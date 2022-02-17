@echo on
setlocal ENABLEDELAYEDEXPANSION
IF NOT EXIST "%~dp0..\Other\Source\Registry.nsh.portable" (
    rename "%~dp0..\Other\Source\Registry.nsh" Registry.nsh.portable
)
xcopy "%~dp0User_Laucher" "%~dp0..\Other\Source" /-y /s
set /P updateflag=If update from portableapps? y for update. Input= 
IF %updateflag%==y (
    xcopy "%~d0\PortableApps\NSISPortable\App\AppInfo\Launcher" "%~dp0..\App\AppInfo\Launcher" /-y /s
    xcopy "%~d0\PortableApps\NSISPortable\App\NSIS" "%~dp0..\App\NSIS" /exclude:nsis_exclude.txt /-y /s
    xcopy "%~d0\PortableApps\NSISPortable\Data\settings\nsisconf.nsh" "%~dp0settings\nsisconf.nsh" /-y /s
    xcopy "%~d0\PortableApps\NSISPortable\NSISPortable.exe" "%~dp0..\NSISPortable.exe" /-y /s
)
if not exist "%~dp0..\App\NSIS\Packhdr" mklink /d "%~dp0..\App\NSIS\Packhdr" "%~dp0User_Nsis\Packhdr"
xcopy "%~dp0User_Nsis" "%~dp0..\App\NSIS" /exclude:nsis_exclude.txt /-y /s
pause
endlocal