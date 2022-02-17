; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "d:\ThinAppPortable\Captures\WebStorm_2019.3.5\%ProgramFilesDir%\JetBrains\WebStorm 2019.3.5\bin"
!define EXENAME "webstorm.exe"
!define USERDIR "d:\Downloads\JetBrains_Keygen"

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
	!define VER "2019.0.0.0"
!endif

!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /noerrors /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME "}\
, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, LegalCopyright={" LEGALCOPYRIGHT "},"
!searchparse /noerrors /file "ProductInfo.ini" "LegalTrademarks={" LEGALTRADEMARKS "}\
, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /noerrors /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION "}\
, SpecialBuild={" SPECIALBUILD "},"

!define APPNAME			"JetBrains Webstorm"			; complete name of program
!define APP				"webstorm"					; short name of program without space and accent  this one is used for the final executable an in the directory structure
!define APPEXE			"webstorm.exe"				; main exe name
!define APPEXE64		"webstorm64.exe"				; main exe 64 bit name
!define APPDIR			"$AppBaseDir"		; main exe relative path
!define APPSWITCH		``							; some default Parameters
!define APPCONFIG		"webstorm.exe.vmoptions"
!define APPCONFIG64		"webstorm64.exe.vmoptions"
!define APPCONFIGENT	"-javaagent:"
!define LICJAR			"JetbrainsIdesCrack_5_3_1_sha1_85f569bd44d787c0.jar"
!define JAVAHOME		"$AppHomeDir\jre32"
!define JAVAHOME64		"$AppHomeDir\jbr"
!define LICDIR			"dvt-license_server\windows"
!define LICEXE			"dvt-jb_licsrv.386.exe"
!define LICEXE64		"dvt-jb_licsrv.amd64.exe"
!define LICSWITCH		`-mode start`
!define APPHOME			"$ProfileDir\system\.home"
!define APPLICFILE		"$ProfileDir\config\WebStorm.key"
!define APPLICID		"$APPDATA\JetBrains\PermanentUserId"
!define APPLICREG		"HKCU\Software\JavaSoft\Prefs\jetbrains"
!define APPLICREGKEY	"licenseserverticket"
!define USERVER "2019.x.x.x"

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
!include "TextFunc.nsh"
!include "Registry.nsh"
!include "ProcFunc.nsh"
!include "WordFunc.nsh"



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
VIAddVersionKey ProductVersion "${PRODUCTVERSION}"
VIAddVersionKey InternalName "${ORIGINALFILENAME}"
VIAddVersionKey LegalTrademarks "${LEGALTRADEMARKS}"
VIAddVersionKey OriginalFilename "${ORIGINALFILENAME}"

; **************************************************************************
; === Other Actions ===
; **************************************************************************

Var LauncherSwitch
Var AppBaseDir
Var AppHomeDir
Var AppExeUsed
Var JavaExeUsed
Var LicFlag
Var ProfileDir


; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"

	${Locate} "$EXEDIR" "/L=D /G=0 /M=WebStorm*" "gethomedir"
	IfFileExists "$AppBaseDir\*.*" SKIPOTHER 0
	ReadRegStr $0 HKLM "SOFTWARE\JetBrains\WebStorm\191.7141.48" ""
	IfFileExists "$0\*.*" 0 SKIPREG
	GetFullPathName $0 "$0\.."
	${Locate} "$0" "/L=D /G=0 /M=WebStorm*" "gethomedir"
	SKIPREG:
	${If} ${FileExists} ${APPHOME}
		${LineRead} "${APPHOME}" "1" $0
		${TrimNewLines} "$0" $0
		; MessageBox MB_OK "$AppHomeDir"
		IfFileExists "$0\*.*" 0 SKIPOTHER
		GetFullPathName $0 "$0\.."
		${Locate} "$0" "/L=D /G=0 /M=WebStorm*" "gethomedir"
	${EndIf}
	SKIPOTHER:
	; MessageBox MB_OK "$AppBaseDir;$AppHomeDir;$ProfileDir"
    SetOverwrite ifnewer
    SetOutPath "$EXEDIR"
    File /nonfatal "${USERDIR}\${LICJAR}"
	; File /nonfatal "${USERDIR}\*.txt"

	${GetParameters} $LauncherSwitch
	${Select} "$LauncherSwitch"
	${Case} "/x86"
		StrCpy $AppExeUsed "$AppBaseDir\${APPEXE}"
        StrCpy $JavaExeUsed "${JAVAHOME}"
	${Case} "/x64"
		StrCpy $AppExeUsed "$AppBaseDir\${APPEXE64}"
        StrCpy $JavaExeUsed "${JAVAHOME64}"
	${Case} "/code"
		StrCpy $LicFlag "code"
		${If} ${RunningX64}
			StrCpy $AppExeUsed "$AppBaseDir\${APPEXE64}"
            StrCpy $JavaExeUsed "${JAVAHOME64}"
		${Else}
			StrCpy $AppExeUsed "$AppBaseDir\${APPEXE}"
            StrCpy $JavaExeUsed "${JAVAHOME}"
		${EndIf}
		Goto RUNAPP
	${Case} "/server"
		StrCpy $LicFlag "server"
		${If} ${RunningX64}
			StrCpy $AppExeUsed "$AppBaseDir\${APPEXE64}"
            StrCpy $JavaExeUsed "${JAVAHOME64}"
		${Else}
			StrCpy $AppExeUsed "$AppBaseDir\${APPEXE}"
            StrCpy $JavaExeUsed "${JAVAHOME}"
		${EndIf}
		Goto RUNAPP
	${CaseElse}
		${If} ${RunningX64}
			StrCpy $AppExeUsed "$AppBaseDir\${APPEXE64}"
            StrCpy $JavaExeUsed "${JAVAHOME64}"
		${Else}
			StrCpy $AppExeUsed "$AppBaseDir\${APPEXE}"
            StrCpy $JavaExeUsed "${JAVAHOME}"
		${EndIf}
	${EndSelect}

	${registry::Open} "${APPLICREG}" "/K=1 /V=1 /S=0 /N='${APPLICREGKEY}'" $0
	${registry::Find} "$0" $1 $2 $3 $4
	${If} $3 != ""
	${AndIf} $4 != ""
		StrCpy $LicFlag "server"
	${EndIf}
	${registry::Close} "$0"
	${registry::Unload}
	; MessageBox MB_OK "$1$\n$2$\n$3$\n$4"

	${If} ${FileExists} ${APPLICFILE}
		${LineSum} "${APPLICFILE}" $0
		StrCpy $1 1
		StrCpy $2 ""
		${Do}
			${IfThen} $1 > $0 ${|} ${ExitDo} ${|}
			${LineRead} "${APPLICFILE}" "$1" $3
			StrCpy $2 "$2$3"
			IntOp $1 $1 + 1
		${LoopWhile} $1 < 5
		; MessageBox MB_OK "$0;$1;$2;$3"
	${EndIf}

	${WordFind} "$2" "url:" "*" $3

	; MessageBox MB_OK "|$2|;$3"
	${If} ${FileExists} ${APPLICFILE}
	${AndIf} $3 < 1
	${AndIf} $LicFlag == ""
		StrCpy $LicFlag "code"
	${EndIf}

	; MessageBox MB_OK "$AppExeUsed;$LicFlag"
	RUNAPP:

	${Select} "$LicFlag"
	${Case} "server"
		${If} ${FileExists} "$AppBaseDir\${APPCONFIG}"
			${ConfigWrite} "$AppBaseDir\${APPCONFIG}" "${APPCONFIGENT}" "" $0
		${EndIf}
		${If} ${FileExists} "$AppBaseDir\${APPCONFIG64}"
			${ConfigWrite} "$AppBaseDir\${APPCONFIG64}" "${APPCONFIGENT}" "" $0
		${EndIf}
