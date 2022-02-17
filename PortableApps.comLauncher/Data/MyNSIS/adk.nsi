﻿; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "d:\SnapShot\adk\Files\@PROGRAMFILESX86@\ADK"
!define EXENAME "ADK.exe"
!define USERDIR "d:\SnapShot\adk\Files\@PROGRAMFILESX86@\ADK"

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
	; !define /date VER "%Y.%m.%d.0"
	!define VER "1.0.7.2"
!endif

!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /noerrors /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME "}\
, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, LegalCopyright={" LEGALCOPYRIGHT "},"
!searchparse /noerrors /file "ProductInfo.ini" "LegalTrademarks={" LEGALTRADEMARKS "}\
, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /noerrors /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION "}\
, SpecialBuild={" SPECIALBUILD "},"

!define APPNAME "Android Development Kit"				; complete name of program
!define APP "ADK"					; short name of program without space and accent  this one is used for the final executable an in the directory structure
!define APPEXE "ADK.exe"				; main exe name
!define APPEXE64 "ADK.exe"				; main exe 64 bit name
!define APPDIR "$EXEDIR"				; main exe relative path
!define APPSWITCH 	``
!define LAUNCHERCFG "${APP}launcher.ini"
!define APPPATCH "Patch"
!define USERVER "1.0.7.2"


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
!include "SetEnvironmentVariable.nsh"
; !include "ForEachPath.nsh"
!include "FileFunc.nsh"
!include "ProcFunc.nsh"
!include "WordFunc.nsh"
; !include "Registry.nsh"


; **************************************************************************
; === Set basic information ===
; **************************************************************************
Name "${APP} Launcher"
; OutFile ".\${APP}Launcher${PRODUCTVERSION}.exe"
OutFile ".\${APP}Launcher${USERVER}.exe"
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
Var UpdateDir
Var LocateFlag
LangString Message1 1033 "${APPEXE} is running. Path $ProcFindPath. $\r$\n\
							Please close the program, then run again. "
LangString Message1 2052 "${APPEXE} 正在运行。路径 $ProcFindPath。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message2 1033 "${APPEXE} is running. Some files need to be copied. $\r$\n\
							Please close the program, then run again. "
LangString Message2 2052 "${APPEXE} 正在运行。需要拷贝文件。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message3 1033 "In ${APP}launcher.ini set UpdatePatch=true; $\r$\n\
							Then update $UpdateDir to software. "
LangString Message3 2052 "${APP}launcher.ini 中设置 UpdatePatch=true；$\r$\n\
							将更新 $UpdateDir 到软件。"

; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"

	${EnumProcessPaths} "ProcFind" $ProcFindOutput
	; MessageBox MB_OK "$ProcFindPath"
	!ifdef INFILE
		${If} $ProcFindPath != "${APPDIR}\${APPEXE}"
			SetOverwrite ifdiff
			SetOutPath "$EXEDIR"
			File /nonfatal /r "${USERDIR}\*.*"
		${EndIf}
	!else
		${DirState} "${APPDIR}\${APPPATCH}" $0
		${If} $0 = 1
			${If} $ProcFindPath == "${APPDIR}\${APPEXE}"
				Abort "$(Message2)"
			${Else}
				${Locate} "${APPDIR}\${APPPATCH}" "/L=FD /M=*.* /G=1" "AppPatch"
			${EndIf}
		${EndIf}
	!endif

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
                    ${EnumProcessPaths} "ProcFind" $ProcFindOutput
					${If} $ProcFindPath == "${APPDIR}\${APPEXE}"
						Abort "$(Message2)"
					${Else}
						StrCpy $2 "$1" "" -1
						${If} $2 == "\"
							StrCpy $UpdateDir "$1" -1
						${Else}
							StrCpy $UpdateDir "$1"
						${EndIf}
						${Locate} "$UpdateDir" "/L=FD /M=*.* /G=1" "UpdatePatch"
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}

	${GetParameters} $0
	${If} $0 == ""
		${If} ${RunningX64}
			Exec "${APPDIR}\${APPEXE64}"
		${Else}
			Exec "${APPDIR}\${APPEXE}"
		${EndIf}
		; Exec "${APPDIR}\${APPEXE}"
		; ExecDos::exec /ASYNC '"${APPDIR}\${APPEXE}"' '' ''
		; ${Execute} "${APPDIR}\${APPEXE}" "" $1
		; MessageBox MB_OK "$1"
	${Else}
		${If} ${RunningX64}
			Exec '"${APPDIR}\${APPEXE64}" $0'
		${Else}
			Exec '"${APPDIR}\${APPEXE}" $0'
		${EndIf}
		; Exec '"${APPDIR}\${APPEXE}" $0'
		; ExecDos::exec /ASYNC '"${APPDIR}\${APPEXE}" $0' '' ''
		; ${Execute} '"${APPDIR}\${APPEXE}" $0' '' $1
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
	${Else}
		Push 1
	${EndIf}
FunctionEnd

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
	StrCpy $1 "$0" "" -1
	${If} $1 == "\"
		StrCpy $0 "$0" -1
	${EndIf}
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

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R0
	; Push $R1
	${If} $R6 != ""
		${WordReplace} "$R9" "${APPDIR}\${APPPATCH}" "${APPDIR}" "+" $R0
		; StrLen $R0 "${APPDIR}\${APPPATCH}"
		; StrCpy $R1 "$R9" "" "$R0"
		MessageBox MB_OK "$R9, $R0, $R1"
		; IfFileExists "${APPDIR}$R1" 0 +2
		; Rename "${APPDIR}$R1" "${APPDIR}$R1.bak"
    	; Rename "$R9" "${APPDIR}$R1"
		IfFileExists "$R0" 0 +2
		Rename "$R0" "$R0.bak"
    	Rename "$R9" "$R0"
	${Else}
		${DirState} "$R9" $R0
		; MessageBox MB_OK "$R9, $R0"
		${IfThen} $R0 = 0 ${|} RMDir "$R9" ${|}
	${EndIf}
	; Pop $R1
	Pop $R0

	Push "continue"	; If $var="StopLocate" Then exit from function
FunctionEnd

Function "UpdatePatch"
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
	${If} $R6 != ""
		${WordReplace} "$R9" "$UpdateDir" "${APPDIR}" "+" $R0
		md5dll::GetMD5File "$R0"
		Pop $R1
		md5dll::GetMD5File "$R9"
		Pop $R2
		${If} $R1 != $R2
			MessageBox MB_OK "$(Message3)"
			CopyFiles /SILENT "$UpdateDir\*.*" "${APPDIR}"
		${EndIf}
		StrCpy $LocateFlag "StopLocate"
	${Else}
		StrCpy $LocateFlag "continue"
	${EndIf}
	Pop $R2
	Pop $R1
	Pop $R0

	Push $LocateFlag    ; If $var="StopLocate" Then exit from function
FunctionEnd
