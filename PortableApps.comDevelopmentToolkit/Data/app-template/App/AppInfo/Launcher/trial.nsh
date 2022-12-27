${SegmentFile}

!ifndef VERSION_NUM
	!searchparse /noerrors "${NSIS_VERSION}" "v" "VERSION_NUM" "-"
!endif
!ifndef USERPLUGINDIR
; !addincludedir "${PACKAGE}\App\AppInfo\Launcher\Include"
!define NSISCONF_3 ";" ; NSIS 2 tries to parse some preprocessor instructions inside "!if 0" blocks!
; !if ${NSIS_PACKEDVERSION} > 0x02ffffff ; NSIS 3+:
!if ${VERSION_NUM} >= 3
	!define /redef NSISCONF_3 ""
	${NSISCONF_3}!addplugindir /x86-ansi "${PACKAGE}\App\AppInfo\Launcher\Plugins\x86-ansi"
	${NSISCONF_3}!addplugindir /x86-unicode "${PACKAGE}\App\AppInfo\Launcher\Plugins\x86-unicode"
!else ; NSIS 2:
	!ifdef NSIS_UNICODE
		!addplugindir "${PACKAGE}\App\AppInfo\Launcher\Plugins\x86-unicode"
	!else
		!addplugindir "${PACKAGE}\App\AppInfo\Launcher\Plugins\x86-ansi"
	!endif
!endif ;~ NSIS_PACKEDVERSION
!undef NSISCONF_3
!define USERPLUGINDIR
!endif

!define TRIALTYPE "|[no]/runasdate/call<????>"
!define RUNASDATE "runasdate\runasdate.exe|runasdate32.exe/runasdate64.exe"
!define RUNASDATEPARA "Days:-7"
Var runasdatepath
Var runasdatepara
Var trialtype


; LangString TrialMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString TrialMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

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

Function "time_t"
	Push $0
	Push $1
	system::call *(&i16,l)i.s
	system::call 'kernel32::GetLocalTime(isr0)'
	IntOp $1 $0 + 16
	system::call 'kernel32::SystemTimeToFileTime(ir0,ir1)'
	system::call *$1(l.r1)
	system::free $0
	system::Int64Op $1 / 10000000
	Pop $1
	system::Int64Op $1 - 11644473600
	Exch 2
	Exch
	Pop $1
	Pop $0
