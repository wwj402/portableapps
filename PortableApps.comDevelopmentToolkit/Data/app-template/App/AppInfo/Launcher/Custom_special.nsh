!ifndef SegmentSpecial
	!define SegmentSpecial ${__FILE__}
!endif
/* !define SPECIAL_INC1 "patch.nsh"
!include "${SPECIAL_INC1}" */

${SegmentFile}

/* LangString SpecialMessage1 1033 "It is possible that the program is exiting.\
		$\r$\nPlease wait for the program to exit completely and then run again."
LangString SpecialMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。" */

; Function .onInit          ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} Core
; 	${RunSegment} Temp
; 	${RunSegment} Language
; 	${RunSegment} OperatingSystem
; 	${RunSegment} RunAsAdmin
; FunctionEnd
/* ${Segment.onInit}
; !macro ${SegmentSpecial}_.onInit
	nop
!macroend */

; Function Init             ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} Core
; 	${RunSegment} PathChecks
; 	${RunSegment} Settings
; 	${RunSegment} DriveLetter
; 	${RunSegment} DirectoryMoving
; 	${RunSegment} Variables
; 	${RunSegment} Language
; 	${RunSegment} Registry
; 	${RunSegment} Java
; 	${RunSegment} RunLocally
; 	${RunSegment} Temp
; 	${RunSegment} InstanceManagement
; 	${RunSegment} SplashScreen
; 	${RunSegment} RefreshShellIcons
; FunctionEnd
/* ${SegmentInit}
; !macro ${SegmentSpecial}_Init
	!define INDEXBASE ${__COUNTER__}

	!define /math INDEX ${__COUNTER__} - ${INDEXBASE}
	!ifmacrodef ${SPECIAL_INC${INDEX}}_${__FUNCTION__}
		!insertmacro "${SPECIAL_INC${INDEX}}_${__FUNCTION__}"
	!endif
	!undef INDEX

	!undef INDEXBASE
	; !ifmacrodef ${SPECIAL_INC1}_${__FUNCTION__}
	; 	!insertmacro "${SPECIAL_INC1}_${__FUNCTION__}"
	; !endif
!macroend */

; Function Pre              ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} RunLocally
; 	${RunSegment} Temp
; 	${RunSegment} Environment
; 	${RunSegment} ExecString
; FunctionEnd
/* ${SegmentPre}
; !macro ${SegmentSpecial}_Pre
	!define INDEXBASE ${__COUNTER__}

	!define /math INDEX ${__COUNTER__} - ${INDEXBASE}
	!ifmacrodef ${SPECIAL_INC${INDEX}}_${__FUNCTION__}
		!insertmacro "${SPECIAL_INC${INDEX}}_${__FUNCTION__}"
	!endif
	!undef INDEX

	!undef INDEXBASE
	; !ifmacrodef ${SPECIAL_INC1}_${__FUNCTION__}
	; 	!insertmacro "${SPECIAL_INC1}_${__FUNCTION__}"
	; !endif
!macroend */

; Function PrePrimary       ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} DriveLetter
; 	${RunSegment} Variables
; 	${RunSegment} DirectoryMoving
; 	${RunSegment} FileWrite
; 	${RunSegment} FilesMove
; 	${RunSegment} DirectoriesMove
; 	;${RunSegment} RegisterDLL
; 	${RunSegment} RegistryKeys
; 	${RunSegment} RegistryValueBackupDelete
; 	${RunSegment} RegistryValueWrite
; 	${RunSegment} Services
; FunctionEnd
/* ${SegmentPrePrimary}
; !macro ${SegmentSpecial}_PrePrimary
	!define INDEXBASE ${__COUNTER__}

	!define /math INDEX ${__COUNTER__} - ${INDEXBASE}
	!ifmacrodef ${SPECIAL_INC${INDEX}}_${__FUNCTION__}
		!insertmacro "${SPECIAL_INC${INDEX}}_${__FUNCTION__}"
	!endif
	!undef INDEX

	!undef INDEXBASE
	; !ifmacrodef ${SPECIAL_INC1}_${__FUNCTION__}
	; 	!insertmacro "${SPECIAL_INC1}_${__FUNCTION__}"
	; !endif
!macroend */

