; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "d:\ThinAppPortable\Captures\Pinegrow_Web_Editor_5.99\%ProgramFilesDir%\Pinegrow Web Editor"
!define EXENAME "Pinegrow.exe"
!define USERDIR "d:\Downloads\PinegrowWinSetup.5.99\crack-pinegrow"

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
	!define VER "2020.5.9.9"
!endif

!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /noerrors /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME "}\
, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, LegalCopyright={" LEGALCOPYRIGHT "},"
!searchparse /noerrors /file "ProductInfo.ini" "LegalTrademarks={" LEGALTRADEMARKS "}\
, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /noerrors /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION "}\
, SpecialBuild={" SPECIALBUILD "},"

!define APPNAME "Pinegrow Web Editor"				; complete name of program
!define APP "Pinegrow"					; short name of program without space and accent  this one is used for the final executable an in the directory structure
!define APPEXE "Pinegrow.exe"				; main exe name
!define APPEXE64 "Pinegrow.exe"				; main exe 64 bit name
!define APPDIR "$EXEDIR"				; main exe relative path
!define APPSWITCH 	``
!define LAUNCHERCFG "${APP}launcher.ini"
!define APPPATCH "Patch"
!define USERVER "2020.x.x.x"


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
Var usedexe
Var BaseDir
Var UpdateDir
Var checkflag
Var LocateFlag
LangString Message1 1033 "${APPNAME} is running. Path $ProcFindPath. $\r$\n\
							Please close the program, then run again. "
LangString Message1 2052 "${APPNAME} 正在运行。路径 $ProcFindPath。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message2 1033 "${APPNAME} is running. Some files need to be copied. $\r$\n\
							Please close the program, then run again. "
LangString Message2 2052 "${APPNAME} 正在运行。需要拷贝文件。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message3 1033 "In ${APP}launcher.ini set UpdatePatch=true; $\r$\n\
							Then update $UpdateDir to software. "
LangString Message3 2052 "${APP}launcher.ini 中设置 UpdatePatch=true；$\r$\n\
							将更新 $UpdateDir 到软件。"


; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"

	!define /date DATEBAK "%Y.%m.%d.bak"
	${If} ${RunningX64}
		${If} ${FileExists} "${APPDIR}\${APPEXE64}"
			StrCpy $usedexe "${APPDIR}\${APPEXE64}"
		${Else}
			StrCpy $usedexe "${APPDIR}\${APPEXE}"
		${EndIf}
	${Else}
		StrCpy $usedexe "${APPDIR}\${APPEXE}"
	${EndIf}
	${EnumProcessPaths} "ProcFind" $ProcFindOutput
	; MessageBox MB_OK "$ProcFindPath"
	!ifdef INFILE
		${If} $ProcFindPath != "$usedexe"
			SetOverwrite ifnewer
			SetOutPath "$EXEDIR\components"
			File /nonfatal /r "${USERDIR}\components\*.*"
			SetOutPath "$LOCALAPPDATA\Pinegrow"
			File /nonfatal /r "${USERDIR}\Pinegrow\*.*"
		${Else}
			Abort "$(Message2)"
		${EndIf}
	!else
		${DirState} "${APPDIR}\${APPPATCH}\components" $0
		${If} $0 = 1
			${If} $ProcFindPath == "$usedexe"
				Abort "$(Message2)"
			${Else}
				${Locate} "${APPDIR}\${APPPATCH}\components" "/L=FD /M=*.* /G=1" "programpatch"
			${EndIf}
		${EndIf}
		${IfNot} ${FileExists} "${APPDIR}\${APPPATCH}\Pinegrow\patched"
			${Locate} "${APPDIR}\${APPPATCH}\Pinegrow" "/L=FD /M=*.* /G=1" "localapppatch"
			${If} $checkflag == "needpatch"
				CopyFiles /SILENT "${APPDIR}\${APPPATCH}\Pinegrow\*.*" "$LOCALAPPDATA\Pinegrow"
				FileOpen $0 "${APPDIR}\${APPPATCH}\Pinegrow\patched" w
				FileWrite $0 ""
				FileClose $0
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
			WriteINIStr "$0${LAUNCHERCFG}" "${APP}" "UpdatePath" ""
			WriteINIStr "$0${LAUNCHERCFG}" "${APP}" "UpdatePatch" "false"
		${EndIf}
		ReadINIStr $1 "$0${LAUNCHERCFG}" "${APP}" "UpdatePatch"
		${If} $1 == "true"
			StrCpy $BaseDir "$0"
			ReadINIStr $1 "$0${LAUNCHERCFG}" "${APP}" "UpdatePath"
			${If} $1 != ""
				Push $1
				Call PathParse
				Pop $1
				${If} $1 != ""
                    ${EnumProcessPaths} "ProcFind" $ProcFindOutput
					${If} $ProcFindPath == "$usedexe"
						Abort "$(Message2)"
					${Else}
						StrCpy $2 "$1" "" -1
						${If} $2 == "\"
							StrCpy $UpdateDir "$1" -1
						${Else}
							StrCpy $UpdateDir "$1"
						${EndIf}
						${IfNot} ${FileExists} "$UpdateDir\updated"
							${Locate} "$UpdateDir" "/L=FD /M=*.* /G=1" "UpdatePatch"
								${If} $checkflag == "needupdate"
								CopyFiles /SILENT "$UpdateDir\*.*" "${APPDIR}"
								FileOpen $0 "$UpdateDir\updated" w
								FileWrite $0 ""
								FileClose $0
							${EndIf}
						${EndIf}
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}

	${GetParameters} $0
	${If} $0 == ""
		Exec "$usedexe"
		; ExecDos::exec /ASYNC '"$usedexe"' '' ''
		; ${Execute} "$usedexe" "" $1
		; MessageBox MB_OK "$1"
	${Else}
		Exec '"$usedexe" $0'
		; ExecDos::exec /ASYNC '"$usedexe" $0' '' ''
		; ${Execute} '"$usedexe" $0' '' $1
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
	${If} $ProcFindPath == "$usedexe"
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

