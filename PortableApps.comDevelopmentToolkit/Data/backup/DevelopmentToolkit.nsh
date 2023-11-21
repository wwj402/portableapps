/* $LauncherFile=z:\PortableAppz\ReplaceStudioPortable\App\AppInfo\Launcher\ReplaceStudioPortable.ini
$EXEFILE=ReplaceStudioPortable.exe
$AppID=ReplaceStudioPortable
$BaseName=ReplaceStudioPortable
$EXEDIR=z:\PortableAppz\ReplaceStudioPortable */

${SegmentFile}

!include "x64.nsh"
!include "UserForEachINIPair.nsh"

!define RESHACKER "$EXEDIR\..\NSISPortable\Data\User_Nsis\Packhdr\ResHacker.exe"
!define RHSWITCH `-open "<exepath>" -save "<icondir>" -action extract -mask ICONGROUP,, -log CON`
!define ANY2ICO "$EXEDIR\..\NSISPortable\Data\User_Nsis\Packhdr\QuickAny2Ico.exe"
!define A2ISWITCH `"-res=<exepath>,0" "-icon=<iconpath>" -formats=16,32,72,128`
; !define NTLINKSMAKER64 "$EXEDIR\..\CommonFiles\NTLinksMaker\NTLinksMaker64.exe"
!define NTLINKSMAKER "$EXEDIR\..\CommonFiles\NTLinksMaker\NTLinksMakerLauncher.exe"
!define NTLMSWITCH `/q /n /b /s "{<src_file>|@<src_list_utf16>}" "<dst_path>"`

Var portableapp_dir
Var app_name
Var app_display
Var exe_ver
Var ini_ver
Var inisecflag
Var linkexe
Var iconexe

LangString PalMessage1 1033 "Version in ini:$ini_ver$\nVersion in exe:$exe_ver$\nReplace?"
LangString PalMessage1 2052 "ini文件中版本:$ini_ver$\nexe文件中版本:$exe_ver$\n是否替换？"
LangString PalMessage2 1033 'create link? \
								$\n "Yes" to create link, "No" to copy directly.'
LangString PalMessage2 2052 "是否创建链接？$\n“是”创建链接，“否”直接复制。"
LangString PalMessage3 1033 'The user code already exists, updated? $\n "Yes" update, "No" skips.'
LangString PalMessage3 2052 "用户代码已存在，是否更新？$\n“是”更新，“否”跳过。"
LangString PalMessage4 1033 '$R7 already exists, is it overwritten? $\n"Yes" override, "No" Skip.'
LangString PalMessage4 2052 "$R7 已存在，是否覆盖？$\n“是”覆盖，“否”跳过。"
LangString PalMessage5 1033 '"Yes" uses QuickAny2Ico to extract the icon, \
												$\"nNo" uses ResHacker to extract the icon.'
LangString PalMessage5 2052 "“是”使用 QuickAny2Ico 提取图标，\
												$\n“否”使用 ResHacker 提取图标。"
LangString PalMessage6 1033 '"Yes" creates a control item for $R7, \
												$\n "No" does not create a control item for $R7.'
LangString PalMessage6 2052 "“是”为 $R7 创建控制项，\
												$\n“否”不为 $R7 创建控制项。"
