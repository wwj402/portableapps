; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "d:\ThinAppPortable\Captures\SDL_Passolo_2018_18.0.171.0\%ProgramFilesDir%\SDL Passolo 2018"
!define LAUNCHERFULLDIR "d:\ThinAppPortable\Captures\SDL_PassoloLauncher2018_18.x.x.x\%ProgramFilesDir%\SDL Passolo 2018"
!define EXENAME "psl.exe"
!define USERDIR "$APPDATA\SDL\Passolo 2018"

!ifdef NSIS_UNICODE
	!define /file_version MAJOR "${EXEFULLDIR}\${EXENAME}" 0
	!define /file_version MINOR "${EXEFULLDIR}\${EXENAME}" 1
	!define /file_version OPTION "${EXEFULLDIR}\${EXENAME}" 2
	!define /file_version BUILD "${EXEFULLDIR}\${EXENAME}" 3
	!define VER ${MAJOR}.${MINOR}.${OPTION}.${BUILD}
	!undef MAJOR
	!undef MINOR
	!undef OPTION
	!undef BUILD
!else
	!echo "${NSIS_VERSION}"
	!getdllversion "${EXEFULLDIR}\${EXENAME}" Expv_
	!define VER "${Expv_1}.${Expv_2}.${Expv_3}.${Expv_4}"
!endif
!echo "${VER}"
!if ${VER} == "..."
	!undef VER
	!define /date VER "%Y.%m.%d.0"
	; !define VER "18.0.0.0"
!endif

!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /noerrors /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME "}\
, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, LegalCopyright={" LEGALCOPYRIGHT "},"
!searchparse /noerrors /file "ProductInfo.ini" "LegalTrademarks={" LEGALTRADEMARKS "}\
, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /noerrors /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION "}\
, SpecialBuild={" SPECIALBUILD "},"

!define APPNAME "Passolo"				; complete name of program
!define APP "Passolo"					; short name of program without space and accent  this one is used for the final executable an in the directory structure
!define 7zEXE "7z.exe"
!define 7zDIR64 "$PROGRAMFILES64\7-Zip"
!define 7zDIR "$PROGRAMFILES\7-Zip"
!define 7zSWITCH `x -y -r $\"%source$\" -o$\"%output$\"`

!define CNDIR "System_zh-CN"
!define ENDIR "System_en-US"
!define LANGUAGEFILES "system.exe"
!define USERLANGUAGEFILES "user.exe"
!define APPPATCH "Patch"
!define IDFILEDIR "System\DnAndroidParser"
!define IDFILE "DnAndroidParser.dll"
!define USERVER "18.x.x.x"

; **************************************************************************
; === Best Compression ===
; **************************************************************************
!ifndef NSIS_UNICODE
	Unicode true
!endif
SetCompressor /SOLID lzma
SetCompressorDictSize 32

; **************************************************************************
; === Includes ===
; **************************************************************************

!include "LogicLib.nsh"
!include "x64.nsh"
; !include "SetEnvironmentVariable.nsh"
; !include "ForEachPath.nsh"
!include "FileFunc.nsh"
!include "ProcFunc.nsh"
!include "WordFunc.nsh"
; !include "Registry.nsh"


; **************************************************************************
; === Set basic information ===
; **************************************************************************
Name "${APP} Translator"
OutFile ".\${APP}Translator${USERVER}.exe"
Icon ".\${EXENAME}${PRODUCTVERSION}.ico"
SilentInstall silent

; **************************************************************************
; === Set version information ===
; **************************************************************************
Caption "${PRODUCTNAME}"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "${PRODUCTNAME}"
VIAddVersionKey Comments "${COMMENTS}"
VIAddVersionKey CompanyName "${COMPANYNAME}"
VIAddVersionKey LegalCopyright "${LEGALCOPYRIGHT}"
VIAddVersionKey FileDescription "${FILEDESCRIPTION}"
VIAddVersionKey FileVersion "${FILEVERSION}"
VIAddVersionKey ProductVersion "${PRODUCTVERSION}"
VIAddVersionKey InternalName "${ORIGINALFILENAME}"
VIAddVersionKey LegalTrademarks "${LEGALTRADEMARKS}"
VIAddVersionKey OriginalFilename "${ORIGINALFILENAME}"

