${SegmentFile}

Var forrestart
Var processpid
Var processpath

; LangString WaitMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString WaitMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

Function "setprocesspid"
	; Pop $var1		; matching path string
	; Pop $var2		; matching process PID
	; ...user commands
	; Push [1/0]		; must return 1 on the stack to continue
	; 				; must return some value otherwise corrupt the stack
	; 				; DO NOT save data in $0-$9
	Pop $processpath
	Pop $processpid
	${If} ${Cmd} `StrCmp $processpath $ProgramExecutable`
		Push 1
	${Else}
		StrCpy $processpid "0"
		Push 1
	${EndIf}
FunctionEnd

/* ${Segment.onInit}
	Nop
!macroend */

/* ${SegmentInit}

!macroend */

/* ${SegmentPre}
	Nop
!macroend */

/* ${SegmentPrePrimary}
	Nop
!macroend */

/* ${SegmentPreSecondary}
	Nop
!macroend */

/* ${SegmentPreExec}
	Nop
!macroend */

/* ${SegmentPreExecPrimary}
	Nop
!macroend */

/* ${SegmentPreExecSecondary}
	Nop
!macroend */

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

	GetCurrentAddress $forrestart
	${ProcessWaitClose} "$processpid" "-1" $0

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

	${GetFileName} $ProgramExecutable $1
	${ProcessWait} "$1" "1000" $0
	${If} $0 > 0
		${EnumProcessPaths} "setprocesspid" $2
		IntCmp $processpid 0 +2 +2 0
		Goto $forrestart
	${EndIf}

	!ifdef CUSTOM_DLL
		Call UnRegsvrDll
	!endif

!macroend

/* ${SegmentPostPrimary}
	Nop
!macroend */

/* ${SegmentPostSecondary}
	Nop
!macroend */

/* ${SegmentPost}
	Nop
!macroend */

/* ${SegmentUnload}
	Nop
!macroend */