${SegmentFile}

!define PATCHHOST "$EXEDIR\Data\Host"
!define SYSTEMHOST "$SYSDIR\drivers\etc\hosts"
!define SYSTEMHOSTICS "$SYSDIR\drivers\etc\hosts.ics"
!define ATTRIBUTES "ARCHIVE|HIDDEN|OFFLINE|READONLY|SYSTEM|TEMPORARY"
Var hostdata
Var hostpath
Var hostattributes
; LangString HostMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString HostMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

; Function .onInit          ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} Core
; 	${RunSegment} Temp
; 	${RunSegment} Language
; 	${RunSegment} OperatingSystem
; 	${RunSegment} RunAsAdmin
; FunctionEnd
/* ${Segment.onInit}
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
${SegmentInit}
	ClearErrors
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "HostPath"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HostPath" ""
	ClearErrors
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "HostType"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HostType" "|[no]/host/host.ics"
	StrCpy $0 "|[no]/host/host.ics"
	${WordFind} "$0" "|" "+1{" $0
	${Select} $0
	${Case} "host"
		StrCpy $hostpath "${SYSTEMHOST}"
	${Case} "host.ics"
		StrCpy $hostpath "${SYSTEMHOSTICS}"	
	${EndSelect}
!macroend

; Function Pre              ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} RunLocally
; 	${RunSegment} Temp
; 	${RunSegment} Environment
; 	${RunSegment} ExecString
; FunctionEnd
${SegmentPre}
	${If} $hostpath != ""
		${If} ${FileExists} "$hostpath"
			CopyFiles "$hostpath" "$hostpath.$BaseName"
		${Else}
			FileOpen $1 "$hostpath" "a"
			FileWrite $1 ""
			FileClose $1
		${EndIf}
		${GetFileAttributes} "$hostpath" "ALL" $hostattributes
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HostAttributes" "$hostattributes"
		${If} $hostattributes != "NORMAL"
		${AndIf} $hostattributes != "ARCHIVE"
			SetFileAttributes "$hostpath" NORMAL
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
						${WordFind} "$hostdata" "." "+$0*}" $1
						${WordFind} "$hostdata" "." "+$0{{" $2
						${ConfigWrite} "$hostpath" "$2" "$1" $3
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
						${WordFind} "$hostdata" "." "+$0*}" $1
						${WordFind} "$hostdata" "." "+$0{{" $2
						${ConfigWrite} "$hostpath" "$2" "$1" $3
					${EndIf}
				${EndIf}
				IntOp $R0 $R0 + 1
			${LoopUntil} $R0 > $1
		${EndIf}
	${EndIf}
!macroend

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
	nop
!macroend */

; Function PreSecondary     ;{{{1
; 	${RunSegment} Custom
; 	;${RunSegment} *
; FunctionEnd
/* ${SegmentPreSecondary}
	nop
!macroend */

; Function PreExec          ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} RefreshShellIcons
; 	${RunSegment} WorkingDirectory
; FunctionEnd
/* ${SegmentPreExec}
	nop
!macroend */

; Function PreExecPrimary   ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} Core
; 	${RunSegment} SplashScreen
; FunctionEnd
/* ${SegmentPreExecPrimary}
	Nop
!macroend */

; Function PreExecSecondary ;{{{1
; 	${RunSegment} Custom
; 	;${RunSegment} *
; FunctionEnd
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
${SegmentPostPrimary}
	ClearErrors
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "RestoreHost"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "RestoreHost" "true"
	ReadINIStr $1 "$EXEDIR\$BaseName.ini" "$BaseName" "HostType"
	${WordFind} "$1" "|" "+1{" $1
	${Select} $1
	${Case} "host"
		StrCpy $hostpath "${SYSTEMHOST}"
	${Case} "host.ics"
		StrCpy $hostpath "${SYSTEMHOSTICS}"	
	${EndSelect}
	${If} $0 != false
	${AndIf} $hostpath != ""
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
						${WordFind} "$hostdata" "." "+$0{{" $2
						${ConfigWrite} "$hostpath" "$2" "" $3
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
						${WordFind} "$hostdata" "." "+$0{{" $2
						${ConfigWrite} "$hostpath" "$2" "" $3
					${EndIf}
				${EndIf}
				IntOp $R0 $R0 + 1
			${LoopUntil} $R0 > $1
		${EndIf}
	${EndIf}

	${If} $hostpath != ""
		ReadINIStr $1 "$EXEDIR\$BaseName.ini" "$BaseName" "HostAttributes"
		${WordFind} "$1" "|" "#" $2
		StrCpy $R0 "1"
		${Do}
			${WordFind} "$1" "|" "+$R0" $3
			${Select} $3
			${Case} "ARCHIVE"
				SetFileAttributes "$hostpath" ARCHIVE
			${Case} "HIDDEN"
				SetFileAttributes "$hostpath" HIDDEN
			${Case} "OFFLINE"
				SetFileAttributes "$hostpath" OFFLINE
			${Case} "READONLY"
				SetFileAttributes "$hostpath" READONLY
			${Case} "SYSTEM"
				SetFileAttributes "$hostpath" SYSTEM
			${Case} "TEMPORARY"
				SetFileAttributes "$hostpath" TEMPORARY
			${EndSelect}
			IntOp $R0 $R0 + 1
		${LoopUntil} $R0 > $2
		Delete "$hostpath.$BaseName"
	${EndIf}
!macroend

; Function PostSecondary    ;{{{1
; 	;${RunSegment} *
; 	${RunSegment} Custom
; FunctionEnd
/* ${SegmentPostSecondary}
	Nop
!macroend */

; Function Post             ;{{{1
; 	${RunSegment} RefreshShellIcons
; 	${RunSegment} Custom
; FunctionEnd
/* ${SegmentPost}
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
	Nop
!macroend */