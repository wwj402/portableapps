; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "c:\Qt\Tools\QtCreator\bin"
!define EXENAME "qtcreator.exe"
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
	; !define /date VER "%Y.%m.%d.0"
	!define VER "4.12.4.0"
!endif

!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /noerrors /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME "}\
, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, LegalCopyright={" LEGALCOPYRIGHT "},"
!searchparse /noerrors /file "ProductInfo.ini" "LegalTrademarks={" LEGALTRADEMARKS "}\
, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /noerrors /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION "}\
, SpecialBuild={" SPECIALBUILD "},"

!define APPNAME "Qt Creator"			; complete name of program
!define APP "QtCreator"				; short name of program without space and accent  this one is used for the final executable an in the directory structure
!define APPEXE "QtCreator.exe"			; main exe name
!define APPEXE64 "QtCreator.exe"		; main exe 64 bit name
!define APPDIR "$EXEDIR\Tools\QtCreator\bin"				; main exe relative path
!define APPSWITCH 	``
!define LAUNCHERCFG "${APP}launcher.ini"
!define APPPATCH "Patch"
!define USERVER "4.x.x.x"


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
VIAddVersionKey ProductVersion "${PRODUCTVERSION}"
VIAddVersionKey InternalName "${ORIGINALFILENAME}"
VIAddVersionKey LegalTrademarks "${LEGALTRADEMARKS}"
VIAddVersionKey OriginalFilename "${ORIGINALFILENAME}"

; **************************************************************************
; === Other Actions ===
; **************************************************************************

