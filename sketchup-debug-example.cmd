PATH=%PATH%;C:\Program Files\SketchUp\SketchUp 2021

xcopy /Y /E C:\Users\mikhail\Documents\Projects\sketchup\plugins\ "C:\Users\mikhail\AppData\Roaming\SketchUp\SketchUp 2021\SketchUp\Plugins\"

SketchUp.exe -rdebug "ide port=7000"