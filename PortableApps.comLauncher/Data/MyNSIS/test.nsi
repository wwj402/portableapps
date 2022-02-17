SetCompressor /SOLID lzma
SetCompressorDictSize 32
Unicode true

Name "Test Launcher"
OutFile ".\TestLauncher.exe"
; Icon ".\${APP}.ico"
SilentInstall silent

!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "Registry.nsh"
!define TESTSTR "..\..\jdk"
Var BaseDir

Section "Main"

MessageBox MB_OK "${TESTSTR}"
${GetRoot} "${TESTSTR}" $0
MessageBox MB_OK "$0,"
IfErrors 0 +2
MessageBox MB_OK "error"
MessageBox MB_OK "$0,"
	StrCpy $BaseDir "$EXEDIR"
!macro Java_Reg _OS _JAVAPATH
	${If} ${_JAVAPATH} != ""
		Push ${_JAVAPATH}
		Call PathParse
		Pop $1
		${If} $1 != ""
			${If} ${_OS} == 64
				SetRegView 64
				${Registry::Write} "HKLM\SOFTWARE\JavaSoft\Java Runtime Environment\test" \
															"JavaHome" "$1" "REG_SZ" $0
				${Registry::Write} "HKLM\SOFTWARE\JavaSoft\Java Runtime Environment" \
															"CurrentVersion" "test" "REG_SZ" $0
				WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\test" "JavaHome" "$1"
				StrCpy $2 "$1" "" -1
				${If} $2 == "\"
					StrCpy $2 "$1" -1
					${Registry::Write} "HKLM\SOFTWARE\JavaSoft\Java Runtime Environment\test" \
												"RuntimeLib" "$2\server\jvm.dll" "REG_SZ" $0
					; WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\1.8" "RuntimeLib" "$2\server\jvm.dll"
				${Else}
					StrCpy $2 "$1"
					${Registry::Write} "HKLM\SOFTWARE\JavaSoft\Java Runtime Environment\test" \
												"RuntimeLib" "$2\server\jvm.dll" "REG_SZ" $0
					; WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\1.8" "RuntimeLib" "$2\server\jvm.dll"
				${EndIf}
			${ElseIf} ${_OS} == 32
				SetRegView 32
				WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\test" "JavaHome" "$1"
				StrCpy $2 "$1" "" -1
				${If} $2 == "\"
					StrCpy $2 "$1" -1
					WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\test" "RuntimeLib" "$2\client\jvm.dll"
				${Else}
					StrCpy $2 "$1"
					WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\test" "RuntimeLib" "$2\client\jvm.dll"
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}	
!macroend

; !insertmacro "Java_Reg" "64" "psl"
ReadEnvStr $1 "Path"
MessageBox MB_OK "$1"
System::Store "r1" "test"
MessageBox MB_OK "$1, ${NSIS_MAX_STRLEN}"
System::Call "Kernel32::GetEnvironmentVariable(t 'Path', t .r0, i ${NSIS_MAX_STRLEN}) i .r1 ?e"
Pop $2
StrLen $3 "$0"
MessageBox MB_OK "$0, ${NSIS_MAX_STRLEN}, $1, $2, $3"

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
    MessageBox MB_OK "$0||$BaseDir"
	Pop $1
	Exch $0
FunctionEnd