; Function PreSecondary     ;{{{1
; 	${RunSegment} Custom
; 	;${RunSegment} *
; FunctionEnd
/* ${SegmentPreSecondary}
; !macro ${SegmentSpecial}_PreSecondary
	Nop
!macroend */

; Function PreExec          ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} RefreshShellIcons
; 	${RunSegment} WorkingDirectory
; FunctionEnd
/* ${SegmentPreExec}
; !macro ${SegmentSpecial}_PreExec
	!define INDEXBASE ${__COUNTER__}

	!define /math INDEX ${__COUNTER__} - ${INDEXBASE}
	!ifmacrodef ${SPECIAL_INC${INDEX}}_${__FUNCTION__}
		!insertmacro "${SPECIAL_INC${INDEX}}_${__FUNCTION__}"
	!endif
	!undef INDEX

	!undef INDEXBASE
	; !ifmacrodef ${SPECIAL_INC1}_${__FUNCTION__}
	; 	!insertmacro "${SPECIAL_INC1}_${__FUNCTION__}"
	; !endif
!macroend */

; Function PreExecPrimary   ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} Core
; 	${RunSegment} SplashScreen
; FunctionEnd
/* ${SegmentPreExecPrimary}
; !macro ${SegmentSpecial}_PreExecPrimary
	!define INDEXBASE ${__COUNTER__}

	!define /math INDEX ${__COUNTER__} - ${INDEXBASE}
	!ifmacrodef ${SPECIAL_INC${INDEX}}_${__FUNCTION__}
		!insertmacro "${SPECIAL_INC${INDEX}}_${__FUNCTION__}"
	!endif
	!undef INDEX

	!undef INDEXBASE
	; !ifmacrodef ${SPECIAL_INC1}_${__FUNCTION__}
	; 	!insertmacro "${SPECIAL_INC1}_${__FUNCTION__}"
	; !endif
!macroend */

; Function PreExecSecondary ;{{{1
; 	${RunSegment} Custom
; 	;${RunSegment} *
; FunctionEnd
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

; Function PostPrimary      ;{{{1
; 	${RunSegment} Services
; 	${RunSegment} RegistryValueBackupDelete
; 	${RunSegment} RegistryKeys
; 	${RunSegment} RegistryCleanup
; 	;${RunSegment} RegisterDLL
; 	${RunSegment} Qt
; 	${RunSegment} DirectoriesMove
; 	${RunSegment} FilesMove
; 	${RunSegment} DirectoriesCleanup
; 	${RunSegment} RunLocally
; 	${RunSegment} Temp
; 	${RunSegment} Custom
; FunctionEnd
/* ${SegmentPostPrimary}
; !macro ${SegmentSpecial}_PostPrimary
	!define INDEXBASE ${__COUNTER__}

	!define /math INDEX ${__COUNTER__} - ${INDEXBASE}
	!ifmacrodef ${SPECIAL_INC${INDEX}}_${__FUNCTION__}
		!insertmacro "${SPECIAL_INC${INDEX}}_${__FUNCTION__}"
	!endif
	!undef INDEX

	!undef INDEXBASE
	; !ifmacrodef ${SPECIAL_INC1}_${__FUNCTION__}
	; 	!insertmacro "${SPECIAL_INC1}_${__FUNCTION__}"
	; !endif
!macroend */

; Function PostSecondary    ;{{{1
; 	;${RunSegment} *
; 	${RunSegment} Custom
; FunctionEnd
/* ${SegmentPostSecondary}
; !macro ${SegmentSpecial}_PostSecondary
	Nop
!macroend */

; Function Post             ;{{{1
; 	${RunSegment} RefreshShellIcons
; 	${RunSegment} Custom
; FunctionEnd
/* ${SegmentPost}
; !macro ${SegmentSpecial}_Post
	Nop
!macroend */

; Function Unload           ;{{{1
; 	${RunSegment} XML
; 	${RunSegment} Registry
; 	${RunSegment} SplashScreen
; 	${RunSegment} Core
; 	${RunSegment} Custom
; FunctionEnd
/* ${SegmentUnload}
; !macro ${SegmentSpecial}_Unload
	Nop
!macroend */