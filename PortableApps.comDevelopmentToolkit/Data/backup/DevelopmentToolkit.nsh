/* $LauncherFile=z:\PortableAppz\ReplaceStudioPortable\App\AppInfo\Launcher\ReplaceStudioPortable.ini
$EXEFILE=ReplaceStudioPortable.exe
$AppID=ReplaceStudioPortable
$BaseName=ReplaceStudioPortable
$EXEDIR=z:\PortableAppz\ReplaceStudioPortable */

${SegmentFile}

!include "x64.nsh"
!include "UserForEachINIPair.nsh"

!define RHEXE "$EXEDIR\..\NSISPortable\Data\User_Nsis\Packhdr\ResHacker.exe"
!define SYBEXE64 "$EXEDIR\..\CommonFiles\NTLinksMaker\NTLinksMaker64.exe"
!define SYBEXE "$EXEDIR\..\CommonFiles\NTLinksMaker\NTLinksMaker.exe"
!define SYBSWITCH "/q /n /b /s"

Var portableapp_dir
Var app_name
Var app_display
Var exe_ver
Var ini_ver
Var inisecflag
Var sybexeused

LangString PalMessage1 1033 "Version in ini:$ini_ver$\nVersion in exe:$exe_ver$\nReplace?"
LangString PalMessage1 2052 "ini文件中版本:$ini_ver$\nexe文件中版本:$exe_ver$\n是否替换？"
LangString PalMessage2 1033 'Does the .nsh file create link? $\n "Yes" to create link, "No" to copy directly.'
LangString PalMessage2 2052 ".nsh 文件是否创建链接？$\n“是”创建链接，“否”直接复制。"
LangString PalMessage3 1033 '$R7 file already exists, is it overwritten? $\n"Yes" override, "No" Skip.'
LangString PalMessage3 2052 "$R7 文件已存在，是否覆盖？$\n“是”覆盖，“否”跳过。"

Function copyicon
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	CopyFiles "$R9" "$portableapp_dir\App\AppInfo\appicon.ico"
	CopyFiles "$R9" "$portableapp_dir\App\AppInfo\appicon$R0.ico"
	RMDir /r "$R8"
	Push "StopLocate"
FunctionEnd

Function seticons
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R1
	Push $R2
	Push $R3
	${GetBaseName} "$R9" $R1
	ReadINIStr $R2 "$R9" Launch ProgramExecutable
	${If} $R2 == ""
	${OrIfNot} ${FileExists} "$portableapp_dir\App\$R2"
		ReadINIStr $R2 "$R9" Launch ProgramExecutable64
	${EndIf}
	${If} ${FileExists} "$portableapp_dir\App\$R2"
		MoreInfo::GetProductName "$portableapp_dir\App\$R2"
		Pop $R3
		WriteINIStr "$R9" "Launch" "AppName" "$R3"
		ExecWait '"${RHEXE}" -open "$portableapp_dir\App\$R2" -save "$portableapp_dir\App\AppInfo\icons" -action extract -mask ICONGROUP,, -log CON'
	${Else}
		IfFileExists "$portableapp_dir\$R1.exe" 0 +2
		ExecWait '"${RHEXE}" -open "$portableapp_dir\$R1.exe" -save "$portableapp_dir\App\AppInfo\icons" -action extract -mask ICONGROUP,, -log CON'
	${EndIf}
	${If} ${FileExists} "$portableapp_dir\App\AppInfo\icons"
		Push $R7
		${Locate} "$portableapp_dir\App\AppInfo\icons" "/L=F /M=*.ico /G=0" "copyicon"
		Pop $R7
	${EndIf}
	${If} $R7 != "AppPortable.ini"
	${AndIf} $R7 != "spoonportable.ini"
		IntOp $R0 $R0 + 1
	${EndIf}
	Pop $R3
	Pop $R2
	Pop $R1
	Push "continue"
FunctionEnd

