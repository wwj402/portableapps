!ifndef SegmentSpecial
	!define SegmentSpecial ${__FILE__}
!endif
/* !define SPECIAL_INC1 "patch.nsh"
!include "${SPECIAL_INC1}" */

${SegmentFile}

; LangString SpecialMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString SpecialMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

/* ${Segment.onInit}
; !macro ${SegmentSpecial}_.onInit
	nop
!macroend */

${SegmentInit}
; !macro ${SegmentSpecial}_Init
/* 	!define INDEXBASE ${__COUNTER__}

	!define /math INDEX ${__COUNTER__} - ${INDEXBASE}
	!ifdef SPECIAL_INC${INDEX}
		!insertmacro "${SPECIAL_INC${INDEX}}_${__FUNCTION__}"
	!endif
	!undef INDEX

	!undef INDEXBASE */
	nop
!macroend

/* ${SegmentPre}
; !macro ${SegmentSpecial}_Pre
	nop
!macroend */

/* ${SegmentPrePrimary}
; !macro ${SegmentSpecial}_PrePrimary
	nop
!macroend */

/* ${SegmentPreSecondary}
; !macro ${SegmentSpecial}_PreSecondary
	nop
!macroend */

/* ${SegmentPreExec}
; !macro ${SegmentSpecial}_PreExec
	nop
!macroend */

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
/* 	!define INDEXBASE ${__COUNTER__}

	!define /math INDEX ${__COUNTER__} - ${INDEXBASE}
	!ifdef SPECIAL_INC${INDEX}
		!insertmacro "${SPECIAL_INC${INDEX}}_${__FUNCTION__}"
	!endif
	!undef INDEX

	!undef INDEXBASE */
	nop
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