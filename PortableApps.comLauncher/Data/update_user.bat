@echo on
setlocal ENABLEDELAYEDEXPANSION
if NOT EXIST "%~dp0..\Other\Source\Registry.nsh.portable" (
    rename "%~dp0..\Other\Source\Registry.nsh" Registry.nsh.portable
)
xcopy "%~dp0User_Laucher" "%~dp0..\Other\Source" /-y /s
set /P version=update nsis 2 or 3? Input 2/3. version= 
if not defined version (set nsis=nsis3) else (
    if "%version%"=="2" (set nsis=nsis) ELSE (set nsis=nsis3)
)

set /P updateflag=Whether update from portableapps? y for update. Input= 
if /i "%updateflag%"=="y" (
    xcopy "%~d0\PortableApps\NSISPortable\App\AppInfo\Launcher" "%~dp0..\App\AppInfo\Launcher" /-y /s
    xcopy "%~d0\PortableApps\NSISPortable\App\NSIS" "%~dp0..\App\%nsis%" /exclude:nsis_exclude.txt /-y /s
    xcopy "%~d0\PortableApps\NSISPortable\Data\settings\nsisconf.nsh" "%~dp0settings\nsisconf.nsh" /-y /s
    xcopy "%~d0\PortableApps\NSISPortable\NSISPortable.exe" "%~dp0..\NSISPortable.exe" /-y /s
)
if not exist "%~dp0..\App\%nsis%\Packhdr" mklink /d "%~dp0..\App\%nsis%\Packhdr" "%~dp0User_Nsis\Packhdr"
xcopy "%~dp0User_Nsis" "%~dp0..\App\%nsis%" /exclude:nsis_exclude.txt /-y /s
if not exist "%~dp0..\App\%nsis%\Plugins\x86-unicode" (
    xcopy "%~dp0User_Nsis\Plugins\x86-unicode" "%~dp0..\App\%nsis%\Plugins" /-y /s
) else (
    xcopy "%~dp0User_Nsis\Plugins" "%~dp0..\App\%nsis%\Plugins" /-y /s
)

pause
endlocal