unit Codex.Consts.Text;

{*******************************************************}
{                                                       }
{                      Codex                            }
{                                                       }
{         Add-in for Delphi from Delphi Worlds          }
{                                                       }
{  Copyright 2020-2023 Dave Nottage under MIT license   }
{  which is located in the root folder of this library  }
{                                                       }
{*******************************************************}

interface

resourcestring
  // General
  sAdoptiumOrKeytoolNotFound = 'Eclipse Adoptium Java SDK or Keytool not found';
  sCancel = 'Cancel';
  sClose = 'Close';
  sCommandExitedWithCode = 'Command: %s exited with code %d';
  sCommandFailed = 'Command: %s failed with an exit code of: %d';
  sCommandLine = 'Command: %s';
  sComplete = 'Complete';
  sConfirmOverwiteFile = 'File already exists. Overwrite?';
  sCopying = 'Copying...';
  sCopyingFile = 'Copying %s';
  sCopiedToClipboard = 'Copied to clipboard';
  sExecuting = 'Executing';
  sExecutingCommand = 'Executing: %s';
  sExitCode = 'Exit code: %d';
  sFileNoExist = '%s does not exist';
  sFolderNoExistOrEmpty = '%s does not exist or is empty';
  sInProgress = 'In Progress';
  sLeftWorkingFilesIntact = 'Left working files intact in: %s';
  sKeystoreInfoMissing = 'KeyStore info is missing or incomplete';
  sPleaseCheckMessages = 'Please check the Codex tab of the messages window';
  sPleaseWait = 'Please wait...';
  sProcessComplete = 'Process complete';
  sProcessFailed = 'Process failed';
  sSearching = 'Searching...';
  sUnableToCreateFolder = 'Unable to create folder: %s';

  // ADB Connect
  sSucceededNotConnected = 'All commands succeeded, however device connection was not detected';
  sConnectedSuccessfully = 'Connected successfully with device at: %s';

  // App Hash
  sCopiedHashToClipboard = 'Copied hash to clipboard: %s';
  sErrorGeneratingHash = 'Error generating hash: %s';

  // Asset packs
  sAssetsFolderMissingOrEmpty = 'Assets folder for %s is either missing or empty';
  sBuildingAssetPacks = 'Building Asset Packs..';
  sBuildingBundle = 'Building Bundle..';
  sCheckConfig = 'Please ensure the target project and correct configuration is selected';
  sCheckConfigAndDeployed = 'Please ensure the correct configuration is made active and that the project has been built/deployed first.';
  sConfirmDeleteAssetPack = 'Delete Asset Pack %s? Note: This will delete the %s folder and its contents';
  sFolderHasIssues = 'The selected folder has issues.';
  sFolderNoExistCreateAssetPack = 'Folder does not exist. Create Asset Pack?';
  sInstallingBundle = 'Installing bundle..';
  sInvalidAssetPackManifest = '%s is not a valid asset pack manifest';
  sManifestMissingOrInvalid = 'Manifest for %s is either missing or invalid';
  sNoValidAssetPacksFound = 'No valid asset packs found in %s';
  sRenameAssetPackFolder = 'Rename Asset Pack folder to: %s?';
  sSelectAndroidForAssetPacks = 'Please select an Android platform in order to use Build Asset Packs';
  sSuccessfullyInstalledBundle = 'Successfully installed bundle';
  sSuccessfullyRebuiltBundle = 'Successfully rebuilt app bundle including asset packs';
  sUnableToBuildAssetPacks = 'Unable to start asset packs build process.';
  sUnableToBuildBundle = 'Unable to start bundle build process.';
  sUnableToCompilePacks = 'Unable to compile any packs.';

  // Build Jar
  sBuildAJarCaption = 'Build A Jar';
  sBuildingJar = 'Building %s..';
  sCompilingJavaSources = 'Compiling Java sources..';
  sCompletedBuildingJar = 'Completed building: %s';
  sConfirmClearConfig = 'Click Yes to confirm that you wish to reset all values';
  sConfigChanged = 'Config has been modified. Save changes?';
  sJavaFolderAlreadyIncluded = 'Folder is already included in %s';
  sMergingResources = 'Merging resources from %s..';
  sNoJavaFilesSpecified = 'No java files have been specified, or they do not share a common folder';
  sNoJavaSources = 'No java sources';
  sUnableToDetermineSubfolders = 'Unable to determine any subfolders under classes. Leaving working path intact: %s';
  sWarningCannotHaveLowerTarget = 'Cannot set a target version lower than the source version';
  sWorkingFilesRetained = 'Working files have been retained in: %s';

implementation

end.
