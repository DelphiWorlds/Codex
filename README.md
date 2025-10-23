# Codex

## Description

Codex:

* Is an expert that can be installed into the Delphi IDE
* Helps boost your productivity
* Integrates with [Mosco](https://github.com/DelphiWorlds/Mosco) (macOS application) to perform iOS/macOS related tasks
* Supports Delphi 12 Athens (Codex v2.0.0 only), Delphi 11 Alexandria (Codex v1.6 and later only), Delphi 10.4 Sydney (Codex v1.5, v1.5.1 and v1.4), Delphi 10.3 Rio (Codex v1.3.1 and below), Delphi 10.2 Tokyo (Codex v1.2.0 only), and Delphi 10.1 Berlin (Codex v1.0.0 only)
* Is implemented using the [TOTAL library](https://github.com/DelphiWorlds/TOTAL). 

The latest release version can be downloaded [here](https://www.delphiworlds.com/codex/latest), and older installers are [here](https://www.delphiworlds.com/codex/older).

**NOTE**: 

**Codex 2.4.3 is a special build for Delphi 13.0** which corrects an issue with the `Add Android Package` function **ONLY**, so it is necessary to install this version *only if you use this function*. Please [download from here](https://www.delphiworlds.com/files/download.php?file=/codex/CodexSetup_2.4.3.exe).

**Codex 2.3.1 is a special build for Delphi 12.1, which has a [workaround for merging AndroidManifest.xml](https://github.com/DelphiWorlds/Kastri/blob/master/Delphi12.1.AndroidManifestIssue.md)**, and can be [downloaded from here](https://www.delphiworlds.com/files/download.php?file=/codex/CodexSetup_2.3.1.exe).

The 64-bit IDE is **yet to be supported in releases**, as I am yet to use it, and since there is yet to be support for cross-platform, which Codex is heavily oriented towards. Having said that, a 64-bit version of Codex could be compiled from the source.

## Installation

Installation is straightforward - run the installer and follow the prompts

## Building Codex from source

### Supported Delphi versions

Codex should compile in at least Delphi 13 and Delphi 12.x, however it may compile in earlier versions.

### Building

Clone the Codex repo, and each of the dependencies:

* [TOTAL](https://github.com/DelphiWorlds/TOTAL)
* [Kastri](https://github.com/DelphiWorlds/Kastri)
* [Babel](https://github.com/DelphiWorlds/Babel)
* [Mosco](https://github.com/DelphiWorlds/Mosco)
* [NEON](https://github.com/paolo-rossi/delphi-neon)
* [Delphi AST](https://github.com/RomanYankovsky/DelphiAST)

The Codex project search paths make use of `User System Overrides` (These can be set up in the IDE options Tools | Options, IDE > Environment Variables), which point to the folders of the respective dependencies. Either create matching overrides in your IDE, or update the project search paths in the Codex project so that the compiler finds them.

Build from the Codex project (`Codex.dproj`), for the Windows 32-bit target.

## Documentation

Can be found [here](Docs/Readme.md).

## Change history

v2.4.3 (Oct 23rd, 2025) Delphi 13.0

* Corrects an issue with the `Add Android Package` function

Please install **ONLY** if you use this function (see notes above)

v2.4.2 (Sep 12th, 2025) Delphi 13.0, 12.x 

* Updated for Delphi 13
* Fixed Java2OP process
* Removed option for suppression of build events warning
* Minor fixes/tweaks

v2.4.1 (Oct 18th, 2024) Delphi 12.0, 12.1, 12.2 Patch 1 only. 

* Rebuilt to be compatible with the versions listed
* Minor fixes/tweaks

**NOTE**

Delphi 12.2 users will need to install Patch 1 to use this version
  
v2.4.0 (Sep 15th, 2024) Delphi 12.x only. 

* Refactored rebuild of IPA for signing of extensions
* Download of packages now allows for retaining .aar files
* Minor fixes/tweaks

**NOTE** 

* Deploying extensions and IPA rebuild functions require [Mosco 1.7.0](https://www.delphiworlds.com/mosco/latest)
* Delphi 12.0 and 12.1 users will need to replace the installed `Codex290.dll` file (installed by default in `C:\Program Files (x86)\DelphiWorlds\Codex`) with this [replacement DLL](https://www.delphiworlds.com/files/hotfix/Codex290.dll), as the DLL in the installer was built with Delphi 12.2 and is **not binary compatible** with Delphi 12.0 and Delphi 12.1.

v2.3.2 (Jun 25th, 2024) Delphi 12.x and 11.x only

* Fixed issues with Asset Packs build process

v2.3.1 (Jun 11th, 2024) Delphi 12.x only

**This release affects Delphi 12.1 only** (but can be installed in any Delphi 12.x version)

* Added [workaround for merging of AndroidManifest.xml](https://github.com/DelphiWorlds/Kastri/blob/master/Delphi12.1.AndroidManifestIssue.md)

v2.3.0 (May 13th, 2024) Delphi 12.x and 11.x only

* Added SDK Tools feature - at present, just install of API levels
* Added Multiline string visualizer for string variables
* Added waiting indicator for Package Download
* Fixed adding of R jar to project
* Fixed Connect button re-enable on ADB Connect
* Minor fixes/tweaks

v2.2.0 (Apr 5th, 2024) Delphi 12.x and 11.x only

* Refactored R jar generation for Delphi 12.1 support
* Fixed R jar generation for App Store in Delphi 12.0
* Fixed resolution of packages which target more than one environment (e.g. Guava - Android/JVM) in Package Download 
* Added project modification notification - title now updates when deployment type is changed
* Minor fixes/tweaks

v2.1.1 (Mar 1st, 2024) Delphi 12 and 11.x only

* Fixed R jar generation (was locking up)
* Added timeout for package search (currently needs to be changed manually in config.json)

v2.1.0 (Jan 1st, 2024) Delphi 12 and 11.x only

**Mosco functions require Mosco v1.6.0**

* Added Deploy Extensions feature
* Added support for theme changes
* Added support for coloring of messages
* Fixed kill process feature
* Fixed form placement/size when re-opening
* Fixed project info update (shown in IDE title)
* Minor fixes/tweaks

v2.0.0 (Nov 8th, 2023) Delphi 12 and 11.x only

**Mosco functions require Mosco v1.5.0**

* First source release
* Added internationalization
* Added "Add Folders" feature
* Added "Project Files" feature
* Fixed issues with Package Download (Android Tools)
* Refactored Mosco REST client code
* Minor fixes/tweaks

v1.6.0 (Feb 26th, 2023) Delphi 11.x only. 

**Mosco functions require Mosco v1.4.0**

* Revamped Package Download
* Added handling of Android Packages (merges resources, creates R jar)
* Added checks for expired Apple certs (requires Mosco)
* Added check for valid provisioning profile (requires Mosco)
* Remembers sizes, positions of sizeable dialogs
* Improved IP address handling in ADB Connect
* Changed Mosco comms
* Removed IDE Path Sets (may be reintroduced later)

v1.5.1 (Oct 11th, 2021) - Delphi 11.x and 10.4 Only

* Added workaround for [Apple App Store deployment issue](https://quality.embarcadero.com/browse/RSP-35701)
* Added [Play Asset Delivery](https://developer.android.com/guide/playcore/asset-delivery) support
* Reworked creation of R jar
* Added option of creating R jars when using Package Download

v1.5.0 (Sept 10th, 2021) - Delphi 11.x and 10.4 Only

* Merged [Mosco](https://github.com/DelphiWorlds/MoscoExpert) functionality
* Removed Android config - now uses settings from the SDK entries in the registry
* Added Insert Paths function
* Added Enable read-only editor popup menu item property
* Added Suppress Build Events warning property (Delphi 11 only)
* Added Single-click Welcome Page options (Delphi 11 only)
* Added Package Download (Maven) function
* Removed remaining "hidden" options
* Revamped Options dialog
* Various fixes

v1.4.0 (April 28th, 2021) - Delphi 10.4 ONLY

* Added: Path Sets
* Added: Source Patching
* Some items now hidden pending future updates
* Removed items no longer required
* Various fixes

v1.3.1 (July 23rd, 2020) - Delphi 10.4 and 10.3 support

* Fixed selection of JDK path in Android Tools
* Modified Logcat Viewer option to launch [Device Lens](http://github.com/DelphiWorlds/DeviceLens) if it exists

v1.3.0 (May 28th, 2020) - Delphi 10.4 and 10.3 support

* Add ADB Connect function - connect to an Android device over the internet!
* Added "Total Clean" function - cleans all files in output folders

v1.2.3 (December 23rd, 2019) - NOTE: This release is for Delphi 10.3.x ONLY

* Fixed Build Jar function so that packages with a prefix of other than com will build successfully
* Fixed Editor Tabs On Left option so that it can be turned off
* Fixed theming of Android options dialog

v1.2.2 (December 1st, 2019) - NOTE: This release is for Delphi 10.3.x ONLY

* Fixed reliability of editor tabs on the left side

v1.2.1 (October 1st, 2019) - NOTE: This release is for Delphi 10.3.x ONLY

* Updated Image Assets function to support current image sizes
* Removed faulty logcat viewer - please use [Device Lens](http://github.com/DelphiWorlds/DeviceLens)
* Fixed IDE theming for all views
* Minor bug fixes

v1.2.0 (March 5th, 2019)

* Added Feed Alerts feature
* Moved logcat color selection into the LogCat viewer window
* Updated Image Assets feature to support the new image/icon sizes supported by Delphi 10.3.1
* Added option for moving the editor tabs to the left hand side (like they used to be)
* Modified the Options dialog to have multiple pages for different categories

(History for earlier versions unavailable)



