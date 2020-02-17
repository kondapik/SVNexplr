/* 
    Name:
    SVNexplr.ahk

    DESCRIPTION:
    Opens SVN path in file explorer  

    CREATED BY : Kondapi V S Krishna Prasanth
    DATE OF CREATION: 28-Jan-2020
    LAST MODIFIED: 28-Jan-2020

    VERSION MANAGER
    v1      Working copy without exception handling
*/

#SingleInstance,Force

applicationname=SVNexplr

Gosub,TRAYMENU
Gosub,READINI

if SubStr(svnURL, 0) = "/"
  svnURL := SubStr(svnURL, 1, StrLen(svnURL)-1)
if SubStr(svnPath, 0) = "\"
  svnPath := SubStr(svnPath, 1, StrLen(svnPath)-1)

svnLen := StrLen(svnURL)
clipboard := ""
oldClip := ""
BtnTxt := "" 
loop
{
    ClipWait  ; Wait for the clipboard to contain text.
    if (clipboard == oldClip)
    {}
    else
    {
        strPos := InStr(clipboard,svnURL)
        if strPos
        {
            clippedURL := SubStr(clipboard, strPos)
            spacePos := InStr(clippedURL,A_Space)
            lnPos := InStr(clippedURL,"`")
            ;MsgBox, %clippedURL%, %spacePos%, %lnPos%
            if (spacePos > 0 or lnPos > 1)
            {
                if (spacePos > lnPos)
                    clippedURL := SubStr(clippedURL, 1, (spacePos - 1))
                else
                    clippedURL := SubStr(clippedURL, 1, (lnPos - 1))
            }
            
            URLpath := SubStr(clippedURL, (svnLen+1))
            fullURL = https://%clippedURL%
            
            ;MsgBox, %dirURL%
            fullPath = %svnPath%%URLpath%
            fullPath := RegExReplace(fullPath, "\/\/|\/","\",,,1)
            SplitPath, fullPath,, dirPath, extPath
            if extPath
            {}
            else
                dirPath := RegExReplace(fullPath,"\s","")
            ;MsgBox, %fullPath%
            
            ;replace %20
            URLpath := RegExReplace(URLpath,"%20"," ")

            If FileExist(dirPath)
            {
                BtnTxt := "File found. Open Path?"
            }
            else
                BtnTxt := "File not found. Commit Path and open?"
            ;MsgBox, SVN URL found in clipboard:`n`n%svnURL%. `n SVN path is: `n%URLpath%.
            setFlag = off

            MsgBox, 33, SVN URL found in clipboard, SVN URL:`n%svnURL% `n`nSVN path is: `n%URLpath%.`n`n%BtnTxt%
            IfMsgBox, OK
            {   
                if (BtnTxt = "File not found. Commit Path and open?")
                    createFolders(svnPath, dirPath, svnURL, fullURL, svnPath)
                    ;RunWait, %ComSpec% /c svn checkout --depth immediates %dirURL% %dirPath%
                dirPath := RegExReplace(dirPath,"%20"," ")
                Run, %dirPath%
                setFlag = on
            }
            ;If (setFlag = "off")
                ;MsgBox, You chose Ignore.
        }
        ;MsgBox, Control-C copied the following contents to the clipboard:`n`n%clipboard% %A_Index%
        oldClip := clipboard
    }
    Sleep, 500
}

;immediates -> Checkout all files and child folders but donot populate them
;files -> Checkout all files and not child folders
createFolders(currPath, dstPath, svnURL, fullURL, svnPath){
    ;Check the availble
    if FileExist(currPath){
    }
    else{
        ;checkout - empty
        diffLen := strLen(currPath) - strLen(svnPath)
        svnTemp := SubStr(fullURL,1, (strLen(svnURL)+8+diffLen))
        currPathWS := RegExReplace(currPath,"%20"," ")
        commands =
        (join&
        echo Checking out SVN path: "%svnTemp%"
        echo.
        svn checkout --depth immediates "%svnTemp%" "%currPathWS%"
        )
        RunWait, %ComSpec% /c %commands%
    }

    if (currPath == dstPath)
    {
        SplitPath, fullURL,, dirURL
        SplitPath, fullURL,, dirURL, extPath
        if extPath
        {}
        else
            dirURL := fullURL
            ;dirURL := RegExReplace(fullURL,"\s","")
        currPathWS := RegExReplace(currPath,"%20"," ")
        commands =
        (join&
        echo Checking out SVN path: "%dirURL%"
        echo.
        svn checkout --depth immediates "%dirURL%" "%currPathWS%"
        )
        RunWait, %ComSpec% /c %commands%
    }
    else{
        ;Updating Path
        foundPos := InStr(dstPath, "\" ,,(StrLen(currPath)+2))
        if foundPos
            currPath := SubStr(dstPath, 1, FoundPos - 1)
        else
            currPath := dstPath
        ;MsgBox, %FoundPos%`n%currPath%`n`nsvnUrl:%svnTemp%.
        ;`n%fullURL%`n%svnURL%
        createFolders(currPath, dstPath, svnURL, fullURL, svnPath)
    }
}

READINI:
IfNotExist,%applicationname%.ini
{
    InputBox, svnURL, SVN Repository URL, Provide SVN Repository URL (without https://), , , , , , , ,<xxxxxxxxxx>.kpit.com/svn/<XXXXXXXX>
    FileSelectFolder, svnPath, , 2, Select path to local SVN repository
    inifile=;%applicationname%.ini
    inifile=%inifile%`n`;[Settings]
    inifile=%inifile%`n`;SVN_URL: URL of SVN repository (Eg., <xxxxxxxxxx>.kpit.com/svn/<XXXXXXXX>)
    inifile=%inifile%`n`;SVN_Path: Path to local SVN repository (Eg., D:\XXXXXXXX or D:\svn) 
    inifile=%inifile%`n
    inifile=%inifile%`n[Settings]
    inifile=%inifile%`nSVN_URL=%svnURL%
    inifile=%inifile%`nSVN_Path=%svnPath%
    FileAppend,%inifile%,%applicationname%.ini
}

IniRead,svnURL,%applicationname%.ini,Settings,SVN_URL
IniRead,svnPath,%applicationname%.ini,Settings,SVN_Path
inifile=
Return

TRAYMENU:
Menu,Tray,NoStandard
Menu,Tray,Add,%applicationname%,SETTINGS
Menu,Tray,Add,
Menu,Tray,Add,&Settings...,SETTINGS
Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Default,%applicationname%
Menu,Tray,Tip,%applicationname%
Return


SETTINGS:
Gosub,READINI
Run,%applicationname%.ini
Return


EXIT:
GuiClose:
ExitApp

ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font, s16, Work Sans Light
Gui,99:Add,Text,x+10 yp+10,%applicationname%  v1.0
Gui,99:Font, s11, Work Sans Medium
Gui,99:Add,Text,y+10,Opens SVN path in windows explorer
Gui,99:Font, s10 norm, Work Sans
Gui,99:Add,Text,y+5,- Detects SVN path copied to clipboard by looking for "SVN repository URL" and 
Gui,99:Add,Text,y+0,open it windows explorer w.r.t "Local SVN path" (i.e path to local SVN repository)

Gui,99:Font,s10 italic, Work Sans
Gui,99:Add,Text,y+20,SVN repository URL: %svnURL%
Gui,99:Add,Text,y+5,Local SVN Path: %svnPath% 

Gui,99:Font,s14 norm Underline, Work Sans Light
Gui,99:Add,Text,y+20,Directions of Use:
Gui,99:Font,s10 norm, Work Sans
Gui,99:Add,Text,y+5,- Copy SVN path to clipboard (i.e Ctrl+C)
Gui,99:Add,Text,y+5,- To change "SVN repository URL" or "Local SVN path", edit the %applicationname%.ini
Gui,99:Add,Text,y+0,by right clicking the tray menu and selecting Settings

;Gui,99:Add,Picture,xm y+20 Icon2,%applicationname%.exe
Gui,99:Font,s12, Work Sans Medium
Gui,99:Add,Text,y+30,Designed by Kondapi Krishna Prasanth
Gui,99:Add,Text,xm y+5,


Gui,99:Show,,%applicationname% About
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE") 
Return

99GuiClose:
  Gui,99:Destroy
  OnMessage(0x200,"")
  DllCall("DestroyCursor","Uint",hCur)
Return

WM_MOUSEMOVE(wParam,lParam)
{
  Global hCurs
  MouseGetPos,,,,ctrl
  If ctrl in Static9,Static13,Static17
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return
