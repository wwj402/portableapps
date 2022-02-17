; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "C:\Qt\Qt5.12\5.12.5\mingw73_64\bin"
!define EXENAME "linguist.exe"
!define USERDIR "c:\Qt\Qt5.12\5.12.5\Src"
!define TRANSDIR "d:\APPs\Translations\Qt5.12"

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
!if ${VER} == "..."
	!undef VER
	!define VER "5.12.5.0"
!endif


!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME \
				"}, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, "
!searchparse /file "ProductInfo.ini" "LegalCopyright={" LEGALCOPYRIGHT "}, LegalTrademarks={" \
				LEGALTRADEMARKS "}, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION \
				"}, SpecialBuild={" SPECIALBUILD "},"

!undef EXENAME

!define APP "Qt5"
!define LUPDATE "lupdate.exe"
!define LUPDATEPAR '"$0\$1" -ts "$0\$2.ts"'
!define LCONVERT "lconvert.exe"
!define LCONVERTPAR '-target-language zh_CN -locations none -o "$R8\$R2" -i "$R9"'
!define LRELEASE "lrelease.exe"
!define LRELEASEPAR '"$R9" -qm "$R0\translations\$R1.qm"'
!define SYBEXE "NTLinksMaker.exe"
!define SYBEXE64 "NTLinksMaker64.exe"
!define SYBDIR "d:\PortableApps\totalcommanderportable\Data\NTLinksMaker"
!define SYBSWITCH1 "/q /n /b"
!define SYBSWITCH2 "/q /n /b /s"
!define ASSISTANT "qttools\src\assistant\assistant.pro"
!define HELP "qttools\src\assistant\help\help.pro"
!define DESIGNER "qttools\src\designer\designer.pro"
!define LINGUIST "qttools\src\linguist\linguist.pro"
!define QTBASE "qtbase\qtbase.pro"
!define QTCONNECTIVITY "qtconnectivity\qtconnectivity.pro"
!define QTDECLARATIVE "qtdeclarative\qtdeclarative.pro"
!define QTLOCATION "qtlocation\qtlocation.pro"
!define QTMULTIMEDIA "qtmultimedia\qtmultimedia.pro"
!define QTQUICKCONTROLS "qtquickcontrols\qtquickcontrols.pro"
!define QTQUICKCONTROLS2 "qtquickcontrols2\qtquickcontrols2.pro"
!define QTSCRIPT "qtscript\qtscript.pro"
!define QTXMLPATTERNS "qtxmlpatterns\qtxmlpatterns.pro"


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
; !include "ForEachPath.nsh"
!include "FileFunc.nsh"
!include "ProcFunc.nsh"
!include "WordFunc.nsh"
; !include "Registry.nsh"


; **************************************************************************
; === Set basic information ===
; **************************************************************************
Name "${APP} Launcher"
OutFile ".\${APP}Launcher${VER}.exe"
Icon "c:\Qt\Qt5.12\qt5.ico"
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

Var usesymexe

LangString Message1 1033 'Generate resource file? $\r$\n"yes" build; "no" skip. '
LangString Message1 2052 "是否生成资源文件？$\r$\n“是” 生成；“否” 跳过。"
LangString Message2 1033 'Copy resource file to translation directory? $\r$\n"yes" copy; "no" skip. '
LangString Message2 2052 "是否复制资源文件到翻译目录？$\r$\n“是” 复制；“否” 跳过。"
LangString Message3 1033 'Convert resource file?  $\r$\n"yes" convert; "no" skip. '
LangString Message3 2052 "是否转换资源文件？$\r$\n“是” 转换；“否” 跳过。"
LangString Message4 1033 'Release resource file?  $\r$\n"yes" release; "no" skip. '
LangString Message4 2052 "是否发布资源文件？$\r$\n“是” 发布；“否” 跳过。"

; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"

!macro LUPDATE_MACRO _SRCPATH
	${GetParent} "${_SRCPATH}" $0
	${GetFileName} "${_SRCPATH}" $1
	${GetBaseName} "${_SRCPATH}" $2
	MessageBox MB_OK "$0|$1|$2"
	; ${ConfigWrite} "${_SRCPATH}" "TRANSLATIONS = " "$2.ts" $3
	ExecDos::exec /TOSTACK '"${EXEFULLDIR}\${LUPDATE}" ${LUPDATEPAR}' '' ''
