# Important notes about rebuilding fmx.jar for Delphi 11.3

## Missing java files

There are 3 java source files missing from the 11.3 distribution:

```
source\rtl\androiddex\java\fmx\src\com\embarcadero\rtl\NativeDispatchException.java
source\rtl\androiddex\java\fmx\src\com\embarcadero\rtl\NativeDispatchHelper.java
source\rtl\androiddex\java\fmx\src\com\embarcadero\rtl\notifications\PendingIntentCompat.java
```

You will need to obtain these files from EMBT in order to rebuild `fmx.jar`. Alternatively, the first two files are included with Delphi 11.2, and the last file (or even all three) could be obtained by using a jar decompiler such as [JD-GUI](https://java-decompiler.github.io/).

## Rebuild

Once the above files have been added, `fmx.jar` can be rebuilt with Codex, using the Build Jar tool, after loading the `fmx.jar.11.3.json` config file and specifying an output file.

