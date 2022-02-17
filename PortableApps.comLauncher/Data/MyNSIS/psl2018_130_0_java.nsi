; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "d:\SnapShot\SDL Passolo 2018.130\Files\@PROGRAMFILESX86@\SDL Passolo 2018"
!define EXENAME "psl.exe"
!define USERDIR "$APPDATA\SDL\Passolo 2018"

!ifdef NSIS_UNICODE
	!define /file_version MAJOR "${EXEFULLDIR}\${EXENAME}" 0
	!define /file_version MINOR "${EXEFULLDIR}\${EXENAME}" 1
	!define /file_version OPTION "${EXEFULLDIR}\${EXENAME}" 2
	!define /file_version BUILD "${EXEFULLDIR}\${EXENAME}" 3
	!if ${MAJOR} == 0
		!define VER "18.0.130.0"		; version of launcher
	!else
		!define VER ${MAJOR}.${MINOR}.${OPTION}.${BUILD}
	!endif
	!undef MAJOR
	!undef MINOR
	!undef OPTION
	!undef BUILD
!else
	!echo "${NSIS_VERSION}"
	!getdllversion "${EXEFULLDIR}\${EXENAME}" Expv_
	!define VER "${Expv_1}.${Expv_2}.${Expv_3}.${Expv_4}"
!endif

!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME \
				"}, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, "
!searchparse /file "ProductInfo.ini" "LegalCopyright={" LEGALCOPYRIGHT "}, LegalTrademarks={" \
				LEGALTRADEMARKS "}, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION \
				"}, SpecialBuild={" SPECIALBUILD "},"

!undef EXENAME

!define APPNAME "Passolo_java"				; complete name of program
!define APP "Psl_java"					; short name of program without space and accent  this one is used for the final executable an in the directory structure
!define APPEXE "java.exe"				; main exe name
!define APPEXE64 "java.exe"				; main exe 64 bit name
!define APPDIR "$EXEDIR"				; main exe relative path
!define APPSWITCH 	``
; !define JAVAHOME	"jre"
; !define JAVAHOME64	"jre64"
!define LAUNCHERCFG "Passololauncher.ini"
!define SDLPATCH "Patch"
!define JAVAHOMEREG "SOFTWARE\JavaSoft\Java Runtime Environment"


; **************************************************************************
; === Best Compression ===
; **************************************************************************
!ifndef NSIS_UNICODE
	Unicode true
!endif
Unicode true
SetCompressor /SOLID lzma
SetCompressorDictSize 32

; **************************************************************************
; === Includes ===
; **************************************************************************

!include "LogicLib.nsh"
; !include "x64.nsh"
; !include "SetEnvironmentVariable.nsh"
; !include "ForEachPath.nsh"
!include "FileFunc.nsh"
; !include "ProcFunc.nsh"
!include "WordFunc.nsh"
; !include "Registry.nsh"


; **************************************************************************
; === Set basic information ===
; **************************************************************************
Name "${APP} Launcher"
OutFile ".\${APP}.exe"
Icon ".\Passolo2018.ico"
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

Var BaseDir
Var JavaOs
Var JavaPath
Var Macro_temp1
Var Macro_temp2

LangString Message1 1033 "Argument -os error. $\r$\n\
							The argument is 64 or 32. "
LangString Message1 2052 "参数 -os 错误。$\r$\n\
							参数为 64 或 32。"
LangString Message2 1033 "javahome=$4$\r$\n\
							Yes overwrite, no skip. "
LangString Message2 2052 "javahome=$4$\r$\n\
							“是”重写，“否”跳过。"


; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"

    ${GetParameters} $0
    ${GetOptions} "$0" "-os=" $JavaOs
    ${GetOptions} "$0" "-path=" $JavaPath
	StrCpy $BaseDir "$EXEDIR"
