/* $LauncherFile=z:\PortableAppz\ReplaceStudioPortable\App\AppInfo\Launcher\ReplaceStudioPortable.ini
$EXEFILE=ReplaceStudioPortable.exe
$AppID=ReplaceStudioPortable
$BaseName=ReplaceStudioPortable
$EXEDIR=z:\PortableAppz\ReplaceStudioPortable */


${SegmentFile}

Var exerun_flag

${OverrideExecute}

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
	${ReadLauncherConfig} $0 Launch BeforeExeN
	${If} $0 != ""
		ExecDos::exec "$ExecString /XShellEx=@APPDIR@\$0"
		Sleep 1000
	${EndIf}	
	
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
	StrCpy $exerun_flag "true"
	${DebugMsg} "$ExecString has finished."
	
	${ReadLauncherConfig} $0 Launch SpoonDelay
	Sleep $0

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
	
	${ReadLauncherConfig} $0 Launch WaitForExeNProgram
	${IF} $0 == true
		${GetFileName} $ProgramExecutable $1
		${DebugMsg} "Waiting till any other instances of $1 and any [Launch]:WaitForEXE[N] values are finished."
		${EmptyWorkingSet}
		${Do}
			${ProcessWait} $1 1000 $R9
			; MessageBox MB_OK "ProcessWait, $R9"
			; ${ProcessWaitClose} $1 -1 $R9
			; ${IfThen} $R9 > 0 ${|} ${Continue} ${|}
			StrCpy $0 1
			${Do}
				ClearErrors
				${ReadLauncherConfig} $2 Launch WaitForEXE$0
				${IfThen} ${Errors} ${|} ${ExitDo} ${|}
				${ProcessWaitClose} $2 -1 $R9
				${IfThen} $R9 > 0 ${|} ${ExitDo} ${|}
				IntOp $0 $0 + 1
				; MessageBox MB_OK "ProcessWaitClose loop, $0"
			${Loop}
			; MessageBox MB_OK "ProcessWaitClose loopwhile, $0"
		${LoopWhile} $R9 > 0
				
		${IF} $exerun_flag == "true"
			; MessageBox MB_OK "afterexen, $2"
			${ReadLauncherConfig} $0 Launch AfterExeN
			${If} $0 != ""
				ExecDos::exec "$ExecString /XShellEx=@APPDIR@\$0"
			${EndIf}	
		${EndIf}

		${ReadLauncherConfig} $0 Launch CloseEXENProcess
		${IF} $0 == true
			${Do}
				${ProcessWait} $1 1000 $R9
				; MessageBox MB_OK "closeexe, $1, $R9"
				; ${ProcessWaitClose} $1 -1 $R9
				; ${IfThen} $R9 > 0 ${|} ${Continue} ${|}
				StrCpy $0 1
				${Do}
					ClearErrors
					${ReadLauncherConfig} $2 Launch CloseProcessEXE$0
					${IfThen} ${Errors} ${|} ${ExitDo} ${|}
					${TerminateProcess} $2 $R9
					; MessageBox MB_OK "TerminateProcess, $2, $R9"
					${IfThen} $R9 > 0 ${|} ${ExitDo} ${|}
					IntOp $0 $0 + 1
					; MessageBox MB_OK "TerminateProcess loop, $R9, $0"
				${Loop}
				; MessageBox MB_OK "TerminateProcess loopwhile, $R9,$0"
			${LoopWhile} $R9 > 0
		${EndIf}
			
		${GetFileName} $ProgramExecutable $1
		${ProcessWaitClose} $1 3000 $R9
		${IF} $R9 == -1
			MessageBox MB_YESNO "$1 is not exit, TerminateProcess?" IDNO +2 
			${TerminateProcess} $1 $R9
		${EndIf}
			
	${EndIf}

!macroend