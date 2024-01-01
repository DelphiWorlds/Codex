unit Codex.Consts;

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

uses
{$IF Defined(EXPERT)}
  ToolsAPI,
{$ENDIF}
  Codex.Types;

const
  CRLF = #13#10;

  cCodexMenuItemName = 'CodexMenuItem';
  cCodexReopenFilesItemName = 'CodexReopenFilesMenuItem';
  cCodexProjectFilesItemName = 'CodexProjectFilesMenuItem';
  cCodexOpenRecentProjectItemName = 'CodexOpenRecentProjectMenuItem';

  cCodexToolbarName = 'CodexToolbar';
  cCodexToolbarCaption = 'Codex';
  cEnvVarBDS = 'BDS';
  cEnvVarBDSBin = 'BDSBin';
  cEnvVarBDSLib = 'BDSLib';
  cEnvVarProductVersion = 'ProductVersion';
  cBDSMacro = '$(BDS)';

  cFormsIDEOptionsDialogClassName = 'TDefaultEnvironmentDialog';
  cFormsIDEOptionsDialogPropertySheetName = 'PropertySheetControl1';
  cFormsIDEOptionsDialogPropertiesPanelName = 'Panel2';
  cFormsProjectOptionsDialogClassName = 'TDelphiProjectOptionsDialog';
  cFormsVariableEntryDialogClassName = 'TVariableEntry';
  cFormsProjectManagerFormName = 'ProjectManagerForm';
  cFormsProjectOptionsDialogButtonsPanelName = 'Panel1';
  cFormsProjectOptionsDialogPropertiesPanelName = 'Panel2';
  cFormsProjectOptionsDialogResizePanelName = 'Panel3';
  cFormsProjectOptionsDialogPropertySheetName = 'PropertySheetControl1';
  cFormsEditWindowEditorFormDesigner = 'EditorFormDesigner';
  cFormsEditWindowViewSelector = 'ViewSelector';
  cFormsEditWindowCodeNavToolbar = 'TEditorNavigationToolbar';

  cComponentViewProjectManagerCommand = 'ViewPrjMgrCommand';

  {$IF Defined(EXPERT)}
  cPMMPCodexSection = pmmpVersionControlSection + 500000; // i.e. 7500000
  cPMMPCodexMainSection = pmmpVersionControlSection + 900000; // i.e. 7900000 - don't go past this with "subwizards"
  cPMMPSuppAddSection = pmmpAddSection + 900000; // Makes sure that items in this section appear after the other "Add" items
  {$ENDIF}

//!!!!! Android consts?
  cManifestFileName = 'AndroidManifest.xml';
  cBundleToolPath = 'android\bundletool-all-1.2.0.jar';
  cAAPT2Path = 'android\aapt2.exe';

  cRegistryCodexSubKey = '\DelphiWorlds\Codex';

  cIDEOptionsSectionEnvironment = 'Environment Options';
  cIDEOptionsSectionDeployment = 'Deployment';

  cRecordToolBarComponentName = 'RecordToolBar';
  cViewBarComponentName = 'ViewBar';

  cKnownOutputFileExts: array[0..10] of string = (
    '.dcu', '.o', '.so', '.res', '.dSYM', '.entitlements', '.ext', '.plist', '.ipa', '.xml', '.jar'
  );
  cKnownEditorFileExts: array[0..14] of string = (
    '.pas', '.html', '.md', '.c', '.h', '.xml', '.sql', '.idl', '.vb', '.js', '.css', '.ini', '.php', '.cs', '.txt'
  );

  cMsgColorHint = '#A05528';
  cMsgColorWarning = '#5AB3E5';
  cMsgColorError = '#3852DF';
  cMsgColorSuccess = '#33B46D';

  cMsgColors: array[TTextColor] of string = (cMsgColorHint, cMsgColorWarning, cMsgColorError, cMsgColorSuccess);

implementation

end.