LangString PalMessage7 1033 'Do you want to use $R3 as the control item name?'
LangString PalMessage7 2052 "是否使用 $R3 作为控制项名字？"
LangString PalMessage8 1033 'Do you want to set the display version number to xxxx.xx.x.x?'
LangString PalMessage8 2052 "是否将显示版本号设置为 xxxx.xx.x.x？"
LangString NOTEXIST_MESSAGE 1033 "$0 does not exist, please check."
LangString NOTEXIST_MESSAGE 2052 "$0 不存在，请检查。"
Function copyicon
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	CopyFiles "$R9" "$portableapp_dir\App\AppInfo\appicon$R0.ico"
	; MessageBox MB_OK "$R9"
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
	${AndIf} ${FileExists} "$portableapp_dir\$R1.exe"
		MoreInfo::GetProductName "$portableapp_dir\App\$R2"
		Pop $R3
		WriteINIStr "$R9" "Launch" "AppName" "$R3"
		!define ICONSKIP "ICON${__LINE__}"
		StrCmp $iconexe "ANY2ICO" 0 ${ICONSKIP}
		IfFileExists "$portableapp_dir\App\AppInfo\icons\*.*" +2 0
		CreateDirectory "$portableapp_dir\App\AppInfo\icons"
		${WordReplace} '${A2ISWITCH}' "<exepath>" "$portableapp_dir\App\$R2" "+" $R3
		${WordReplace} '$R3' "<iconpath>" "$portableapp_dir\App\AppInfo\icons\appicon.ico" "+" $R3
		ExecWait '"${ANY2ICO}" $R3'
		${ICONSKIP}:
		${WordReplace} '${RHSWITCH}' "<exepath>" "$portableapp_dir\App\$R2" "+" $R3
		${WordReplace} '$R3' "<icondir>" "$portableapp_dir\App\AppInfo\icons" "+" $R3
		ExecWait '"${RESHACKER}" $R3'
		!undef ICONSKIP
	${EndIf}
	${If} ${FileExists} "$portableapp_dir\App\AppInfo\icons"
		Push $R7
		${Locate} "$portableapp_dir\App\AppInfo\icons" "/L=F /M=*.ico /G=0" "copyicon"
		Pop $R7
	${EndIf}
	${If} $R7 != "AppPortable.ini"
	${AndIf} $R7 != "spoonportable.ini"
	${AndIf} ${FileExists} "$portableapp_dir\$R1.exe"
		IntOp $R0 $R0 + 1
	${EndIf}
	ClearErrors
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
		!define ICONSKIP "ICON${__LINE__}"
		StrCmp $iconexe "ANY2ICO" 0 ${ICONSKIP}
		IfFileExists "$portableapp_dir\App\AppInfo\icons\*.*" +2 0
		CreateDirectory "$portableapp_dir\App\AppInfo\icons"
		${WordReplace} '${A2ISWITCH}' "<exepath>" "$portableapp_dir\App\$R2" "+" $R3
		${WordReplace} '$R3' "<iconpath>" "$portableapp_dir\App\AppInfo\icons\appicon.ico" "+" $R3
		ExecWait '"${ANY2ICO}" $R3'
		${ICONSKIP}:
		${WordReplace} '${A2ISWITCH}' "<exepath>" "$portableapp_dir\App\$R2" "+" $R3
		${WordReplace} '$R3' "<icondir>" "$portableapp_dir\App\AppInfo\icons" "+" $R3
		ExecWait '"${RESHACKER}" $R3'
		!undef ICONSKIP
	${Else}
		!define ICONSKIP "ICON${__LINE__}"
		StrCmp $iconexe "ANY2ICO" 0 ${ICONSKIP}
		IfFileExists "$portableapp_dir\App\AppInfo\icons\*.*" +2 0
		CreateDirectory "$portableapp_dir\App\AppInfo\icons"
		${WordReplace} '${A2ISWITCH}' "<exepath>" "$R9" "+" $R3
		${WordReplace} '$R3' "<iconpath>" "$portableapp_dir\App\AppInfo\icons\appicon.ico" "+" $R3
		ExecWait '"${ANY2ICO}" $R3'
		${ICONSKIP}:
		${WordReplace} '${RHSWITCH}' "<exepath>" "$R9" "+" $R3
		${WordReplace} '$R3' "<icondir>" "$portableapp_dir\App\AppInfo\icons" "+" $R3
		ExecWait '"${RESHACKER}" $R3'
		!undef ICONSKIP
	${EndIf}
	${If} ${FileExists} "$portableapp_dir\App\AppInfo\icons"
		${Locate} "$portableapp_dir\App\AppInfo\icons" "/L=F /M=*.ico /G=0" "copyicon"
	${EndIf}
	IntOp $R0 $R0 + 1
	NOSETICONS:
	ClearErrors
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
	${WordFind} "$R7" "Portable.exe" "*" $R2
	${If} $R2 != $R7
	${AndIf} ${FileExists} "$portableapp_dir\App\AppInfo\Launcher\$R1.ini"
		ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable
		${If} $R2 == ""
		${OrIfNot} ${FileExists} "$portableapp_dir\App\$R2"
			ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable64
		${EndIf}
		IfFileExists "$portableapp_dir\App\$R2" +3 0
		StrCpy $R2 "$R9"
		MessageBox MB_YESNO "$(PalMessage6)" IDNO NOCONTROL
	${Else}
		StrCpy $R2 "$R9"
		MessageBox MB_YESNO "$(PalMessage6)" IDNO NOCONTROL
	${EndIf}

	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start$R0 $R7
	; IfErrors 0 +2
	; MessageBox MB_OK 'WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start$R0 $R7/error'

	MoreInfo::GetProductName "$portableapp_dir\App\$R2"
	Pop $R3
	MessageBox MB_YESNO "$(PalMessage7)" IDYES +2
	StrCpy $R3 ""
	MoreInfo::GetFileVersion "$portableapp_dir\App\$R2"
	Pop $R4
	${IfNot} $R4 == ""
		${GetFileVersion} "$portableapp_dir\App\$R2" $R4
	${EndIf}
	${If} $R3 == ""
		StrCpy $R3 "$R7" -4
	${EndIf}
	${If} $R4 == ""
		!define /date VER "%Y.%m.%d.0"
		StrCpy $R4 "${VER}"
		!undef VER
	${EndIf}
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Name$R0 "$R3_$R4"

	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" 0 +2
	WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" "Launch" "AppName" "$R3"
	!define ICONSKIP "ICON${__LINE__}"
	IfFileExists "$portableapp_dir\App\AppInfo\icons\*.*" +2 0
	CreateDirectory "$portableapp_dir\App\AppInfo\icons"
	${WordReplace} '$iconexe' "<exepath>" "$portableapp_dir\App\$R2" "+" $R3
	${WordReplace} '$R3' "<iconpath>" "$portableapp_dir\App\AppInfo\icons\appicon.ico" "+" $R3
	${WordReplace} '$R3' "<icondir>" "$portableapp_dir\App\AppInfo\icons" "+" $R3
	ExecWait `$R3`
	!undef ICONSKIP
	${If} ${FileExists} "$portableapp_dir\App\AppInfo\icons"
		${Locate} "$portableapp_dir\App\AppInfo\icons" "/L=F /M=*.ico /G=0" "copyicon"
	${EndIf}

	IntOp $R0 $R0 + 1

	NOCONTROL:
	ClearErrors
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
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	${GetBaseName} "$R9" $R1
	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" 0 NODETAILS
	IntOp $R0 $R0 + 1
	ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable64
	StrCmp $R2 "" 0 +2
	ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch ProgramExecutable
	${If} ${FileExists} "$portableapp_dir\$R2"
		ReadINIStr $R2 "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start
		${If} $R2 == ""
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start $R7
		${Else}
			ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R2.ini" Launch ProgramExecutable64
			StrCmp $R2 "" 0 +2
			ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R2.ini" Launch ProgramExecutable64
			StrCmp $R2 "" 0 +2
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Start $R7
		${EndIf}
	${EndIf}

	ReadINIStr $R2 "$portableapp_dir\App\AppInfo\appinfo.ini" Details Path
	StrCmp $R2 "" 0 +2
	ReadINIStr $R2 "$portableapp_dir\App\AppInfo\Launcher\$R1.ini" Launch name_ver
	${If} $R2 != ""
	${AndIf} ${FileExists} "$R2"
		; MoreInfo::GetFileVersion "$portableapp_dir\App\$R2"
		; Pop $exe_ver
		${GetFileVersion} "$R2" $exe_ver
		MoreInfo::GetCompanyName "$R2"
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

	MessageBox MB_OK "ver=$exe_ver;name=$R3"
	${If} $R3 == ""
		MoreInfo::GetCompanyName "$R9"
		Pop $R3
		${If} $R3 == ""
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details Publisher$R0 ""
		${Else}
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details Publisher$R0 $R3
		${EndIf}
	${Else}
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details Publisher$R0 $R3
	${EndIf}

	${If} $exe_ver != ""
		ReadINIStr $ini_ver "$portableapp_dir\App\AppInfo\appinfo.ini" Version PackageVersion
		${If} $exe_ver != $ini_ver
			MessageBox MB_YESNO "$(PalMessage1)" IDYES 0 IDNO VERNOCHANGE
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Version DisplayVersion $exe_ver
			WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Version PackageVersion $exe_ver
			VERNOCHANGE:
		${EndIf}
	${EndIf}
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details AppID$R0 $R1
	${WordReplace} "$R1" "Portable" " Portable" "+" $R4
