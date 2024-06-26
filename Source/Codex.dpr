library Codex;

{$R 'Icon.res' 'Icon.rc'}
{$R 'VersionInfo.res' 'VersionInfo.rc'}
{$R 'Lang.res' 'Lang.rc'}
{$I Codex.LibSuffix.inc}

uses
  Codex.AboutView in 'Core\Codex.AboutView.pas' {AboutView},
  Codex.ActionList.Helper in 'Core\Codex.ActionList.Helper.pas',
  Codex.Android.ADBConnectView in 'Android\Codex.Android.ADBConnectView.pas' {ADBConnectView},
  Codex.Android.AssetPackDetailsView in 'Android\Codex.Android.AssetPackDetailsView.pas' {AssetPackDetailsView},
  Codex.Android.AssetPacksView in 'Android\Codex.Android.AssetPacksView.pas' {AssetPacksView},
  Codex.Android.AssetPackTypes in 'Android\Codex.Android.AssetPackTypes.pas',
  Codex.Android.BuildAssetPacksProcess in 'Android\Codex.Android.BuildAssetPacksProcess.pas',
  Codex.Android.BuildJarView in 'Android\Codex.Android.BuildJarView.pas' {BuildJarView},
  Codex.Android.BuildRJarProcess in 'Android\Codex.Android.BuildRJarProcess.pas',
  Codex.Android.CreateJarProcess in 'Android\Codex.Android.CreateJarProcess.pas',
  Codex.Android.PackageDownloadView in 'Android\Codex.Android.PackageDownloadView.pas' {PackageDownloadView},
  Codex.Android.GenerateAppProcess in 'Android\Codex.Android.GenerateAppProcess.pas',
  Codex.Android.GradleDepsProcess in 'Android\Codex.Android.GradleDepsProcess.pas',
  Codex.Android.Java2OPProcess in 'Android\Codex.Android.Java2OPProcess.pas',
  Codex.Android.Java2OPView in 'Android\Codex.Android.Java2OPView.pas' {Java2OPView},
  Codex.Android.KeyStoreInfoView in 'Android\Codex.Android.KeyStoreInfoView.pas' {KeyStoreInfoView},
  Codex.Android.PackagesView in 'Android\Codex.Android.PackagesView.pas' {PackagesView},
  Codex.Android.ProjectManagerMenu in 'Android\Codex.Android.ProjectManagerMenu.pas',
  Codex.Android.ResourcesModule in 'Android\Codex.Android.ResourcesModule.pas' {AndroidResources: TDataModule},
  Codex.Android.SDKToolsProcess in 'Android\Codex.Android.SDKToolsProcess.pas',
  Codex.Android.SDKToolsView in 'Android\Codex.Android.SDKToolsView.pas' {SDKToolsView},
  Codex.Android.Types in 'Android\Codex.Android.Types.pas',
  Codex.Android.Wizard in 'Android\Codex.Android.Wizard.pas',
  Codex.AST in 'Core\Codex.AST.pas',
  Codex.BaseView in 'Core\Codex.BaseView.pas',
  Codex.Cleaner.CleanView in 'Cleaner\Codex.Cleaner.CleanView.pas' {CleanView},
  Codex.Cleaner.Wizard in 'Cleaner\Codex.Cleaner.Wizard.pas',
  Codex.Config in 'Core\Codex.Config.pas',
  Codex.Config.NEON in 'Core\Codex.Config.NEON.pas',
  Codex.Config.PreVersion2 in 'Core\Codex.Config.PreVersion2.pas',
  Codex.Consts.Text in 'Core\Codex.Consts.Text.pas',
  Codex.Core in 'Core\Codex.Core.pas',
  Codex.CustomPathsView in 'Core\Codex.CustomPathsView.pas' {CustomPathsView: TFrame},
  Codex.CustomResourcesModule in 'Core\Codex.CustomResourcesModule.pas',
  Codex.EditorContextD11.Wizard in 'Wizards\Codex.EditorContextD11.Wizard.pas',
  Codex.EditorContext.Wizard in 'Wizards\Codex.EditorContext.Wizard.pas',
  Codex.ErrorInsight in 'Core\Codex.ErrorInsight.pas',
  Codex.External.DelphiWorlds in 'Core\Codex.External.DelphiWorlds.pas',
  Codex.IDEActions.Wizard in 'Wizards\Codex.IDEActions.Wizard.pas',
  Codex.IDEOptionsView in 'Core\Codex.IDEOptionsView.pas' {IDEOptionsView},
  Codex.IDETweaks.Wizard in 'Wizards\Codex.IDETweaks.Wizard.pas',
  Codex.Interfaces in 'Core\Codex.Interfaces.pas',
  Codex.ModuleNotifier in 'Core\Codex.ModuleNotifier.pas',
  Codex.Modules.DuplicateModuleView in 'Modules\Codex.Modules.DuplicateModuleView.pas' {DuplicateModuleView},
  Codex.Modules.Types in 'Modules\Codex.Modules.Types.pas',
  Codex.Modules.Wizard in 'Modules\Codex.Modules.Wizard.pas',
  Codex.Mosco.AddSDKFrameworkView in 'Mosco\Codex.Mosco.AddSDKFrameworkView.pas' {AddSDKFrameworkView},
  Codex.Mosco.Consts in 'Mosco\Codex.Mosco.Consts.pas',
  Codex.Mosco.Helpers in 'Mosco\Codex.Mosco.Helpers.pas',
  Codex.Mosco.OptionsView in 'Mosco\Codex.Mosco.OptionsView.pas' {MoscoOptionsView},
  Codex.Mosco.ProjectManagerMenu in 'Mosco\Codex.Mosco.ProjectManagerMenu.pas',
  Codex.Mosco.Wizard in 'Mosco\Codex.Mosco.Wizard.pas',
  Codex.FileMenu.Wizard in 'Wizards\Codex.FileMenu.Wizard.pas',
  Codex.IPAddressView in 'Core\Codex.IPAddressView.pas' {IPAddressView: TFrame},
  Codex.Options in 'Options\Codex.Options.pas',
  Codex.OptionsView in 'Options\Codex.OptionsView.pas' {OptionsView},
  Codex.OTA.Helpers in 'Core\Codex.OTA.Helpers.pas',
  Codex.OutputView in 'Core\Codex.OutputView.pas' {OutputView},
  Codex.PListMerger in 'Core\Codex.PListMerger.pas',
  Codex.ProgressView in 'Core\Codex.ProgressView.pas' {ProgressView},
  Codex.ProjectFiles in 'Core\Codex.ProjectFiles.pas',
  Codex.ProjectFilesView in 'Core\Codex.ProjectFilesView.pas' {ProjectFilesView},
  Codex.ProjectNotifier in 'Core\Codex.ProjectNotifier.pas',
  Codex.Project.AddFoldersView in 'Project\Codex.Project.AddFoldersView.pas' {AddFoldersView},
  Codex.Project.CommonPathsView in 'Project\Codex.Project.CommonPathsView.pas' {CommonPathsView},
  Codex.Project.DeployExtensionsView in 'Project\Codex.Project.DeployExtensionsView.pas' {DeployExtensionsView},
  Codex.Project.DeployFolderView in 'Project\Codex.Project.DeployFolderView.pas' {DeployFolderView},
  Codex.Project.EffectivePathsView in 'Project\Codex.Project.EffectivePathsView.pas' {EffectivePathsView},
  Codex.Project.ProjectManagerMenu in 'Project\Codex.Project.ProjectManagerMenu.pas',
  Codex.Project.ProjectPathsView in 'Project\Codex.Project.ProjectPathsView.pas' {ProjectPathsView},
  Codex.Project.ProjectToolsView in 'Project\Codex.Project.ProjectToolsView.pas' {ProjectToolsView},
  Codex.Project.ResourcesModule in 'Project\Codex.Project.ResourcesModule.pas' {ProjectResourcesModule: TDataModule},
  Codex.Project.Wizard in 'Project\Codex.Project.Wizard.pas',
  Codex.ResourcesModule in 'Core\Codex.ResourcesModule.pas' {CodexResourcesModule: TDataModule},
  Codex.SDKRegistry in 'Core\Codex.SDKRegistry.pas',
  Codex.SourcePatch.OptionsView in 'SourcePatch\Codex.SourcePatch.OptionsView.pas' {SourcePatchOptionsView},
  Codex.SourcePatch.PatchProcess in 'SourcePatch\Codex.SourcePatch.PatchProcess.pas',
  Codex.SourcePatch.FunctionsModule in 'SourcePatch\Codex.SourcePatch.FunctionsModule.pas' {SourcePatchFunctionsModule: TDataModule},
  Codex.SourcePatch.ResourcesModule in 'SourcePatch\Codex.SourcePatch.ResourcesModule.pas' {SourcePatchResourcesModule: TDataModule},
  Codex.SourcePatch.Wizard in 'SourcePatch\Codex.SourcePatch.Wizard.pas',
  Codex.Types in 'Core\Codex.Types.pas',
  Codex.Visualizer.MultiLineString in 'Visualizers\Codex.Visualizer.MultiLineString.pas',
  Codex.Visualizer.MultiLineStringFrame in 'Visualizers\Codex.Visualizer.MultiLineStringFrame.pas' {MultiLineStringFrame: TFrame},
  Codex.Wizard in 'Core\Codex.Wizard.pas';

{$R *.res}

begin
end.