/*
		${GetProcessPID} "${LICEXE}" $0
		${GetProcessPID} "${LICEXE64}" $1
		${If} ${RunningX64}
			${If} $0 = 0
			${AndIf} $1 = 0
				ExecDos::exec /ASYNC '"$EXEDIR\${LICDIR}\${LICEXE64}" ${LICSWITCH}' '' ''
			${EndIf}
		${Else}
			${If} $0 = 0
			${AndIf} $1 = 0
				ExecDos::exec /ASYNC '"$EXEDIR\${LICDIR}\${LICEXE}" ${LICSWITCH}' '' ''
			${EndIf}
		${EndIf}
*/
	${Case} "code"
		${If} ${FileExists} "$AppBaseDir\${APPCONFIG}"
		${AndIf} ${FileExists} "$EXEDIR\${LICJAR}"
			${ConfigWrite} "$AppBaseDir\${APPCONFIG}" "${APPCONFIGENT}" "$EXEDIR\${LICJAR}" $0
		${EndIf}
		${If} ${FileExists} "$AppBaseDir\${APPCONFIG64}"
		${AndIf} ${FileExists} "$EXEDIR\${LICJAR}"
			${ConfigWrite} "$AppBaseDir\${APPCONFIG64}" "${APPCONFIGENT}" "$EXEDIR\${LICJAR}" $0
		${EndIf}
	${CaseElse}
		${IfNot} ${FileExists} "$EXEDIR\ACTIVATION_CODE.txt"
			ExecDos::exec '"$JavaExeUsed\bin\java.exe" -jar "$EXEDIR\${LICJAR}" getLic' '' '$EXEDIR\ACTIVATION_CODE.txt'
			ExecShell open "$EXEDIR\ACTIVATION_CODE.txt"
		${EndIf}
		${If} ${FileExists} "$AppBaseDir\${APPCONFIG}"
		${AndIf} ${FileExists} "$EXEDIR\${LICJAR}"
			${ConfigWrite} "$AppBaseDir\${APPCONFIG}" "${APPCONFIGENT}" "$EXEDIR\${LICJAR}" $0
		${EndIf}
		${If} ${FileExists} "$AppBaseDir\${APPCONFIG64}"
		${AndIf} ${FileExists} "$EXEDIR\${LICJAR}"
			${ConfigWrite} "$AppBaseDir\${APPCONFIG64}" "${APPCONFIGENT}" "$EXEDIR\${LICJAR}" $0
		${EndIf}
		${GetProcessPID} "${LICEXE}" $0
		${GetProcessPID} "${LICEXE64}" $1
		${If} ${RunningX64}
			${If} $0 = 0
			${AndIf} $1 = 0
				ExecDos::exec /ASYNC '"$EXEDIR\${LICDIR}\${LICEXE64}"' '' ''
			${EndIf}
		${Else}
			${If} $0 = 0
			${AndIf} $1 = 0
				ExecDos::exec /ASYNC '"$EXEDIR\${LICDIR}\${LICEXE}"' '' ''
			${EndIf}
		${EndIf}
	${EndSelect}
	; MessageBox MB_OK "$0,$1,$AppExeUsed"

	; ${Execute} '"$AppExeUsed"' "$AppBaseDir" $0
	Exec '"$AppExeUsed"'
	; ExecWait '"$AppExeUsed"'
	; ExecDos::exec '"$AppExeUsed"' '' ''

SectionEnd

Function "gethomedir"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $0
	Push $1
	${If} $R6 == ""
		StrCpy $AppHomeDir "$R9"
		StrCpy $AppBaseDir "$AppHomeDir\bin"
		${WordReplace} "$R7" " " "" "+*" $0
		${WordFind} "$0" "." "+2{" $1
		StrCpy $ProfileDir "$PROFILE\.$1"
	${EndIf}
	Pop $1
	Pop $0
	Push "StopLocate"
FunctionEnd