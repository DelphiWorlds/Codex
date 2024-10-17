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
  sAbout = 'About';
  sAdoptiumOrKeytoolNotFound = 'Eclipse Adoptium Java SDK or Keytool not found';
  sAddToProjectMenuCaption = 'Add To Project';
  sCancel = 'Cancel';
  sCheckForUpdate = 'Check For Update';
  sClose = 'Close';
  sCodexMenuItemCaption = 'Codex';
  sCommandExitedWithCode = 'Command: %s exited with code %d';
  sCommandFailed = 'Command: %s failed with an exit code of: %d';
  sCommandLine = 'Command: %s';
  sComplete = 'Complete';
  sConfirmOverwiteFile = 'File already exists. Overwrite?';
  sCopying = 'Copying...';
  sCopyingFile = 'Copying %s';
  sCopiedToClipboard = 'Copied to clipboard';
  sDuplicateModuleCaption = 'Duplicate Module..';
  sErrorUnknown = 'Unknown error';
  sErrorTimedOut = 'Timed out';
  sExecuting = 'Executing';
  sExecutingCommand = 'Executing: %s';
  sExitCode = 'Exit code: %d';
  sFileNoExist = '%s does not exist';
  sFolderNoExistOrEmpty = '%s does not exist or is empty';
  sInProgress = 'In Progress';
  sLeftWorkingFilesIntact = 'Left working files intact in: %s';
  sKeystoreInfoMissing = 'KeyStore info is missing or incomplete';
  sOptions = 'Options';
  sPleaseCheckMessages = 'Please check the Codex tab of the messages window';
  sPleaseWait = 'Please wait...';
  sProcessComplete = 'Process complete';
  sProcessFailed = 'Process failed';
  sProjectHasBeenMoved = 'Project has been moved or deleted';
  sProjectPathExists = '%s already exists in the project search path';
  sSaveSource = 'Save source';
  sSaveSourceAndResource = 'Save source and %s';
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
  sBuildFailedWithExitCode = 'Build failed with exit code: %d';
  sBuildingJar = 'Building %s..';
  sCompileFailedWithExitCode = 'Compile failed with exit code: %d';
  sCompilingJavaSources = 'Compiling Java sources..';
  sCompletedBuildingJar = 'Completed building: %s';
  sConfirmClearConfig = 'Click Yes to confirm that you wish to reset all values';
  sConfigChanged = 'Config has been modified. Save changes?';
  sDexingFailedWithExitCode = 'Dex-ing failed with exit code: %d';
  sDexingJar = 'Dexing %s..';
  sJavaFolderAlreadyIncluded = 'Folder is already included in %s';
  sMergingResources = 'Merging resources from %s..';
  sNoJavaFilesSpecified = 'No java files have been specified, or they do not share a common folder';
  sNoJavaSources = 'No java sources';
  sSuccessfullyBuiltJar = 'Successfully built: %s';
  sSuccessfullyDexedJar = 'Successfully dexed: %s';
  sUnableToDetermineSubfolders = 'Unable to determine any subfolders under classes. Leaving working path intact: %s';
  sWarningCannotHaveLowerTarget = 'Cannot set a target version lower than the source version';
  sWorkingFilesRetained = 'Working files have been retained in: %s';

  // Mosco
  sAddLinkedFrameworksCaption = 'Add Linked Frameworks';
  sAddSDKFrameworksCaption = 'Add SDK Frameworks';
  sBuildIPACaption = 'Rebuild IPA';
  sCheckProvisioningCaption = 'Check Provisioning';
  sInstallAppCaption = 'Rebuild/Install';
  sMoscoOptionsCaption = 'Mosco Options';
  sSelectSDKCaption = 'Select SDK';
  sSelectProfileCaption = 'Select Profile';
  sShowDeployedAppCaption = 'Show Deployed App';
  sSignLibrariesCaption = 'Sign Libraries';

  sAddSDKFrameworksTitle = 'Add SDK Frameworks';
  sCannotObtainPlatformSDK = 'Unable to obtain platform SDK for %s';
  sCertExpiresOn = '%s certificate expires/expired on: %s';
  sConnectionTestTitle = 'Connection test';
  sConnectionTestCannotDetermineHost = 'Cannot test - hostname cannot be determined';
  sConnectionTestConnected = 'Connected to %s';
  sConnectionTestUnableToConnect = 'Unable to connect. Please ensure that Mosco is running';
  sCurrentProfileNoHost = 'Current: %s (No hostname)';
  sCurrentProfileWithHost = 'Current: %s (%s)';
  sFetchingAppExtensions = 'Fetching app extensions from macOS..';
  sFetchingFrameworks = 'Fetching frameworks from macOS..';
  sFetchingSDKs = 'Fetching SDKs from macOS..';
  sNoFrameworksAdded = 'No frameworks added. Either they already exist, or errors occurred';
  sNoMacDeveloperCert = 'You do not appear to have a macOS developer certificate';
  sNoMacInstallerCert = 'You do not appear to have a macOS installer certificate';
  sNoMatchingImportedSDKs = 'No matching imported SDKs found';
  sNoProvisioningProfile = 'There does not appear to be a matching provisioning profile for this project';
  sRebuildInstalliOSApp = 'Rebuild/install iOS App..';
  sRebuildIPA = 'Rebuild IPA..';
  sUpdatedProjectInstallerCert = 'Updated project macOS installer certificate';
  sUpdatedProjectDeveloperCert = 'Updated project macOS developer certificate';

  // Android
  sADBConnectCaption = 'ADB Connect';
  sAndroidToolsCaption = 'Android Tools';
  sBuildAssetPacksCaption = 'Build Asset Packs';
  sBuildJarCaption = 'Build Jar';
  sCreateRJarCaption = 'Create R Jar';
  sEnsureSDKCompleteMessage = 'Please ensure an Android SDK is configured correctly';
  sExtractAARFilesCaption = 'Extract AAR File';
  sExtractAPKsCaption = 'Extract APKs From AAB';
  sImportGoogleServicesJsonCaption = 'Import google-services.json';
  sInstallAABCaption = 'Install AAB';
  sSDKToolsCaption = 'SDK Tools';
  sJava2OPCaption = 'Java2OP';
  sLogCatCaption = 'Logcat Viewer';
  sMergePackagesCaption = 'Merge Packages';
  sOptionsCaption = 'Options';
  sPackageDownloadCaption = 'Package Download';
  sRebuildAppCaption = 'Rebuild Project';

  sAddAndroidPackageCaption = 'Add Android Package';
  sAddedJarToProject = 'Added %s to project';
  sAddedResourcesToDeployment = 'Added resources to deployment';
  sCannotInstallNoDevice = 'Cannot install - no device found for the active configuration';
  sExtractAPKFromAABCaption = 'Extract APK From AAB';
  sFetchingAPILevels = 'Fetching API Levels..';
  sGetDependenciesFailed = 'Get dependencies failed with exit code: %d';
  sInstallingAPILevels = 'Installing selected API Levels..';
  sInitializationFailed = 'Initialization failed with exit code: %d';
  sPackageFolderAlreadyAdded = 'Package folder has already been added';
  sPerformDeployment = 'Please perform a deployment before adding an Android package';
  sPerformingPostProcessing = 'Performing post processing..';
  sRebuildBundleWithAssetPacksCaption = 'Rebuild Bundle With Asset Packs';
  sSearchingAndroidPackages = 'Searching Android packages..';
  sSelectAndroidPackageFolder = 'Select Android Package Folder';

  sCleanerCaption = 'Cleaner';
  sCleaning = 'Cleaning';
  sConfirmClean = 'Confirm that you wish to delete files with the selected extensions, and the selected folders';
  sProjectFilesForProject = 'Project files for: %s';
  sScanningFiles = 'Scanning files..';
  sScanningFolders = 'Scanning folders..';

  sProjectToolsCaption = 'Project Tools';
  sBundleProjectCaption = 'Bundle Project';
  sCleanCouldNotComplete = 'Clean could not complete. Please see the Codex tab of the Messages window';
  sCleanCouldNotDeleteFile = 'Could not delete file: %s';
  sCleanDeletingFile = 'Deleting %s';
  sCleaningProjectTitle = 'Cleaning %s';
  sCommonPathsCaption = 'Common Paths';
  sEffectivePathsFormCaption = 'Effective Paths for: %s (%s\%s)';
  sFindUnitCaption = 'Find Unit';
  sInsertPathsCaption = 'Insert Paths';
  sResourceFilesCaption = 'Resource Files';
  sShowEffectivePathsCaption = 'Show Effective Paths';
  sShowToolsCaption = 'Show Tools';
  sTotalCleanOfProjectCompleted = 'Total Clean of %s completed successfully';
  sAddFoldersCaption = 'Add Folders To Search Path';
  sDeployExtensionsCaption = 'Deploy Extensions';
  sDeployFolderCaption = 'Deploy Folder';
  sTotalCleanCaption = 'Total Clean';
  sPathsToInsert = 'Paths To Insert';

  sAllPatches = 'All patches';
  sCouldNotOpenFile = 'Could not open %s';
  sDiffFailed = 'Failed to create patch from %s and %s, exit code: %d';
  sDiffSuccessful = 'Successfully created patch %s from %s and %s';
  sPatchesForFileWithMask = 'Patches for %s (%s)';
  sPatchFailed = 'Failed to patch %s using %s, exit code: %d';
  sPatchSuccessful = 'Successfully patched %s using %s';
  sXFilesCopiedToFolder = '%d file(s) copied to %s';
  sSourcePatchTitle = 'Source Patch';
  sSourceCopyRelativeCaption = 'Folder relative to project to copy source to: (blank means same folder as project)';
  sSourceCopyDefaultFolderCaption = 'Default folder to copy source to:';
  sPatchMenuCaption = 'Source Patch';

  sCopySourcesMenuCaption = 'Copy source files';
  sCopySourceMenuCaption = 'Copy source file';
  sCopySourceToProjectMenuCaption = 'Copy file to project folder';
  sCreatePatchMenuCaption = 'Create patch file';
  sPatchSourceMenuCaption = 'Apply patch';
  sPatchSourceToProjectMenuCaption = 'Apply patch to project folder';

  sCodexProjectItemCaption = 'Codex..';
  sCodexReopenFilesItemCaption = 'Reopen File';
  sCodexProjectFilesItemCaption = 'Project Files';
  sConfirmContinueWithDistBuildType = 'Build type is: %s. Continue?';
  sJarFilesMissing = 'One or more jar files for this project are not present in this version of Delphi';

implementation

end.