!macro Java_Reg _OS _JAVAPATH
	${If} ${_JAVAPATH} != ""
		Push ${_JAVAPATH}
		Call PathParse
		Pop $Macro_temp1
		${If} $Macro_temp1 != ""
			${If} ${_OS} == 64
				SetRegView 64
                WriteRegStr HKLM "SOFTWARE\Classes\.jar" "" "jarfile"
				WriteRegStr HKLM "${JAVAHOMEREG}" "CurrentVersion" "1.8"
				StrCpy $Macro_temp2 "$Macro_temp1" "" -1
				${If} $Macro_temp2 == "\"
					StrCpy $Macro_temp2 "$Macro_temp1" -1
					WriteRegStr HKLM "SOFTWARE\Classes\jarfile\shell\open\command" "" \
                                                '"$Macro_temp2\javaw.exe" -jar "%1" %*'
					WriteRegStr HKLM "${JAVAHOMEREG}\1.8" "JavaHome" "$Macro_temp2"
					WriteRegStr HKLM "${JAVAHOMEREG}\1.8" "RuntimeLib" "$Macro_temp2\server\jvm.dll"
				${Else}
					StrCpy $Macro_temp2 "$Macro_temp1"
					WriteRegStr HKLM "${JAVAHOMEREG}\1.8" "RuntimeLib" "$Macro_temp2\server\jvm.dll"
				${EndIf}
                ${RefreshShellIcons}
			${ElseIf} ${_OS} == 32
				SetRegView 32
                WriteRegStr HKLM "SOFTWARE\Classes\.jar" "" "jarfile"
				WriteRegStr HKLM "${JAVAHOMEREG}" "CurrentVersion" "1.8"
				StrCpy $Macro_temp2 "$Macro_temp1" "" -1
				${If} $Macro_temp2 == "\"
					StrCpy $Macro_temp2 "$Macro_temp1" -1
            	    WriteRegStr HKLM "SOFTWARE\Classes\jarfile\shell\open\command" "" \
                                                '"$Macro_temp2\javaw.exe" -jar "%1" %*'
					WriteRegStr HKLM "${JAVAHOMEREG}\1.8" "JavaHome" "$Macro_temp2"
					WriteRegStr HKLM "${JAVAHOMEREG}\1.8" "RuntimeLib" \
                                                                        "$Macro_temp2\client\jvm.dll"
				${Else}
					StrCpy $Macro_temp2 "$Macro_temp1"
					WriteRegStr HKLM "${JAVAHOMEREG}\1.8" "RuntimeLib" \
                                                                        "$Macro_temp2\client\jvm.dll"
				${EndIf}
                ${RefreshShellIcons}
			${EndIf}
		${EndIf}
	${EndIf}	
!macroend
	${IfThen} $JavaOs == "64" ${|} SetRegView 64 ${|}
	${IfThen} $JavaOs == "32" ${|} SetRegView 32 ${|} 
	StrCpy $0 0
	KEYLOOP:
		EnumRegKey $1 HKLM "${JAVAHOMEREG}" $0
		StrCmp $1 "" KEYDONE
		MessageBox MB_OK "$1"
		IntOp $0 $0 + 1
		StrCpy $2 0
		VALLOOP:
			ClearErrors
			EnumRegValue $3 HKLM "${JAVAHOMEREG}\$1" $2
			IfErrors VALDONE
			MessageBox MB_OK "$3"
			IntOp $2 $2 + 1
			${If} $3 == "javahome"
				ReadRegStr $4 HKLM "${JAVAHOMEREG}\$1" "$3"
				Goto KEYDONE
			${EndIf}
		Goto VALLOOP
		VALDONE:
	Goto KEYLOOP
	KEYDONE:
	GetFullPathName $4 "$4"
	${If} $4 != ""
		${WordFind} "$JavaPath" "'" "+1" $JavaPath
    	${WordFind} '$JavaPath' '"' '+1' $JavaPath
		StrCpy $5 "$JavaPath" "" -1
		${IfThen} $5 == "\" ${|} StrCpy $5 "$JavaPath" -1 ${|}
		${If} $4 != $5
			MessageBox MB_YESNO "$(message2)" IDYES OVERWRITE IDNO SKIPWRITE
		${Else}
			Goto SKIPWRITE
		${EndIf}
	${EndIf}

    ${WordFind} "$JavaPath" "'" "+1" $JavaPath
    ${WordFind} '$JavaPath' '"' '+1' $JavaPath
	OVERWRITE:
    ${If} $JavaOs == "64"
        !insertmacro "Java_Reg" "$JavaOs" "$JavaPath"
    ${ElseIf} $JavaOs == "32"
        !insertmacro "Java_Reg" "$JavaOs" "$JavaPath"
    ${Else}
        MessageBox MB_OK "$(Message1)"
    ${EndIf}
    SKIPWRITE:

SectionEnd

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