; **************************************************************************
; === Other Actions ===
; **************************************************************************

Var dirref
Var appbasedir
Var urltemp
Var scripttemp
Var BaseDir
Var getver

LangString Message1 1033 "Whether to move to $0. $\r$\n\
							'Yes' moves, 'No' does not move."
LangString Message1 2052 "是否移动到 $0。$\r$\n\
							“是”移动，“否”不移动。"


; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"
	; Goto NoMove
	GetDLLVersion "${LAUNCHERFULLDIR}\${ENDIR}\${IDFILEDIR}\${IDFILE}" $R0 $R1
	IntOp $R2 $R0 / 0x00010000
	IntOp $R3 $R0 & 0x0000FFFF
	IntOp $R4 $R1 / 0x00010000
	IntOp $R5 $R1 & 0x0000FFFF
	StrCpy $getver "$R2.$R3.$R4.$R5"
	IfFileExists "$EXEDIR\$EXEFILE.ini" +3 0
	WriteINIStr "$EXEDIR\$EXEFILE.ini" "$EXEFILE" "pslsource" "${EXEFULLDIR}"
	WriteINIStr "$EXEDIR\$EXEFILE.ini" "$EXEFILE" "launcherdir" "${LAUNCHERFULLDIR}"
	ReadINIStr $0 "$EXEDIR\$EXEFILE.ini" "$EXEFILE" "pslsource"
	${If} ${FileExists} "$0"
		StrCpy $appbasedir "$0"
	${ElseIf} ${FileExists} "${EXEFULLDIR}"
		StrCpy $appbasedir "${EXEFULLDIR}"
	${Else}
		StrCpy $appbasedir "$EXEDIR"
	${EndIf}
	StrCpy $dirref "$appbasedir\${CNDIR}"
	StrCpy $BaseDir "$appbasedir"
	${Locate} "$dirref" "/L=F /G=1" "copyenfiles"
	${Locate} "$dirref" "/L=F /M=*.???chs /G=1" "renamechs"
	${Locate} "$appbasedir" "/L=F /M=*.log.htm /G=1" "deletelog"
	ReadINIStr $0 "$EXEDIR\$EXEFILE.ini" "$EXEFILE" "launcherdir"
	MessageBox MB_YESNO "$(Message1)" IDYES 0 IDNO NoMove
	${If} ${FileExists} "$0"
		IfFileExists "$appbasedir\${ENDIR}\*.*" 0 +4
		IfFileExists "$0\${ENDIR}\*.*" 0 +2
		Rename "$0\${ENDIR}" "$0\${ENDIR}_$getver"
		Rename "$appbasedir\${ENDIR}" "$0\${ENDIR}"
		IfFileExists "$appbasedir\${CNDIR}\*.*" 0 +4
		IfFileExists "$0\${CNDIR}\*.*" 0 +2
		Rename "$0\${CNDIR}" "$0\${CNDIR}_$getver"
		Rename "$appbasedir\${CNDIR}" "$0\${CNDIR}"
		IfFileExists "$appbasedir\zh-CN\*.*" 0 +4
		IfFileExists "$0\zh-CN\*.*" 0 +2
		Rename "$0\zh-CN" "$0\zh-CN_$getver"
		Rename "$appbasedir\zh-CN" "$0\zh-CN"
		IfFileExists "$appbasedir\en-US\psl.loc" 0 +4
		IfFileExists "$0\en-US\psl.loc" 0 +2
		Rename "$0\en-US\psl.loc" "$0\en-US\psl.loc_$getver"
		Rename "$appbasedir\en-US\psl.loc" "$0\en-US\psl.loc"
		IfFileExists "$appbasedir\en-US\PAIXML.loc" 0 +4
		IfFileExists "$0\en-US\PAIXML.loc" 0 +2
		Rename "$0\en-US\PAIXML.loc" "$0\en-US\PAIXML.loc_$getver"
		Rename "$appbasedir\en-US\PAIXML.loc" "$0\en-US\PAIXML.loc"
		MessageBox MB_OK "$appbasedir\System\WinWrapBasic\ww10@chs.dll" 
		IfFileExists "$appbasedir\System\WinWrapBasic\ww10@chs.dll" 0 +4
		IfFileExists "$0\System\WinWrapBasic\ww10@chs.dll" 0 +2
		Rename "$0\System\WinWrapBasic\ww10@chs.dll" "$0\System\WinWrapBasic\ww10@chs.dll_$getver"
		Rename "$appbasedir\System\WinWrapBasic\ww10@chs.dll" "$0\System\WinWrapBasic\ww10@chs.dll"
		IfFileExists "$0\${APPPATCH}\${EXENAME}" 0 +2
		Rename "$0\${APPPATCH}\${EXENAME}" "$0\${APPPATCH}\${EXENAME}_$getver"
		IfFileExists "$0\PassoloLauncher18.x.x.x.exe" 0 +2
		Rename "$0\PassoloLauncher18.x.x.x.exe" "$0\PassoloLauncher18.x.x.x.exe_$getver"
		CopyFiles /SILENT "$0\${ENDIR}_$getver\Macros\*.*" "$0\${ENDIR}\Macros"
		CopyFiles /SILENT "$0\${ENDIR}_$getver\MacroTemplates\*.*" "$0\${ENDIR}\MacroTemplates"
		; CopyFiles /SILENT "$0\${ENDIR}\${IDFILEDIR}\${IDFILE}" "$0\${ENDIR}\${IDFILE}"
		CopyFiles /SILENT "$0\${CNDIR}_$getver\Macros\*.*" "$0\${CNDIR}\Macros"
		CopyFiles /SILENT "$0\${CNDIR}_$getver\MacroTemplates\*.*" "$0\${CNDIR}\MacroTemplates"
		; CopyFiles /SILENT "$0\${CNDIR}\${IDFILEDIR}\${IDFILE}" "$0\${CNDIR}\${IDFILE}"
	${EndIf}
	NoMove:
	StrCpy $scripttemp "$EXEDIR\pslscript\Macros"
	StrCpy $urltemp "http://jp.wanfutrade.com/download/PslAccessKey.rar"
	${WordFind} "$urltemp" "/" "-1" $0
	StrCpy $0 "$EXEDIR\$0"
	IfFileExists "$0" SKIP1 0
	Inetc::get /CONNECTTIMEOUT 30 "$urltemp" "$0"
	Pop $1
	StrCmp $1 "OK" 0 SKIP1
	StrCpy $2 "${7zSWITCH}"
	${WordReplace} "$2" "%source" "$0" "+" $2
	${WordReplace} "$2" "%output" "$scripttemp" "+" $2
	ExecWait '"${7zDIR64}\${7zEXE}" $2'
	SKIP1:
	StrCpy $urltemp "http://jp.wanfutrade.com/download/PSLWebTrans.rar"
	${WordFind} "$urltemp" "/" "-1" $0
	StrCpy $0 "$EXEDIR\$0"
	IfFileExists "$0" SKIP2 0
	Inetc::get /CONNECTTIMEOUT 30 "$urltemp" "$0"
	Pop $1
	StrCmp $1 "OK" 0 SKIP2
	StrCpy $2 "${7zSWITCH}"
	${WordReplace} "$2" "%source" "$0" "+" $2
	${WordReplace} "$2" "%output" "$scripttemp" "+" $2
	ExecWait '"${7zDIR64}\${7zEXE}" $2'
	SKIP2:
	StrCpy $urltemp "http://jp.wanfutrade.com/download/PSLGbk2Big5_Modified_wanfu.rar"
	${WordFind} "$urltemp" "/" "-1" $0
	StrCpy $0 "$EXEDIR\$0"
	IfFileExists "$0" SKIP3 0
	Inetc::get /CONNECTTIMEOUT 30 "$urltemp" "$0"
	Pop $1
	StrCmp $1 "OK" 0 SKIP3
	StrCpy $2 "${7zSWITCH}"
	${WordReplace} "$2" "%source" "$0" "+" $2
	${WordReplace} "$2" "%output" "$scripttemp" "+" $2
	ExecWait '"${7zDIR64}\${7zEXE}" $2'
	SKIP3:
	StrCpy $urltemp "http://jp.wanfutrade.com/download/CovertINIFile.rar"
	${WordFind} "$urltemp" "/" "-1" $0
	StrCpy $0 "$EXEDIR\$0"
	IfFileExists "$0" SKIP4 0
	Inetc::get /CONNECTTIMEOUT 30 "$urltemp" "$0"
	Pop $1
	StrCmp $1 "OK" 0 SKIP4
	StrCpy $2 "${7zSWITCH}"
	${WordReplace} "$2" "%source" "$0" "+" $2
	${WordReplace} "$2" "%output" "$scripttemp" "+" $2
	ExecWait '"${7zDIR64}\${7zEXE}" $2'
	SKIP4:
	StrCpy $urltemp "http://jp.wanfutrade.com/download/PSLHardCodedString.rar"
	${WordFind} "$urltemp" "/" "-1" $0
	StrCpy $0 "$EXEDIR\$0"
	IfFileExists "$0" SKIP5 0
	Inetc::get /CONNECTTIMEOUT 30 "$urltemp" "$0"
	Pop $1
	StrCmp $1 "OK" 0 SKIP5
	StrCpy $2 "${7zSWITCH}"
	${WordReplace} "$2" "%source" "$0" "+" $2
	${WordReplace} "$2" "%output" "$scripttemp" "+" $2
	ExecWait '"${7zDIR64}\${7zEXE}" $2'
	SKIP5:
	${Locate} "$scripttemp" "/L=F /M=*.txt /G=0" "movehelp"
	${Locate} "$scripttemp" "/L=F /M=*.rar /G=0" "convertz"
	ReadINIStr $0 "$EXEDIR\$EXEFILE.ini" "$EXEFILE" "launcherdir"
	${GetFileName} "$scripttemp" $1
	CopyFiles /SILENT "$scripttemp\*.*" "$0\$1"
	${GetParent} "$scripttemp" $1
	${GetParent} "$0" $2
	CopyFiles /SILENT "$1\ConvertZ\*.*" "$2\ConvertZ"