/* 	MoreInfo::GetProductName "$R9"
	Pop $R4 */
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Details Name$R0 $R4
	; MessageBox MB_OK "$R7$\n$1$\n$exe_ver"
	NODETAILS:
	ClearErrors
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
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
		${AndIfNot} $0 == "TypeLib"
		${AndIfNot} $0 == "CLSID"
			WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomDll1 $0 $1
		${ElseIf} $0 == "TypeLib"
		${OrIf} $0 == "CLSID"
			WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" CustomDll1 $0 "null"
		${EndIf}
	${UserNextINIPair}
FunctionEnd

Function CustomLink
	${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" DirectoriesMove $0 $1
		ReadINIStr $2 "$portableapp_dir\$app_name.ini" DirectoriesMove $0
		${If} $2 == ""
			WriteINIStr "$portableapp_dir\$app_name.ini" DirectoriesLink $0 $1
			WriteINIStr "$portableapp_dir\$app_name.ini" DirectoriesMove $0 $1
			WriteINIStr "$portableapp_dir\$app_name.ini" FilesMove $0\*.ini $1
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
	Push $R0
	${TrimNewLines} "$R9" $R0 
	${If} $R0 == "[DirectoriesLink]"
		StrCpy $inisecflag "true"
	${Else}
		StrCpy $inisecflag "false"
	${EndIf}
	Pop $R0
	${If} $inisecflag == "true"
		Push "StopLineFind"
	${Else}
		Push "continue"
	${EndIf}
FunctionEnd

Function CustomLinksss
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	${GetBaseName} "$R7" $R0
	${If} ${FileExists} "$portableapp_dir\App\AppInfo\Launcher\$R0.ini"
		${LineFind} "$portableapp_dir\$R0.ini" "/NUL" "1:-1 " "findinisec"
		${If} $inisecflag != "true"
			${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\$R0.ini" DirectoriesMove $R1 $R2
				ReadINIStr $R3 "$portableapp_dir\$R0.ini" DirectoriesMove $R1
				${If} $R3 == ""
					WriteINIStr "$portableapp_dir\$R0.ini" DirectoriesLink $R1 $R2
					WriteINIStr "$portableapp_dir\$R0.ini" DirectoriesMove $R1 $R2
					WriteINIStr "$portableapp_dir\$R0.ini" FilesMove $R1 $R2
				${EndIf}
			${UserNextINIPair}
			${UserForEachINIPair} "$portableapp_dir\App\AppInfo\Launcher\$R0.ini" FilesMove $R1 $R2
				ReadINIStr $R3 "$portableapp_dir\$R0.ini" FilesMove $R1
				${If} $R3 == ""
					WriteINIStr "$portableapp_dir\$R0.ini" FilesMove $R1 $R2
				${EndIf}
			${UserNextINIPair}
			ExecShell "open" "$portableapp_dir\$R0.ini"
		${EndIf}
	${EndIf}
	ClearErrors
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
	Push "continue"
FunctionEnd

Function linkLauncher
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
	${If} $R1 != "special.nsh"
		${If} ${FileExists} "$portableapp_dir\App\AppInfo\Launcher\$R7"
			MessageBox MB_YESNO "$(PalMessage4)" IDNO ${__FUNCTION__}_SKIP
			${If} $R6 == ""
				RMDir /r "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${Else}
				Delete "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${EndIf}
		${EndIf}
		${WordReplace} "$linkexe" "{<src_file>|@<src_list_utf16>}" "$R9" "+" $R1
		${WordReplace} "$R1" "<dst_path>" "$portableapp_dir\App\AppInfo\Launcher\$R7" "+" $R1
		ExecWait `$R1`
	${Else}
		${IfNot} ${FileExists} "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${If} $R6 == ""
				CopyFiles "$R9\*.*" "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${Else}
				CopyFiles "$R9" "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${EndIf}
		${EndIf}
	${EndIf}
	${__FUNCTION__}_SKIP:
	; ClearErrors
	Pop $R1
	Pop $R0
	Push "continue"
FunctionEnd

Function copyLauncher
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
	${If} $R1 != "special.nsh"
		${If} ${FileExists} "$portableapp_dir\App\AppInfo\Launcher\$R7"
			MessageBox MB_YESNO "$(PalMessage4)" IDNO ${__FUNCTION__}_SKIP
			${If} $R6 == ""
				CopyFiles "$R9\*.*" "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${Else}
				CopyFiles "$R9" "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${EndIf}
		${EndIf}
	${Else}
		${IfNot} ${FileExists} "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${If} $R6 == ""
				CopyFiles "$R9\*.*" "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${Else}
				CopyFiles "$R9" "$portableapp_dir\App\AppInfo\Launcher\$R7"
			${EndIf}
		${EndIf}
	${EndIf}
	${__FUNCTION__}_SKIP:
	; ClearErrors
	Pop $R1
	Pop $R0
	Push "continue"
FunctionEnd

Function setoptionalfile
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	IntOp $R0 $R0 + 1
	WriteINIStr "$portableapp_dir\App\AppInfo\installer.ini" "OptionalComponents" "OptionalFile$R0" "$R9"
	Push "continue"
FunctionEnd

${SegmentInit}
	ReadINIStr $0 $EXEDIR\Data\settings.ini Main ResHacker
	StrCmp $0 "" 0 +3
	WriteINIStr "$EXEDIR\Data\settings.ini" "Main" "ResHacker" "${RESHACKER}"
	StrCpy $0 "${RESHACKER}"
	IfFileExists "$0" +2 0
	MessageBox MB_OK "$(NOTEXIST_MESSAGE)"
	ReadINIStr $0 $EXEDIR\Data\settings.ini Main Any2Ico
	StrCmp $0 "" 0 +3
	WriteINIStr "$EXEDIR\Data\settings.ini" "Main" "Any2Ico" "${ANY2ICO}"
	StrCpy $0 "${ANY2ICO}"
	IfFileExists "$0" +2 0
	MessageBox MB_OK "$(NOTEXIST_MESSAGE)"
	ReadINIStr $0 $EXEDIR\Data\settings.ini Main NTLinksMaker
	StrCmp $0 "" 0 +3
	WriteINIStr "$EXEDIR\Data\settings.ini" "Main" "NTLinksMaker" "${NTLINKSMAKER}"
	StrCpy $0 "${NTLINKSMAKER}"
	IfFileExists "$0" +2 0
	MessageBox MB_OK "$(NOTEXIST_MESSAGE)"
	ReadINIStr $0 $EXEDIR\Data\settings.ini Main RHPara
	StrCmp $0 "" 0 +2
	WriteINIStr "$EXEDIR\Data\settings.ini" "Main" "RHPara" `${RHSWITCH}`
	ReadINIStr $0 $EXEDIR\Data\settings.ini Main A2IPara
	StrCmp $0 "" 0 +2
	WriteINIStr "$EXEDIR\Data\settings.ini" "Main" "A2IPara" `${A2ISWITCH}`
	ReadINIStr $0 $EXEDIR\Data\settings.ini Main NTLMPara
	StrCmp $0 "" 0 +2
	WriteINIStr "$EXEDIR\Data\settings.ini" "Main" "NTLMPara" `${NTLMSWITCH}`
!macroend

${SegmentPostPrimary}

/* 	${If} ${RunningX64}
		StrCpy $linkexe "${SYBEXE64}"
	${Else}
		StrCpy $linkexe "${SYBEXE}"
	${EndIf} */
	ReadINIStr $portableapp_dir "$EXEDIR\Data\settings.ini" Main Package
	${WordReplace} "$portableapp_dir" "/" "\" "+*" $portableapp_dir
	ReadINIStr $app_name "$portableapp_dir\App\AppInfo\appinfo.ini" Details AppID
	; MessageBox MB_OK "portableapp_dir, $portableapp_dir$\r$\napp_name, $app_name"
	IfFileExists "$portableapp_dir\$app_name.exe" EXISTEXE 0
	CreateDirectory "$portableapp_dir\App\DefaultData"
	CreateDirectory "$portableapp_dir\Data"
	CreateDirectory "$portableapp_dir\App\AppInfo\Launcher"
	CopyFiles "$EXEDIR\Data\app-template\App\DefaultData\*.*" "$portableapp_dir\App\DefaultData"
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\installer.ini" "$portableapp_dir\App\AppInfo"
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\*.png" "$portableapp_dir\App\AppInfo"
/* 	!define Index 'Line${__LINE__}'
	MessageBox MB_YESNO "$(PalMessage2)" IDYES 0 IDNO ${Index}
	${Locate} "$EXEDIR\Data\app-template\App\AppInfo\Launcher" "/L=FD /G=0" "linkLauncher"
	Goto ${Index}_SKIPCOPY
	${Index}:
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\Launcher\*.*" "$portableapp_dir\App\AppInfo\Launcher"
	${Index}_SKIPCOPY:
	!undef Index */
	EXISTEXE:
	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\Custom.nsh" +3 0
	CreateDirectory "$portableapp_dir\App\AppInfo\Launcher"
	Goto +2
	MessageBox MB_YESNO "$(PalMessage3)" IDNO EXISTNSH
	!define Index 'Line${__LINE__}'
	MessageBox MB_YESNO "$(PalMessage2)" IDYES 0 IDNO ${Index}
	ReadINIStr $0 "$EXEDIR\Data\settings.ini" Main NTLinksMaker
	StrCpy $linkexe "$0"
	ReadINIStr $0 "$EXEDIR\Data\settings.ini" Main NTLMPara
	StrCpy $linkexe `"$linkexe" $0`
	${Locate} "$EXEDIR\Data\app-template\App\AppInfo\Launcher" "/L=FD /G=0" "linkLauncher"
	Goto ${Index}_SKIPCOPY
	${Index}:
	${Locate} "$EXEDIR\Data\app-template\App\AppInfo\Launcher" "/L=FD /G=0" "copyLauncher"
	; CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\Launcher\*.*" "$portableapp_dir\App\AppInfo\Launcher"
	${Index}_SKIPCOPY:
	!undef Index
	EXISTNSH:
	IfFileExists "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" +2 0
	CopyFiles "$portableapp_dir\App\AppInfo\Launcher\AppPortable.ini" \
		"$portableapp_dir\App\AppInfo\Launcher\$app_name.ini"
	IfFileExists "$portableapp_dir\App\AppInfo\appicon*.*" +2 0
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\appicon*.*" "$portableapp_dir\App\AppInfo"
	IfFileExists "$portableapp_dir\App\AppInfo\installer.ini" +2 0
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\installer.ini" "$portableapp_dir\App\AppInfo"
	CopyFiles "$EXEDIR\Data\app-template\App\AppInfo\*.png" "$portableapp_dir\App\AppInfo"
	; ReadINIStr $app_display "$portableapp_dir\App\AppInfo\appinfo.ini" Details Name
	; WriteINIStr "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Launch AppName $app_display
	StrCpy $R0 1
	MessageBox MB_YESNO "$(PalMessage5)" IDNO +6
	ReadINIStr $0 "$EXEDIR\Data\settings.ini" "Main" "Any2Ico"
	StrCpy $iconexe "$0"
	ReadINIStr $0 "$EXEDIR\Data\settings.ini" "Main" "A2IPara"
	StrCpy $iconexe `"$iconexe" $0`
	Goto +5
	ReadINIStr $0 "$EXEDIR\Data\settings.ini" "Main" "ResHacker"
	StrCpy $iconexe "$0"
	ReadINIStr $0 "$EXEDIR\Data\settings.ini" "Main" "RHPara"
	StrCpy $iconexe `"$iconexe" $0`
	; ${Locate} "$portableapp_dir\App\AppInfo\Launcher" "/L=F /M=*Portable.ini /G=0" "seticons"
	; ${Locate} "$portableapp_dir" "/L=F /M=*Portable.exe /G=0" "seticonsexe"
	; RMDir "$portableapp_dir\App\AppInfo\icons"
	StrCpy $R0 1
	${Locate} "$portableapp_dir" "/L=F /M=*.exe /G=0" "setcontrol"
	RMDir "$portableapp_dir\App\AppInfo\icons"
	IntOp $R0 $R0 - 1
	${If} $R0 == 0
		StrCpy $R0 1
	${EndIf}
	WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Control Icons $R0
/* 	IntCmp $R0 1 0 +3 +3
	Rename "$portableapp_dir\App\AppInfo\appicon.ico" "$portableapp_dir\App\AppInfo\appicon0.ico"
	CopyFiles "$portableapp_dir\App\AppInfo\appicon1.ico" "$portableapp_dir\App\AppInfo\appicon.ico" */
	StrCpy $R0 "0"
	${Locate} "$portableapp_dir" "/L=F /M=*Portable.exe /G=0" "setdetails"

	${If} $R0 > 2
		MessageBox MB_YESNO "$(PalMessage8)" IDNO +2
		WriteINIStr "$portableapp_dir\App\AppInfo\appinfo.ini" Version DisplayVersion "xxxx.xx.x.x"
	${EndIf}
	ExecShell "open" "$portableapp_dir\App\AppInfo\appinfo.ini"

	ReadINIStr $0 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Launch ProgramExecutable
	${If} $0 == ""
		ReadINIStr $0 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Launch ProgramExecutable64
	${EndIf}
/* 	ClearErrors
	ReadINIStr $1 "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini" Custom Service
	${If} ${Errors}
	${AndIf} $0 != "" */
	${If} $0 != ""
		Call CustomLauncher
		ExecShell "open" "$portableapp_dir\App\AppInfo\Launcher\$app_name.ini"
	${EndIf}
	ClearErrors
	${Locate} "$portableapp_dir" "/L=F /M=*Portable.exe /G=0" "CustomLinksss"
/* 	${LineFind} "$portableapp_dir\$app_name.ini" "/NUL" "1:-1 " "findinisec"
	${If} $inisecflag != "true"
		Call CustomLink
		ExecShell "open" "$portableapp_dir\$app_name.ini"
	${EndIf} */

	ReadINIStr $0 "$portableapp_dir\App\AppInfo\appinfo.ini" Details Name
	ReadINIStr $1 "$portableapp_dir\App\AppInfo\installer.ini" OptionalComponents MainSectionTitle
	${If} $1 != ""
		${WordReplace} "$1" "AppName Portable" "$0" "+" $1
		StrCmp $0 $1 +2 0
		WriteINIStr "$portableapp_dir\App\AppInfo\installer.ini" OptionalComponents MainSectionTitle $1
	${EndIf}
	StrCpy $R0 0

	${Locate} "$portableapp_dir" "/L=F /M=*Portable.ini /G=0" "setoptionalfile"

!macroend

