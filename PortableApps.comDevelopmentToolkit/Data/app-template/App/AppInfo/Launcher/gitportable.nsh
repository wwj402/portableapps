${SegmentFile}

; LangString GitMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString GitMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

!define SSHAGENT "ssh-agent.exe"
!define SSHADD "ssh-add.exe"
!define SSHPID "SSH_AGENT_PID"
!define SSHAUTH "SSH_AUTH_SOCK"
!define GITDIR "d:\APPs\Tools\GitPortable\App\PortableGit64"
!define GITPATH "${GITDIR}\cmd;${GITDIR}\mingw64\bin;${GITDIR}\usr\bin"
!define GITHOME "${GITDIR}\..\..\data\Gitwin"
Var sshagentid
Var temppath
Var sshflag

!ifmacrondef path_canonicalize
Var strtemp
Var macro_t
!macro path_canonicalize _BASEDIR _PATHSTR
	ExpandEnvStrings ${_PATHSTR} "${_PATHSTR}"
	${GetRoot} "${_PATHSTR}" $macro_t
	${If} $macro_t == ""
		StrCpy ${_PATHSTR} "${_BASEDIR}\${_PATHSTR}"
	${EndIf}
	StrCpy $macro_t "${_PATHSTR}" "" -1
	${If} $macro_t == "\"
		StrCpy ${_PATHSTR} "${_PATHSTR}" -1
	${EndIf}
	; GetFullPathName ${_PATHSTR} "${_PATHSTR}"
!macroend
!endif

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
	Push $0
	Push $1
	Push $2
	Push $3
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
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd
Function "set_ssh_env"
	Exch $0
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
	Pop $0
FunctionEnd

/* ${Segment.onInit}
; !macro ${SegmentSpecial}_.onInit
	Nop
!macroend */

${SegmentInit}
; !macro ${SegmentSpecial}_Init
	ClearErrors
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "GitPortablePath"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "GitPortablePath" "${GITDIR}"
	StrCmp $0 "" 0 +2
	StrCpy $0 "${GITDIR}"
	!insertmacro "path_canonicalize" "$EXEDIR" "$0"
	${If} ${FileExists} "$0"
		${SetEnvironmentVariable} GITDIR "$0"
		ReadEnvStr $1 "Path"
		${WordReplace} "${GITPATH}" "${GITDIR}" "$0" "+*" $2
		${SetEnvironmentVariable} Path "$2;$1"
		${WordReplace} "${GITHOME}" "${GITDIR}" "$0" "+*" $1
		${SetEnvironmentVariable} HOME "$1"
	${EndIf}
!macroend

/* ${SegmentPre}
; !macro ${SegmentSpecial}_Pre
	Nop
!macroend */

/* ${SegmentPrePrimary}
; !macro ${SegmentSpecial}_PrePrimary
	Nop
!macroend */

/* ${SegmentPreSecondary}
; !macro ${SegmentSpecial}_PreSecondary
	Nop
!macroend */

${SegmentPreExec}
; !macro ${SegmentSpecial}_PreExec
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
	${If} $0 = 1
		ExecWait "${SSHADD}"
		; ExecDos::exec /TIMEOUT=3000 '${SSHADD}' 'git@wwj8069303$\r$\n' ''
		; ExecDos::exec /TOSTACK '"${SSHADD}" -l' '' ''
		; Pop $0
		; ${IfThen} $0 = 1 ${|} ExecWait "${SSHADD}" ${|}
	${EndIf}
!macroend

/* ${SegmentPreExecPrimary}
; !macro ${SegmentSpecial}_PreExecPrimary
	Nop
!macroend */

/* ${SegmentPreExecSecondary}
; !macro ${SegmentSpecial}_PreExecSecondary
	Nop
!macroend */

/* ${OverrideExecute}

	${!getdebug}
	!ifdef DEBUG
		${If} $WaitForProgram != false
			${DebugMsg} "About to execute the following string and wait till it's done: $ExecString"
		${Else}
			${DebugMsg} "About to execute the following string and finish: $ExecString"
		${EndIf}
	!endif
	${EmptyWorkingSet}
	ClearErrors
	${ReadLauncherConfig} $0 Launch HideCommandLineWindow
	${If} $0 == true
		; TODO: do this without a plug-in or at least some way it won't wait with secondary
		ExecDos::exec $ExecString
		Pop $0
	${Else}
		${IfNot} ${Errors}
		${AndIf} $0 != false
			${InvalidValueError} [Launch]:HideCommandLineWindow $0
		${EndIf}
		${If} $WaitForProgram != false
			ExecWait $ExecString
		${Else}
			Exec $ExecString
		${EndIf}
	${EndIf}
	${DebugMsg} "$ExecString has finished."

	${If} $WaitForProgram != false
		; Wait till it's done
		ClearErrors
		${ReadLauncherConfig} $0 Launch WaitForOtherInstances
		${If} $0 == true
		${OrIf} ${Errors}
			${GetFileName} $ProgramExecutable $1
			${DebugMsg} "Waiting till any other instances of $1 and any [Launch]:WaitForEXE[N] values are finished."
			${EmptyWorkingSet}
			${Do}
				${ProcessWaitClose} $1 -1 $R9
				${IfThen} $R9 > 0 ${|} ${Continue} ${|}
				StrCpy $0 1
				${Do}
					ClearErrors
					${ReadLauncherConfig} $2 Launch WaitForEXE$0
					${IfThen} ${Errors} ${|} ${ExitDo} ${|}
					${ProcessWaitClose} $2 -1 $R9
					${IfThen} $R9 > 0 ${|} ${ExitDo} ${|}
					IntOp $0 $0 + 1
				${Loop}
			${LoopWhile} $R9 > 0
			${DebugMsg} "All instances are finished."
		${ElseIf} $0 != false
			${InvalidValueError} [Launch]:WaitForOtherInstances $0
		${EndIf}
	${EndIf}

	!ifdef CUSTOM_DLL
		Call UnRegsvrDll
	!endif

!macroend */

${SegmentPostPrimary}
; !macro ${SegmentSpecial}_PostPrimary
	${If} $sshflag == "new"
		ExecDos::exec '"${SSHAGENT}" -k' '' ''
	${EndIf}
!macroend

/* ${SegmentPostSecondary}
; !macro ${SegmentSpecial}_PostSecondary
	Nop
!macroend */

/* ${SegmentPost}
; !macro ${SegmentSpecial}_Post
	Nop
!macroend */

/* ${SegmentUnload}
; !macro ${SegmentSpecial}_Unload
	Nop
!macroend */