!macro "AppPatch" "_FUCTIONNAME" "_SOURCE" "_TARGET"
Function "${_FUCTIONNAME}"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function

	${If} $R6 != ""
		Push $0
		Push $1
		Push $2
		Push $3
		${WordReplace} "$R9" "${_SOURCE}" "${_TARGET}" "+" $0
		${If} ${FileExists} "$0"
			${If} ${FileExists} "$0.bak"
				GetFileTime "$0" $2 $3
				IntOp $2 $2 & $3
				Rename "$0" "$0_$2.bak"
			${Else}
				Rename "$0" "$0.bak"
			${EndIf}
			Rename "$R9" "$0"
		${Else}
			Rename "$R9" "$0"
		${EndIf}
		Pop $3
		Pop $2
		Pop $1
		Pop $0
	${Else}
		Push $0
		${DirState} "$R9" $0
		; MessageBox MB_OK "$R9, $R0"
		${IfThen} $0 = 0 ${|} RMDir "$R9" ${|}
		Pop $0
	${EndIf}

	Push "continue"	; If $var="StopLocate" Then exit from function
FunctionEnd
!macroend
!insertmacro "AppPatch" "programpatch" "${APPDIR}\${APPPATCH}" "${APPDIR}"

!macro "checkstatus" "_FUCTIONNAME" "_SOURCE" "_TARGET" "_FLAG"
Function "${_FUCTIONNAME}"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...
	; Push $var    ; If $var="StopLocate" Then exit from function
	${If} $R6 != ""
		Push $0
		Push $1
		Push $2
		Push $3
		${WordReplace} "$R9" "${_SOURCE}" "${_TARGET}" "+" $0
		${If} ${FileExists} "$0"
			md5dll::GetMD5File "$0"
			Pop $1
			md5dll::GetMD5File "$R9"
			Pop $2
			${If} $1 != $2
				StrCpy $checkflag "${_FLAG}"
				StrCpy $LocateFlag "StopLocate"
			${Else}
				StrCpy $LocateFlag "ContinueLocate"
			${EndIf}
		${Else}
			StrCpy $checkflag "${_FLAG}"
			StrCpy $LocateFlag "StopLocate"
		${EndIf}
		Pop $3
		Pop $2
		Pop $1
		Pop $0
	${Else}
		StrCpy $LocateFlag "ContinueLocate"
	${EndIf}

	Push $LocateFlag	; If $var="StopLocate" Then exit from function
FunctionEnd
!macroend
!insertmacro "checkstatus" "localapppatch" "${APPDIR}\${APPPATCH}" "$LOCALAPPDATA" "needpatch"
!insertmacro "checkstatus" "UpdatePatch" "$UpdateDir" "${APPDIR}" "needupdate"