SectionEnd

Function "PathParse"
	Exch $0
	Push $1
	ExpandEnvStrings $0 "$0"
	${GetRoot} "$0" $1
	${if} $1 == ""
		StrCpy $1 "$BaseDir" "" -1
		${If} $1 == "\"
			StrCpy $0 "$BaseDir$0"
		${Else}
			StrCpy $0 "$BaseDir\$0"
		${EndIf}
	${EndIf}
	GetFullPathName $0 "$0"
	Pop $1
	Exch $0
FunctionEnd
Function "copyenfiles"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; If $var="StopLocate" Then exit from function
	${If} $R6 != ""
		${WordReplace} "$R9" "$dirref" "$appbasedir\${ENDIR}" "+" $0
		${WordReplace} "$R9" "$dirref" "$appbasedir" "+" $1
		; MessageBox MB_OK "$1$\n$0"
		IfFileExists "$1" 0 +2
		CopyFiles /SILENT "$1" "$0"
	${EndIf}
	Push "continue"
FunctionEnd
Function "deletelog"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; If $var="StopLocate" Then exit from function
	${If} $R6 != ""
		Delete "$R9"
	${EndIf}
	Push "continue"
FunctionEnd
Function "movehelp"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; If $var="StopLocate" Then exit from function
	${If} $R6 != ""
		IfFileExists "$R8\Doc\*.*" +2 0
		CreateDirectory "$R8\Doc"
		${If} ${FileExists} "$R8\Doc\$R7"
			CopyFiles "$R9" "$R8\Doc\$R7"
			Delete "$R9"
		${Else}
			Rename "$R9" "$R8\Doc\$R7"
		${EndIf}
	${EndIf}
	Push "continue"
FunctionEnd
Function "convertz"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; If $var="StopLocate" Then exit from function
	${If} $R6 != ""
		Push $1
		Push $2
		${GetParent} "$scripttemp" $1
		StrCpy $2 "${7zSWITCH}"
		${WordReplace} "$2" "%source" "$R9" "+" $2
		${WordReplace} "$2" "%output" "$1\ConvertZ" "+" $2
		ExecWait '"${7zDIR64}\${7zEXE}" $2'
		Pop $2
		Pop $1
	${EndIf}
	Push "continue"
FunctionEnd
Function "renamechs"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; If $var="StopLocate" Then exit from function
	${If} $R6 != ""
		StrCpy $0 "$R9" -3
		IfFileExists "$0" 0 +2
		Delete "$0"
		Rename "$R9" "$0"
	${EndIf}
	Push "continue"
FunctionEnd