FunctionEnd

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
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "TrialType"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "TrialType" "${TRIALTYPE}"
	StrCpy $strtemp "${TRIALTYPE}"
	${WordFind} "$strtemp" "|" "#" $0
	${Select} $0
	${Case} 2
		${WordFind} "$strtemp" "|" "+1" $trialtype
		${WordFind} "$strtemp" "|" "-1" $1
	${Case} 1
		${WordFind} "$strtemp" "|" "+1{" $trialtype
		${WordFind} "$strtemp" "|" "+1}" $1
	${Case} $strtemp
		StrCpy $trialtype "$0"
		StrCpy $1 ""
	${EndSelect}
	${If} $1 == ""
		StrCpy $1 "${TRIALTYPE}" "" 1
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "TrialType" "$trialtype|$1"
	${EndIf}
	ClearErrors
	ReadINIStr $runasdatepath "$EXEDIR\$BaseName.ini" "$BaseName" "RunasdatePath"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "RunasdatePath" "${RUNASDATE}"
	StrCpy $runasdatepath "${RUNASDATE}"
	${If} $trialtype == "runasdate"
		${WordFind} $runasdatepath "|" "#" $1
		${Select} $1
		${Case} 2
			${WordFind} $runasdatepath "|" "+1}" $1
			${WordFind} $runasdatepath "|" "+1{" $runasdatepath
		${Case} 1
			StrCpy $2 "$runasdatepath" 1
			StrCmp $2 "|" 0 +3
			StrCpy $runasdatepath "$runasdatepath" "" 1
			Goto +2
			StrCpy $runasdatepath "$runasdatepath" -1
			StrCpy $1 ""
		${CaseElse}
			StrCpy $1 ""
		${EndSelect}
		${WordFind} $runasdatepath "/" "#" $2
		${Select} $2
		${Case} 2
			!insertmacro "path_canonicalize" "$EXEDIR\Data" "$runasdatepath"
			${GetParent} "$runasdatepath" $2
			${If} $RegViewFlag == "64"
				${WordFind} "$runasdatepath" "/" "+1}" $runasdatepath
			${Else}
				${WordFind} "$runasdatepath" "/" "+1{" $runasdatepath
			${EndIf}
			!insertmacro "path_canonicalize" "$2" "$runasdatepath"
		${Case} 1
			StrCpy $2 "$runasdatepath" 1
			StrCmp $2 "/" 0 +3
			StrCpy $runasdatepath "$runasdatepath" "" 1
			Goto +2
			StrCpy $runasdatepath "$runasdatepath" -1
		${EndSelect}
		${If} $runasdatepath != ""
			!insertmacro "path_canonicalize" "$EXEDIR\Data" "$runasdatepath"
		${EndIf}
		${If} $1 != ""
			${WordFind} $1 "/" "#" $2
			${If} $2 == 2
				${WordFind} "$1" "/" "+1{" $2
				${WordFind} "$1" "/" "+1}" $3
				${GetParent} "$runasdatepath" $0
				!insertmacro "path_canonicalize" "$0" "$2"
				!insertmacro "path_canonicalize" "$0" "$3"
				${IfNot} ${FileExists} "$runasdatepath"
				${AndIf} ${FileExists} "$3"
				${AndIf} $RegViewFlag == "64"
					Rename "$3" "$runasdatepath"
				${ElseIfNot} ${FileExists} "$runasdatepath"
				${AndIf} ${FileExists} "$2"
				${AndIf} $RegViewFlag == "32"
					Rename "$2" "$runasdatepath"
				${ElseIf} ${FileExists} "$runasdatepath"
				${AndIf} ${FileExists} "$2"
				${AndIf} $RegViewFlag == "32"
					Rename "$runasdatepath" "$3"
					Rename "$2" "$runasdatepath"
				${ElseIf} ${FileExists} "$runasdatepath"
				${AndIf} ${FileExists} "$3"
				${AndIf} $RegViewFlag == "64"
					Rename "$runasdatepath" "$2"
					Rename "$3" "$runasdatepath"
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}
	ClearErrors
	ReadINIStr $runasdatepara "$EXEDIR\$BaseName.ini" "$BaseName" "RunasdatePara"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "RunasdatePara" "${RUNASDATEPARA}"
!macroend

; Function Pre              ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} RunLocally
; 	${RunSegment} Temp
; 	${RunSegment} Environment
; 	${RunSegment} ExecString
; FunctionEnd
${SegmentPre}
	${If} $trialtype != ""
		StrCpy $0 "$trialtype" 5
		StrCmp $0 "call<" 0 +4
		StrCpy $0 "$trialtype" -1 5
		Push $0
		call resettrial
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

${OverrideExecute}

	${If} $trialtype == "runasdate"
	${AndIf} ${FileExists} "$runasdatepath"
		${If} $RegViewFlag == "64"
			ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64"
		${Else}
			ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable"
		${EndIf}
		${GetFileName} "$1" $1
		StrCpy $0 "1"
		${Do}
			ClearErrors
			ReadINIStr $2 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "WaitForEXE$0"
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${If} $1 == $2
				StrCpy $1 ""
				${ExitDo}
			${EndIf}
			IntOp $0 $0 + 1
		${Loop}
		${If} $1 != ""
			WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "WaitForEXE$0" "$1"
		${EndIf}
		StrCpy $ExecString `"$runasdatepath" $runasdatepara $ExecString`
	${EndIf}
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

!macroend

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
	Nop
!macroend */

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