Function seticonsexe
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R1
	Push $R2
	Push $R3
	; MessageBox MB_OK "$R7"
	${GetBaseName} "$R9" $R1
	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" 0 NOSETICONS
	ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable
	${If} $R2 == ""
	${OrIfNot} ${FileExists} "$portableapp_dir\App\$R2"
		ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable64
	${EndIf}
	${If} ${FileExists} "$portableapp_dir\App\$R2"
		MoreInfo::GetProductName "$portableapp_dir\App\$R2"
		Pop $R3
		WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" "Launch" "AppName" "$R3"
		ExecWait '"${RHEXE}" -open "$portableapp_dir\App\$R2" -save "$portableapp_dir\App\AppInfo\icons" -action extract -mask ICONGROUP,, -log CON'
	${Else}
		ExecWait '"${RHEXE}" -open "$R9" -save "$portableapp_dir\App\AppInfo\icons" -action extract -mask ICONGROUP,, -log CON'
	${EndIf}
	${If} ${FileExists} "$portableapp_dir\App\AppInfo\icons"
		${Locate} "$portableapp_dir\App\AppInfo\icons" "/L=F /M=*.ico /G=0" "copyicon"
	${EndIf}
	IntOp $R0 $R0 + 1
	NOSETICONS:
	Pop $R3
	Pop $R2
	Pop $R1
	Push "continue"
FunctionEnd

Function setcontrol
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	; MessageBox MB_OK "$R7"
	${GetBaseName} "$R9" $R1
	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" 0 NOCONTROL
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start$R0 $R7
	; IfErrors 0 +2
	; MessageBox MB_OK 'WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start$R0 $R7/error'
	ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable
	${If} $R2 == ""
	${OrIfNot} ${FileExists} "$portableapp_dir\App\$R2"
		ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable64
	${EndIf}
	${If} ${FileExists} "$portableapp_dir\App\$R2"
		MoreInfo::GetProductName "$portableapp_dir\App\$R2"
		Pop $R3
		MoreInfo::GetFileVersion "$portableapp_dir\App\$R2"
		Pop $R4
		${IfNot} $R4 == ""
			${GetFileVersion} "$portableapp_dir\App\$R2" $R4
		${EndIf}
		${If} $R3 == ""
			StrCpy $R3 "$R7" -4
		${EndIf}
		${If} $R4 == ""
			StrCpy $R4 "xx.xx.xx"
		${EndIf}
		WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Name$R0 "$R3_$R4"
		IntOp $R0 $R0 + 1
	${Else}
/* 		MoreInfo::GetProductName "$R9"
		Pop $R3
		MoreInfo::GetFileVersion "$R9"
		Pop $R4
		${IfNot} $R4 == ""
			${GetFileVersion} "$R9" $R4
		${EndIf} */
	${EndIf}

	NOCONTROL:
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Push "continue"
FunctionEnd

Function setdetails
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	${GetBaseName} "$R9" $R1
	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" 0 NODETAILS
	ReadINIStr $0 "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start
	${If} $0 == ""
		WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start $R7
	${EndIf}

	ReadINIStr $R2 "$portableapp_dir\App\AppInfo\appinfo.ini" Details Path
	${If} $R2 != ""
		; MoreInfo::GetFileVersion "$portableapp_dir\App\$R2"
		; Pop $exe_ver
		${GetFileVersion} "$portableapp_dir\App\$R2" $exe_ver
		MoreInfo::GetCompanyName "$portableapp_dir\App\$R2"
		Pop $R3
	${Else}
		ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable
		${If} $R2 == ""
		${OrIfNot} ${FileExists} "$portableapp_dir\App\$R2"
			ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable64
		${EndIf}
		; MoreInfo::GetFileVersion "$portableapp_dir\App\$R2"
		; Pop $exe_ver
		${GetFileVersion} "$portableapp_dir\App\$R2" $exe_ver
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
	Push "StopLocate"
	NODETAILS:
	Push "continue"
FunctionEnd

