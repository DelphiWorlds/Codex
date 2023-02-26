# Codex

This repository is for documentation, installers and for reporting issues

## Description

Codex:

* Is an expert that can be installed into the Delphi IDE
* Helps boost your productivity
* Integrates with [Mosco](https://github.com/DelphiWorlds/Mosco) (macOS application) to perform iOS/macOS related tasks
* Supports Delphi 11 Alexandria (Codex v1.5 and later only), Delphi 10.4 Sydney (Codex v1.5, v1.5.1 and v1.4), Delphi 10.3 Rio (Codex v1.3.1 and below), Delphi 10.2 Tokyo (Codex v1.2.0 only), and Delphi 10.1 Berlin (Codex v1.0.0 only)
* Is implemented using the [TOTAL library](https://github.com/DelphiWorlds/TOTAL). 

The complete source for Codex is planned to be released when version 2.0 is ready, which is currently scheduled for late 2023  

## Installation

Installers for Codex can be found in the [Bin folder](Bin)

Installation is straightforward - run the installer and follow the prompts

## Documentation

Can be found [here](Docs/Readme.md).

## Change history

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



