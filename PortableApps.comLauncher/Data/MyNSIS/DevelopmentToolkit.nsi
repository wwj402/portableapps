/* $LauncherFile=z:\PortableAppz\ReplaceStudioPortable\App\AppInfo\Launcher\ReplaceStudioPortable.ini
$EXEFILE=ReplaceStudioPortable.exe
$AppID=ReplaceStudioPortable
$BaseName=ReplaceStudioPortable
$EXEDIR=z:\PortableAppz\ReplaceStudioPortable */

${SegmentFile}

!include "x64.nsh"

Var portableapp_dir
Var app_name
Var app_display
Var exe_ver
Var ini_ver

LangString PalMessage1 1033 "Version in ini:$ini_ver$\nVersion in exe:$exe_ver$\nReplace?"
LangString PalMessage1 2052 "ini文件中版本:$ini_ver$\nexe文件中版本:$exe_ver$\n是否替换？"


Function setcontrol

	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start$R0 $R7
	; IfErrors 0 +2
	; MessageBox MB_OK 'WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start$R0 $R7/error'
	MoreInfo::GetProductName "$R9"
	Pop $R1
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Name$R0 $R1
	CopyFiles "$portableapp_dir\App\AppInfo\appicon.ico" "$portableapp_dir\App\AppInfo\appicon$R0.ico"
	IntOp $R0 $R0 + 1
	; MessageBox MB_OK "$portableapp_dir$\n$R7$\n$1$\n$R0$\n$0"
	Push $0

FunctionEnd

Function setdetails

	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start $R7
	${GetBaseName} "$R9" $R1
	ReadINIStr $R2 "$portableapp_dir\App\AppInfo\appinfo.ini" Details Path
	${If} $R2 != ""
		MoreInfo::GetFileVersion "$portableapp_dir\App\$R2"
		Pop $exe_ver
		MoreInfo::GetCompanyName "$portableapp_dir\App\$R2"
		Pop $R3
	${Else}
		${If} ${RunningX64}
			ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable64
			${If} $R2 == ""
				ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable
			${EndIf}
		${Else}
			ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable
		${EndIf}
		MoreInfo::GetFileVersion "$portableapp_dir\App\$R2"
		Pop $exe_ver
		MoreInfo::GetCompanyName "$portableapp_dir\App\$R2"
		Pop $R3
	${EndIf}

	MessageBox MB_OK "$exe_ver;$R3"
	${If} $R3 == ""
		MoreInfo::GetCompanyName "$R9"
		Pop $R3
		${If} $R3 == ""
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details Publisher ""
		${Else}
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details Publisher $R3
		${EndIf}
	${Else}
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details Publisher $R3
	${EndIf}

	${If} $exe_ver != ""
		ReadINIStr $ini_ver "$portableapp_dir\App\AppInfo\appinfo.ini" Version DisplayVersion
		${If} $exe_ver != $ini_ver
			MessageBox MB_YESNO "$(PalMessage1)" IDYES 0 IDNO VERNOCHANGE
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Version DisplayVersion $exe_ver
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Version PackageVersion $exe_ver
			VERNOCHANGE:
		${EndIf}
	${EndIf}
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details AppID $R1
	MoreInfo::GetProductName "$R9"
	Pop $R1
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details Name $R1
	; MessageBox MB_OK "$R7$\n$1$\n$exe_ver"
	StrCpy $R1 StopLocate
	Push $R1

FunctionEnd


${SegmentPostPrimary}

	ReadINIStr $portableapp_dir "$EXEDIR\Data\settings.ini" Main Package
	${WordReplace} "$portableapp_dir" "/" "\" "+*" $portableapp_dir
	; MessageBox MB_OK "portableapp_dir, $portableapp_dir"
	IfFileExists "$portableapp_dir\*.exe" EXISTEXE 0
	CreateDirectory "$portableapp_dir\App\DefaultData"
	CreateDirectory "$portableapp_dir\Data\settings"
	CreateDirectory "$portableapp_dir\App\AppInfo\Launcher"
	CopyFiles "$EXEDIR\Data\app-template\App\DefaultData\*.*" "$portableapp_dir\App\DefaultData"
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\Launcher\*.*" "$portableapp_dir\App\AppInfo\Launcher"
	ReadINIStr $app_name "$portableapp_dir\App\AppInfo\appinfo.ini" Details AppID
	; MessageBox MB_OK "app_name, $app_name"
	; Rename $portableapp_dir\App\AppInfo\Launcher\appname.ini $portableapp_dir\App\AppInfo\Launcher\$app_name.ini
	CopyFiles "$portableapp_dir\App\AppInfo\Launcher\AppPortable.ini" "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini"
	ReadINIStr $app_display "$portableapp_dir\App\AppInfo\appinfo.ini" Details Name
	WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Launch AppName $app_display
	EXISTEXE:
	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\Custom.nsh" EXISTNSH 0
	CreateDirectory "$portableapp_dir\App\AppInfo\Launcher"
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\Launcher\*.*" "$portableapp_dir\App\AppInfo\Launcher"
	EXISTNSH:
	IfFileExists "$portableapp_dir\App\AppInfo\appicon*.*" +2 0
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\appicon*.*" "$portableapp_dir\App\AppInfo"
	StrCpy $R0 1
	${Locate} "$portableapp_dir" "/L=F /M=*Portable.exe  /G=0" "setcontrol"
	IntOp $R0 $R0 - 1
	${If} $R0 == 0
		StrCpy $R0 1
	${EndIf}
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Icons $R0
	${Locate} "$portableapp_dir" "/L=F /M=*Portable.exe  /G=0" "setdetails"

	ExecShell "open" "$portableapp_dir\App\AppInfo\appinfo.ini"

!macroend

