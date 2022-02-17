; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "d:\SnapShot\mm2020\Files\@PROGRAMFILES@\MindManager 2020"
!define EXENAME "MindManager.exe"
!define USERDIR "$APPDATA"

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
	; !define VER "9.2.7.21663"
!endif

!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /noerrors /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME "}\
, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, LegalCopyright={" LEGALCOPYRIGHT "},"
!searchparse /noerrors /file "ProductInfo.ini" "LegalTrademarks={" LEGALTRADEMARKS "}\
, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /noerrors /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION "}\
, SpecialBuild={" SPECIALBUILD "},"

!define APPNAME "MindManager"				; complete name of program
!define APP "MindManager"					; short name of program without space and accent  this one is used for the final executable an in the directory structure
!define APPEXE "MindManager.exe"				; main exe name
!define APPEXE64 "MindManager.exe"				; main exe 64 bit name
!define APPDIR "$EXEDIR"				; main exe relative path
!define APPSWITCH 	``
!define LAUNCHERCFG "${APP}launcher.ini"
!define APPPATCH "Patch"
!define USERVER "9.x.x.x"


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
; !include "UserForEachPath.nsh"
!include "FileFunc.nsh"
!include "ProcFunc.nsh"
!include "WordFunc.nsh"
; !include "Registry.nsh"


; **************************************************************************
; === Set basic information ===
; **************************************************************************
Name "${APP} Launcher"
OutFile ".\${APP}Launcher${PRODUCTVERSION}.exe"
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
; VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${PRODUCTVERSION}"
; VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "${ORIGINALFILENAME}"
VIAddVersionKey LegalTrademarks "${LEGALTRADEMARKS}"
VIAddVersionKey OriginalFilename "${ORIGINALFILENAME}"

; **************************************************************************
; === Other Actions ===
; **************************************************************************

Var ProcFindOutput
Var ProcFindPath
Var ProcFindPid
Var BaseDir
; Var Macro_temp1
; Var Macro_temp2
; Var PslSpoonFileName
; Var PslSpoonPid
LangString Message1 1033 "${APPEXE} is running. Path $ProcFindPath. $\r$\n\
							Please close the program, then run again. "
LangString Message1 2052 "${APPEXE} 正在运行。路径 $ProcFindPath。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message2 1033 "${APPEXE} is running. Some files need to be copied. $\r$\n\
							Please close the program, then run again. "
LangString Message2 2052 "${APPEXE} 正在运行。需要拷贝文件。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message3 1033 "${APP}launcher.ini UpdatePatch=true$\r$\n\
							Update $1 to software. "
LangString Message3 2052 "${APP}launcher.ini UpdatePatch=true$\r$\n\
							更新 $1 到软件。"


; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"

	${DirState} "${APPDIR}\${APPPATCH}" $0
	; MessageBox MB_OK "$0"
	${If} $0 == 1
		${EnumProcessPaths} "ProcFind" $ProcFindOutput
		${Locate} "${APPDIR}\${APPPATCH}" "/L=FD /M=*.*" "AppPatch"
	${EndIf}

	StrCpy $BaseDir "$EXEDIR"

	ReadEnvStr $0 VMDIR
	${If} $0 != ""
		StrCpy $1 "$0" "" -1
		${If} $1 != "\"
			StrCpy $0 "$0\"
		${EndIf}
		${If} ${FileExists} "$0${LAUNCHERCFG}"
			Nop
		${Else}
			WriteINIStr "$0${LAUNCHERCFG}" "${APP}" "PatchPath" ""
			WriteINIStr "$0${LAUNCHERCFG}" "${APP}" "UpdatePatch" "false"
		${EndIf}
		ReadINIStr $1 "$0${LAUNCHERCFG}" "${APP}" "UpdatePatch"
		${If} $1 == "true"
			StrCpy $BaseDir "$0"
			ReadINIStr $1 "$0${LAUNCHERCFG}" "${APP}" "PatchPath"
			${If} $1 != ""
				Push $1
				Call PathParse
				Pop $1
				${If} $1 != ""
					MessageBox MB_OK "$(Message3)"
					${EnumProcessPaths} "ProcFind" $ProcFindOutput
					StrCpy $2 "$1" "" -1
					${If} $2 == "\"
						CopyFiles "$1*.*" "${APPDIR}"
					${Else}
						CopyFiles "$1\*.*" "${APPDIR}"
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}


	${GetParameters} $0
	${If} $0 == ""
		; Exec "${APPDIR}\${APPEXE}"
		; ExecDos::exec /ASYNC /TOSTACK '"${APPDIR}\${APPEXE}"' '' ''
		${Execute} "${APPDIR}\${APPEXE}" "" $1
		; MessageBox MB_OK "$1"
	${Else}
		; Exec '"${APPDIR}\${APPEXE}" $0'
		; ExecDos::exec /ASYNC /TOSTACK '"${APPDIR}\${APPEXE}" $0' '' ''
		${Execute} '"${APPDIR}\${APPEXE}" $0' '' $1
		; MessageBox MB_OK "$1"
	${EndIf}

SectionEnd

Function "ProcFind"
	; Pop $var1			; matching path string
	; Pop $var2			; matching process PID
	; ...user commands
	; Push [1/0]		; must return 1 on the stack to continue
	; 					; must return some value or corrupt the stack
	; 					; DO NOT save data in $0-$9
	Pop $ProcFindPath
	Pop $ProcFindPid
	; MessageBox MB_OK "$ProcFindPath; $ProcFindPid"
	${If} $ProcFindPath == "${APPDIR}\${APPEXE}"
		Push 0
		Abort "$(Message1)"
	${EndIf}
	Push 1
FunctionEnd

Function PathParse
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

Function "AppPatch"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; If $var="StopLocate" Then exit from function
	${If} $R6 != ""
		Push $0
		Push $1
		StrLen $0 "${APPDIR}\${APPPATCH}"
		StrCpy $1 "$R9" "" "$0"
		; MessageBox MB_OK "$1"
		Rename "${APPDIR}$1" "${APPDIR}$1.bak"
		StrCpy $1 "$R8" "" "$0"
		ClearErrors
		CopyFiles /SILENT "$R9" "${APPDIR}$1"
		IfErrors +2 0
		Delete "$R9"
		Pop $1
		Pop $0
	${Else}
		Push $0
		${DirState} "$R9" $0
		${If} $0 == 0
			RMDir "$R9"
		${EndIf}
		Pop $0
	${EndIf}
	Push "continue"
FunctionEnd