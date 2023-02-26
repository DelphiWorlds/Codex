# Source Patch

These menu items perform functions related to creating/applying patches for Delphi source. A repo called [Delphi Patches](https://github.com/DelphiWorlds/DelphiPatches) has been started for patch files intended for use with this function.

## Copy source files

Presents an open file dialog that starts at the Delphi source folder. Select one or more files and they will be copied to the folder nominated in the Codex Options (`Default folder to copy source to`), or it will prompt for which folder to copy to if the folder does not exist, or the `Always prompt for folder to copy source to` option is checked. Once source files are copied, they will be opened in the code editor if the `Open source files once copied` option is checked.

## Create patch file

Presents an open file dialog to select which source file copy is to be diffed with existing source. The default folder for source copies can be set in the Codex Options. 

If the original source file cannot be found, it will prompt for selecting the file. 

Lastly, it will prompt for a filename to save the patch file as. The default name for the patch file will be in the format: `[originalname].[version].patch` where `[originalname]` is the original source file name (minus the `.pas` extension), and `[version]` is the version of Delphi being used. 

The default folder for where patch files will be prompted for can also be set in the Codex Options (`Default location for patch files`)

## Apply patch

Presents an open file dialog to select which patch file to apply to a copy of the source. It will then either prompt for the copy of the source, or automatically apply it to an existing source file if it can be found in the default source file copies folder specified in the Codex Options (`Default folder to copy source to`)

**Note: The last 2 items require [Git](https://git-scm.com/) to be installed on the machine before the items will enable**

