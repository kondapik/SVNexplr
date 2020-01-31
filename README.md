# SVNexplr
Background software to open SVN URLs in windows explorer.

_**SVNexplr**_ detects* SVN URL copied to clipboard by looking for _'SVN repository URL'_, looks for corresponding folder in _'Local SVN path'_, will checkout the folder (if not present) and opens it in windows explorer. 

_*URLs should not contain any white characters (e.g., <space\>)_

## Installation
1. Run 'SVNexplr.exe'
2. Add SVN repository URL with out 'HTTPS://' (E.g., xxxxxx.xxx/xxxxx)
3. Add local SVN path (E.g., D:\xxxxx)
4. Copy shortcut of _'SVNexplr'_ to windows startup folder (open RUN (Windows + R) and type `shell:startup`)

## Usage
Copy SVN URL to clipboard (Ctrl + C)

## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Credits
Kondapi Krishna Prasanth

## License
This project is released under GNU General Public License v3.0