!macroend
	MessageBox MB_YESNO "$(Message1)" IDYES 0 IDNO LUPDNO
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${ASSISTANT}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${HELP}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${DESIGNER}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${LINGUIST}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${QTBASE}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${QTCONNECTIVITY}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${QTDECLARATIVE}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${QTLOCATION}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${QTMULTIMEDIA}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${QTQUICKCONTROLS}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${QTQUICKCONTROLS2}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${QTSCRIPT}"
	!insertmacro "LUPDATE_MACRO" "${USERDIR}\${QTXMLPATTERNS}"
	LUPDNO:

	${If} ${RunningX64}
		StrCpy $usesymexe "${SYBDIR}\${SYBEXE64}"
	${Else}
		StrCpy $usesymexe "${SYBDIR}\${SYBEXE}"
	${EndIf}
!macro TRANSCOPY_MACRO _SRCPATH
	${GetParent} "${_SRCPATH}" $0
	${GetFileName} "${_SRCPATH}" $1
	${GetBaseName} "${_SRCPATH}" $2
	${If} ${FileExists} "${TRANSDIR}\$2.ts"
		Delete "${TRANSDIR}\$2.ts"
	${EndIf}
	ExecDos::exec /TOSTACK '"$usesymexe" ${SYBSWITCH2} "$0\$2.ts" "${TRANSDIR}\$2.ts"' '' ''
	Pop $3
	${If} $3 != 0
		ExecDos::exec /TOSTACK '"$usesymexe" ${SYBSWITCH1} "$0\$2.ts" "${TRANSDIR}\$2.ts"' '' ''
		Pop $3
		${If} $3 != 0
			CopyFiles /SILENT "$0\$2.ts" "${TRANSDIR}\$2.ts"
		${EndIf}
	${EndIf}
!macroend
	MessageBox MB_YESNO "$(Message2)" IDYES 0 IDNO COPYNO
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${ASSISTANT}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${HELP}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${DESIGNER}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${LINGUIST}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${QTBASE}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${QTCONNECTIVITY}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${QTDECLARATIVE}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${QTLOCATION}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${QTMULTIMEDIA}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${QTQUICKCONTROLS}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${QTQUICKCONTROLS2}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${QTSCRIPT}"
	!insertmacro "TRANSCOPY_MACRO" "${USERDIR}\${QTXMLPATTERNS}"
	${If} ${FileExists} "${TRANSDIR}\qt_help.ts"
		Delete "${TRANSDIR}\qt_help.ts"
	${EndIf}
	Rename "${TRANSDIR}\help.ts" "${TRANSDIR}\qt_help.ts"
	COPYNO:

	MessageBox MB_YESNO "$(Message3)" IDYES 0 IDNO LCONNO
	${Locate} "${TRANSDIR}" "/M=*_zh-CN.ts /G=0" "LCONV_FUN"
	LCONNO:

	MessageBox MB_YESNO "$(Message4)" IDYES 0 IDNO LRELNO
	${Locate} "${TRANSDIR}" "/M=*_zh_CN.ts /G=0" "LRELE_FUN"
	LRELNO:


SectionEnd

Function "LCONV_FUN"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...
	${WordFind} "$R7" "_" "-1" $R0
	${WordReplace} "$R0" "-" "_" "-1" $R1
	${WordReplace} "$R7" "$R0" "$R1" "-1" $R2
	ExecDos::exec /DETAILED '"${EXEFULLDIR}\${LCONVERT}" ${LCONVERTPAR}' '' ''
	Pop $0

	Push "var"    ; If $var="StopLocate" Then exit from function

FunctionEnd

Function "LRELE_FUN"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...
	${GetParent} "${EXEFULLDIR}" $R0
	${GetBaseName} "$R9" $R1
	ExecDos::exec /DETAILED '"${EXEFULLDIR}\${LRELEASE}" ${LRELEASEPAR}' '' ''
	Pop $0

	Push "var"    ; If $var="StopLocate" Then exit from function

FunctionEnd