Var BaseDir
!define SSHAGENT "ssh-agent.exe"
!define SSHADD "ssh-add.exe"
!define SSHPID "SSH_AGENT_PID"
!define SSHAUTH "SSH_AUTH_SOCK"
!define GitBINPATH "d:\APPs\Tools\GitPortable\App\PortableGit64\usr\bin\"
!define GitHOMEPATH "d:\APPs\Tools\GitPortable\Data\Gitwin\"
Var sshagentid
Var temppath
Var sshflag
Var cfgdir
Var useexe

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

	StrCpy $cfgdir "$EXEDIR"
	${If} $cfgdir != ""
		StrCpy $0 "$cfgdir" "" -1
		${If} $0 != "\"
			StrCpy $cfgdir "$cfgdir\"
		${EndIf}
		${If} ${FileExists} "$cfgdir${LAUNCHERCFG}"
            Nop
		${Else}
			WriteINIStr "$cfgdir${LAUNCHERCFG}" "${APP}" "QtCreatorBinPath" "${APPDIR}\${APPEXE}"
			WriteINIStr "$cfgdir${LAUNCHERCFG}" "${APP}" "GitBinPath" "${GitBINPATH}"
			WriteINIStr "$cfgdir${LAUNCHERCFG}" "${APP}" "GitHomePath" "${GitHOMEPATH}"
            WriteINIStr "$cfgdir${LAUNCHERCFG}" "${APP}" "SshKeyToAdd" ""
		${EndIf}
		ReadINIStr $1 "$cfgdir${LAUNCHERCFG}" "${APP}" "GitBinPath"
		${If} $1 != ""
			StrCpy $BaseDir "$cfgdir"
			Push $1
			Call PathParse
			Pop $1
			${If} ${FileExists} "$1\${SSHAGENT}"
				StrCpy $2 "Path"
				ReadEnvStr $3 "$2"
				StrCpy $1 "$1\;$3"
				System::Call 'Kernel32::SetEnvironmentVariable(t r2,t r1) i.r0'
			${EndIf}
		${EndIf}
		ReadINIStr $1 "$cfgdir${LAUNCHERCFG}" "${APP}" "GitHomePath"
		${If} $1 != ""
			StrCpy $BaseDir "$cfgdir"
			Push $1
			Call PathParse
			Pop $1
			${If} ${FileExists} "$1"
				StrCpy $2 "Home"
				System::Call 'Kernel32::SetEnvironmentVariable(t r2,t r1) i.r0'
			${EndIf}
		${EndIf}
	${EndIf}

	${GetProcessPID} "${SSHAGENT}" $sshagentid
	ReadEnvStr $0 "${SSHPID}"
	ReadEnvStr $1 "${SSHAUTH}"
	; MessageBox MB_OK "$sshagentid, $0, $1, $TEMP"
	${If} $sshagentid <= 0
	${AndIf} $1 = ""
		ReadEnvStr $temppath "TEMP"
		${Locate} "$temppath" "/L=D /G=0 /M=ssh-*" "rm_auth_sock"
		StrCpy $temppath "$TEMP"
		${Locate} "$temppath" "/L=D /G=0 /M=ssh-*" "rm_auth_sock"
		GetFunctionAddress $R0 "set_ssh_env"
		ExecDos::exec /TOFUNC "${SSHAGENT}" "" "$R0"
		StrCpy $sshflag "new"
	${ElseIf} $sshagentid > 0
		ReadEnvStr $temppath "TEMP"
		${Locate} "$temppath" "/L=F /G=1 /M=agent.*" "set_auth_sock"
		StrCpy $temppath "$TEMP"
		${Locate} "$temppath" "/L=F /G=1 /M=agent.*" "set_auth_sock"
		StrCpy $sshflag "exist"
	${EndIf}

	ExecDos::exec /TOSTACK '"${SSHADD}" -l' '' ''
	Pop $0
	; MessageBox MB_OK "$0"
	ReadINIStr $1 "$cfgdir${LAUNCHERCFG}" "${APP}" "SshKeyToAdd"
	${If} $0 = 1
	${AndIf} $1 == ""
		ExecWait "${SSHADD}"
	${ElseIf} $0 = 1
		${WordFind} "$1" "::" "#" $R0
		${If} $1 == $R0
			StrCpy $R0 "1"
		${EndIf}
		StrCpy $R1 "1"
		${Do}
			${WordFind} "$1" "::" "+$R1" $2
			StrCpy $BaseDir "$cfgdir"
			Push $2
			call PathParse
			Pop $2
			IntOp $R1 $R1 + 1
			ExecWait '"${SSHADD}" $2'
		${LoopUntil} $R1 > $R0
	${EndIf}


	${GetParameters} $0
	ReadINIStr $1 "$cfgdir${LAUNCHERCFG}" "${APP}" "QtCreatorBinPath"
	${If} $1 != ""
		StrCpy $BaseDir "$cfgdir"
		Push $1
		Call PathParse
		Pop $1
		${If} ${FileExists} "$1"
			StrCpy $useexe "$1"
		${EndIf}
	${Else}
		StrCpy $useexe "${APPDIR}\${APPEXE}"
	${EndIf}
	${If} $0 == ""
		; Exec "${APPDIR}\${APPEXE}"
		; ExecDos::exec /ASYNC "${APPDIR}\${APPEXE}" "" ""
		${Execute} "$useexe" "" $2
		; MessageBox MB_OK "$2"
	${Else}
		; Exec '"${APPDIR}\${APPEXE}" $0'
		; ExecDos::exec /ASYNC '"${APPDIR}\${APPEXE}" $0' '' ''
		${Execute} '"$useexe" $0' '' $2
		; MessageBox MB_OK "$2"
	${EndIf}

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
	StrCpy $1 "$0" "" -1
	${If} $1 == "\"
		StrCpy $0 "$0" -1
	${EndIf}
	Pop $1
	Exch $0
FunctionEnd

Function "rm_auth_sock"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	${If} $R6 = ""
		RMDir /r "$R8"
	${EndIf}
	Push "Continue"
FunctionEnd
Function "set_auth_sock"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	${WordFind} "$R7" "." "-1" $0
	; MessageBox MB_OK "$R7, $0"
	${If} $R7 != $0
		${WordReplace} "$R9" ":" "/" "+" $1
		${WordReplace} "$1" "\" "/" "+" $1
		StrCpy $1 "/$1"
		IntOp $0 $0 + 1
		; MessageBox MB_OK "$1, $0"
		StrCpy $2 "${SSHAUTH}"
		System::Call "Kernel32::SetEnvironmentVariable(t r2,t r1) i.r3"
		StrCpy $2 "${SSHPID}"
		System::Call "Kernel32::SetEnvironmentVariable(t r2,t r0) i.r3"
		Push "StopLocate"
	${Else}
		Push "Continue"
	${EndIf}
FunctionEnd
Function "set_ssh_env"
	Pop $0
	; MessageBox MB_OK "$0"
	${WordFind} "$0" ";" "+1" $1
	${If} $1 != $0
		${WordFind} "$1" "=" "+1" $2
		${WordFind} "$1" "=" "+2" $3
		${If} $2 != $3
			; MessageBox MB_OK "$2, $3"
			System::Call "Kernel32::SetEnvironmentVariable(t r2,t r3) i.r4 ?e"
		${EndIf}
	${EndIf}
FunctionEnd