Function CustomLauncher
	${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\AppPortable.ini" Custom $0 $1
		ReadINIStr $2 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Custom $0
		${If} $2 == ""
			WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Custom $0 $1
		${EndIf}
	${UserNextINIPair}
	${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\AppPortable.ini" CustomCom $0 $1
		ReadINIStr $2 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomCom $0
		${If} $2 == ""
			WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomCom $0 $1
		${EndIf}
	${UserNextINIPair}
	${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\AppPortable.ini" CustomDev1 $0 $1
		ReadINIStr $2 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomDev1 $0
		${If} $2 == ""
			WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomDev1 $0 $1
		${EndIf}
	${UserNextINIPair}
	${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\AppPortable.ini" CustomServ1 $0 $1
		ReadINIStr $2 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomServ1 $0
		${If} $2 == ""
			WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomServ1 $0 $1
		${EndIf}
	${UserNextINIPair}
	${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\AppPortable.ini" CustomDll1 $0 $1
		ReadINIStr $2 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomDll1 $0
		${If} $2 == ""
			WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomDll1 $0 $1
		${EndIf}
	${UserNextINIPair}
FunctionEnd

Function CustomLink
	${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" DirectoriesMove $0 $1
		ReadINIStr $2 "$portableapp_dir\$app_name.ini" DirectoriesMove $0
		${If} $2 == ""
			WriteINIStr "$portableapp_dir\$app_name.ini" DirectoriesLink $0 $1
			WriteINIStr "$portableapp_dir\$app_name.ini" DirectoriesMove $0 $1
			WriteINIStr "$portableapp_dir\$app_name.ini" FilesMove $0 $1
		${EndIf}
	${UserNextINIPair}
	${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" FilesMove $0 $1
		ReadINIStr $2 "$portableapp_dir\$app_name.ini" FilesMove $0
		${If} $2 == ""
			WriteINIStr "$portableapp_dir\$app_name.ini" FilesMove $0 $1
		${EndIf}
	${UserNextINIPair}
FunctionEnd

Function findinisec
	; $R9       current line
	; $R8       current line number
	; $R7       current line negative number
	; $R6       current range of lines
	; $R5       handle of a file opened to read
	; $R4       handle of a file opened to write ($R4="" if "/NUL")

	; you can use any string functions
	; $R0-$R3  are not used (save data in them).
	; ...
	; Push $var      ; If $var="StopLineFind"  Then exit from function
	               ; If $var="SkipWrite"     Then skip current line (ignored if "/NUL")
	${TrimNewLines} "$R9" $R0 
	${If} $R0 == "[DirectoriesLink]"
		StrCpy $inisecflag "true"
		Push "StopLineFind"
	${Else}
		Push "continue"
	${EndIf}
FunctionEnd

Function linknsh
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R0
	Push $R1
	${GetFileExt} "$R7" $R0
	${WordFind} "$R7" "_" "-1" $R1
	${If} $R0 == "nsh"
	${AndIf} $R1 != "special.nsh"
	; ${AndIf} $R7 != "Custom_special.nsh"
		; ExecDos::exec /DISABLEFSR '$SYSDIR\mklink.exe "$portableapp_dir\App\AppInfo\Launcher\$R7" \
		; "$R9"' '' '$EXEDIR\mklink.log'
		IfFileExists "$portableapp_dir\App\AppInfo\Launcher\$R7" 0 +3
		MessageBox MB_YESNO "$(PalMessage3)" IDNO +3
		Delete "$portableapp_dir\App\AppInfo\Launcher\$R7"
		ExecWait '$sybexeused ${SYBSWITCH} "$R9" "$portableapp_dir\App\AppInfo\Launcher\$R7"'
	${Else}
		IfFileExists "$portableapp_dir\App\AppInfo\Launcher\$R7" 0 +2
		MessageBox MB_YESNO "$(PalMessage3)" IDNO +2
		CopyFiles "$R9" "$portableapp_dir\App\AppInfo\Launcher\$R7"
	${EndIf}
	Pop $R1
	Pop $R0
	Push "continue"
FunctionEnd

${SegmentPostPrimary}

	${If} ${RunningX64}
		StrCpy $sybexeused "${SYBEXE64}"
	${Else}
		StrCpy $sybexeused "${SYBEXE}"
	${EndIf}
	ReadINIStr $portableapp_dir "$EXEDIR\Data\settings.ini" Main Package
	${WordReplace} "$portableapp_dir" "/" "\" "+*" $portableapp_dir
	ReadINIStr $app_name "$portableapp_dir\App\AppInfo\appinfo.ini" Details AppID
	; MessageBox MB_OK "portableapp_dir, $portableapp_dir$\r$\napp_name, $app_name"
	IfFileExists "$portableapp_dir\*.exe" EXISTEXE 0
	CreateDirectory "$portableapp_dir\App\DefaultData"
	CreateDirectory "$portableapp_dir\Data"
	CreateDirectory "$portableapp_dir\App\AppInfo\Launcher"
	CopyFiles "$EXEDIR\Data\app-template\App\DefaultData\*.*" "$portableapp_dir\App\DefaultData"
/* 	!define Index 'Line${__LINE__}'
	MessageBox MB_YESNO "$(PalMessage2)" IDYES 0 IDNO ${Index}
	${Locate} "$EXEDIR\Data\app-template\App\AppInfo\Launcher" "/L=F /G=0" "linknsh"
	Goto ${Index}_SKIPCOPY
	${Index}:
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\Launcher\*.*" "$portableapp_dir\App\AppInfo\Launcher"
	${Index}_SKIPCOPY:
	!undef Index */
	EXISTEXE:
	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\Custom.nsh" EXISTNSH 0
	CreateDirectory "$portableapp_dir\App\AppInfo\Launcher"
	!define Index 'Line${__LINE__}'
	MessageBox MB_YESNO "$(PalMessage2)" IDYES 0 IDNO ${Index}
	${Locate} "$EXEDIR\Data\app-template\App\AppInfo\Launcher" "/L=F /G=0" "linknsh"
	Goto ${Index}_SKIPCOPY
	${Index}:
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\Launcher\*.*" "$portableapp_dir\App\AppInfo\Launcher"
	${Index}_SKIPCOPY:
	!undef Index
	EXISTNSH:
	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" +2 0
	CopyFiles "$portableapp_dir\App\AppInfo\Launcher\AppPortable.ini" "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini"
	IfFileExists "$portableapp_dir\App\AppInfo\appicon*.*" +2 0
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\appicon*.*" "$portableapp_dir\App\AppInfo"
	; ReadINIStr $app_display "$portableapp_dir\App\AppInfo\appinfo.ini" Details Name
	; WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Launch AppName $app_display
	StrCpy $R0 1
	; ${Locate} "$portableapp_dir\App\AppInfo\Launcher" "/L=F /M=*Portable.ini /G=0" "seticons"
	${Locate} "$portableapp_dir" "/L=F /M=*Portable.exe /G=0" "seticonsexe"
	StrCpy $R0 1
	${Locate} "$portableapp_dir" "/L=F /M=*Portable.exe /G=0" "setcontrol"
	IntOp $R0 $R0 - 1
	${If} $R0 == 0
		StrCpy $R0 1
	${EndIf}
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Icons $R0

	${Locate} "$portableapp_dir" "/L=F /M=*Portable.exe /G=0" "setdetails"

	ExecShell "open" "$portableapp_dir\App\AppInfo\appinfo.ini"

	ReadINIStr $0 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Launch ProgramExecutable
	${If} $0 == ""
		ReadINIStr $0 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Launch ProgramExecutable64
	${EndIf}
	ClearErrors
	ReadINIStr $1 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Custom Service
	${If} ${Errors}
	${AndIf} $0 != ""
		Call CustomLauncher
		ExecShell "open" "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini"
	${EndIf}
	ClearErrors
	${LineFind} "$portableapp_dir\$app_name.ini" "/NUL" "1:-1 " "findinisec"
	${If} $inisecflag != "true"
		Call CustomLink
		ExecShell "open" "$portableapp_dir\$app_name.ini"
	${EndIf}

!macroend

