${SegmentFile}

; patch
!define PATCHHOST "$EXEDIR\Data\Host"
!define SYSTEMHOST "$SYSDIR\drivers\etc\hosts"
!define ATTRIBUTES "ARCHIVE|HIDDEN|OFFLINE|READONLY|SYSTEM|TEMPORARY"
Var hostdata
Var hostattributes
; patch
; LangString HostMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString HostMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"
; patch

/* ${Segment.onInit}
	nop
!macroend */

${SegmentInit}
; patch
	ClearErrors
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "HostPath"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HostPath" ""
	ClearErrors
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "PatchHost"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchHost" ""
	${If} $0 == true
		CopyFiles "${SYSTEMHOST}" "${SYSTEMHOST}.$BaseName"
		${GetFileAttributes} "${SYSTEMHOST}" "ALL" $hostattributes
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HostAttributes" "$hostattributes"
		${If} $hostattributes != "NORMAL"
			SetFileAttributes "${SYSTEMHOST}" NORMAL
		${EndIf}
		ClearErrors
		ReadINIStr $0 "$EXEDIR\$BaseName.ini" "Host" "1"
		${IfNot} ${Errors}
			StrCpy $R0 "1"
			${Do}
				ClearErrors
				ReadINIStr $hostdata "$EXEDIR\$BaseName.ini" "Host" "$R0"
				${IfThen} ${Errors} ${|} ${ExitDo} ${|}
				${If} $hostdata != ""
					${WordFind} "$hostdata" "." "#" $0
					${If} $0 != $hostdata
						${WordFind} "$hostdata" "+$0*}" "#" $1
						${WordFind} "$hostdata" "+$0{{" "#" $2
						${ConfigWrite} "${SYSTEMHOST}" "$2" "$1" $3
					${EndIf}
				${EndIf}
				IntOp $R0 $R0 + 1
			${Loop}
		${Else}
			ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "HostPath"
			${If} $0 == ""
				StrCpy $0 "${PATCHHOST}"
			${EndIf}
			ExpandEnvStrings $0 "$0"
			${GetRoot} "$0" $1
			${If} $1 == ""
				StrCpy $0 "$EXEDIR\Data\$0"
			${EndIf}
			${LineSum} "$0" $1
			StrCpy $R0 "1"
			${Do}
				${LineRead} "$0" "$R0" $hostdata
				${TrimNewLines} "$hostdata" $hostdata
				${If} $hostdata != ""
					${WordFind} "$hostdata" "." "#" $0
					${If} $0 != $hostdata
						${WordFind} "$hostdata" "+$0*}" "#" $1
						${WordFind} "$hostdata" "+$0{{" "#" $2
						${ConfigWrite} "${SYSTEMHOST}" "$2" "$1" $3
					${EndIf}
				${EndIf}
				IntOp $R0 $R0 + 1
			${LoopUntil} $R0 > $1
		${EndIf}
	${EndIf}
; patch
!macroend

/* ${SegmentPre}
	nop
!macroend */

/* ${SegmentPrePrimary}
	nop
!macroend */

/* ${SegmentPreSecondary}
	nop
!macroend */

/* ${SegmentPreExec}
	nop
!macroend */

/* ${SegmentPreExecPrimary}
	Nop
!macroend */

/* ${SegmentPreExecSecondary}
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
; patch
	ClearErrors
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "RestoreHost"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "RestoreHost" ""
	ReadINIStr $1 "$EXEDIR\$BaseName.ini" "$BaseName" "PatchHost"
	${If} $0 != false
	${AndIf} $1 == true
		ClearErrors
		ReadINIStr $0 "$EXEDIR\$BaseName.ini" "Host" "1"
		${IfNot} ${Errors}
			StrCpy $R0 "1"
			${Do}
				ClearErrors
				ReadINIStr $hostdata "$EXEDIR\$BaseName.ini" "Host" "$R0"
				${IfThen} ${Errors} ${|} ${ExitDo} ${|}
				${If} $hostdata != ""
					${WordFind} "$hostdata" "." "#" $0
					${If} $0 != $hostdata
						; ${WordFind} "$hostdata" "+$0*}" "#" $1
						${WordFind} "$hostdata" "+$0{{" "#" $2
						${ConfigWrite} "${SYSTEMHOST}" "$2" "" $3
					${EndIf}
				${EndIf}
				IntOp $R0 $R0 + 1
			${Loop}
		${Else}
			ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "HostPath"
			${If} $0 == ""
				StrCpy $0 "${PATCHHOST}"
			${EndIf}
			ExpandEnvStrings $0 "$0"
			${GetRoot} "$0" $1
			${If} $1 == ""
				StrCpy $0 "$EXEDIR\Data\$0"
			${EndIf}
			${LineSum} "$0" $1
			StrCpy $R0 "1"
			${Do}
				${LineRead} "$0" "$R0" $hostdata
				${TrimNewLines} "$hostdata" $hostdata
				${If} $hostdata != ""
					${WordFind} "$hostdata" "." "#" $0
					${If} $0 != $hostdata
						; ${WordFind} "$hostdata" "+$0*}" "#" $1
						${WordFind} "$hostdata" "+$0{{" "#" $2
						${ConfigWrite} "${SYSTEMHOST}" "$2" "" $3
					${EndIf}
				${EndIf}
				IntOp $R0 $R0 + 1
			${LoopUntil} $R0 > $1
		${EndIf}
	${EndIf}
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "PatchHost"
	${If} $0 == true
		ReadINIStr $1 "$EXEDIR\$BaseName.ini" "$BaseName" "HostAttributes"
		${WordFind} "$1" "|" "#" $2
		StrCpy $R0 "1"
		${Do}
			${WordFind} "$1" "|" "+$R0" $3
			${Select} $3
			${Case} "ARCHIVE"
				SetFileAttributes "${SYSTEMHOST}" ARCHIVE
			${Case} "HIDDEN"
				SetFileAttributes "${SYSTEMHOST}" HIDDEN
			${Case} "OFFLINE"
				SetFileAttributes "${SYSTEMHOST}" OFFLINE
			${Case} "READONLY"
				SetFileAttributes "${SYSTEMHOST}" READONLY
			${Case} "SYSTEM"
				SetFileAttributes "${SYSTEMHOST}" SYSTEM
			${Case} "TEMPORARY"
				SetFileAttributes "${SYSTEMHOST}" TEMPORARY
			${EndSelect}
			IntOp $R0 $R0 + 1
		${LoopUntil} $R0 > $2
		Delete "${SYSTEMHOST}.$BaseName"
	${EndIf}
; patch
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