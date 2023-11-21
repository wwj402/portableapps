; **************************************************************************
; === Define constants ===
; **************************************************************************
!searchreplace /ignorecase "PORTABLEAPPNAME" "${__FILE__}" ".nsi" ""
!searchparse /noerrors /file ".\App\AppInfo\launcher\${PORTABLEAPPNAME}.ini" \
	"ProgramExecutable=" "EXEPATH"
!if ${EXEPATH} == ""
	!undef EXEPATH
	!searchparse /noerrors /file ".\App\AppInfo\launcher\${PORTABLEAPPNAME}.ini" \
		"ProgramExecutable64=" "EXEPATH"
!endif
!if ${EXEPATH} == ""
	!undef EXEPATH
	!define EXEPATH "App\AppName\appname.exe"
!endif

!searchparse /noerrors "${NSIS_VERSION}" "v" "VERSION_NUM" "-"
!echo "${NSIS_VERSION}||${VERSION_NUM}"
; !ifdef NSIS_UNICODE
!if ${VERSION_NUM} < 3
	!define /file_version MAJOR "${EXEPATH}" 0
	!define /file_version MINOR "${EXEPATH}" 1
	!define /file_version OPTION "${EXEPATH}" 2
	!define /file_version BUILD "${EXEPATH}" 3
	!define VER ${MAJOR}.${MINOR}.${OPTION}.${BUILD}
	!undef MAJOR
	!undef MINOR
	!undef OPTION
	!undef BUILD
!else
	; !getdllversion "${EXEPATH}" Expv_
	!getdllversion /noerrors "${EXEPATH}" Expv_
	!define VER "${Expv_1}.${Expv_2}.${Expv_3}.${Expv_4}"
!endif
!echo "${VER}"
!if "${VER}" == "..."
	!undef VER
	!define /date VER "%Y.%m.%d.0"
	; !define VER "22.0.0.0"
!else if "${VER}" == "${Expv_1}.${Expv_2}.${Expv_3}.${Expv_4}"
	!undef VER
	!define /date VER "%Y.%m.%d.0"
	; !define VER "22.0.0.0"
!endif

!execute '"${NSISDIR}\Packhdr\ProductInfo.exe" "${EXEPATH}"'
!searchparse /noerrors /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME "}\
, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, LegalCopyright={" LEGALCOPYRIGHT "},"
!searchparse /noerrors /file "ProductInfo.ini" "LegalTrademarks={" LEGALTRADEMARKS "}\
, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /noerrors /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION "}\
, SpecialBuild={" SPECIALBUILD "},"

!if "${PRODUCTNAME}" != ""
	!searchreplace /ignorecase "APPNAME" " ${PRODUCTNAME}" " " ""
!else
	!define APPNAME "App Name"	; complete name of program
!endif
!if "${ORIGINALFILENAME}" != ""
	!searchreplace /ignorecase "APP" " ${ORIGINALFILENAME}" ".exe" ""
	!searchreplace /ignorecase "APP" " ${ORIGINALFILENAME}" " " ""
!else
	!define APP "appname"		; short name of program without space and accent  
								;this one is used for the final executable an in the directory structure
!endif
!define APPEXE "appname.exe"		; main exe name
!define APPEXE64 "appname64.exe"	; main exe 64 bit name
!define APPDIR "$EXEDIR\App"		; main exe path
!define APPSWITCH ``

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
OutFile ".\${PORTABLEAPPNAME}.exe"
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

; Var Macro_temp1
; Var Macro_temp2

LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\SimpChinese.nlf"
LangString Message1 1033 "${APPEXE} is running. $\r$\n\
							Please close the program, then run again. "
LangString Message1 2052 "${APPEXE} 正在运行。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message2 1033 "${APPEXE} is running. Some files need to be copied. $\r$\n\
							Please close the program, then run again. "
LangString Message2 2052 "${APPEXE} 正在运行。需要拷贝文件。$\r$\n\
							请退出正在运行的程序后，再次运行。"

; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"



SectionEnd