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

!define HOOKTYPE "|[no]/normal/runbefore/keep"
!define HOOKDIR "$EXEDIR\Data\hook"
Var hookpath
Var hookpathto
Var hooktype
Var hooklast

; LangString HookMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString HookMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

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

Function "hookadd"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R0
	Push $R1
	Push $R2
	${If} $R6 != ""
		${WordReplace} "$R9" "$hookpath" "$hookpathto" "+1" $R0
		; MessageBox MB_OK "$R0"
		${If} ${FileExists} "$R0"
			; md5dll::GetMD5File "$R9"
			CRCCheck::GenCRC "$R9"
			Pop $R1
			; md5dll::GetMD5File "$R0"
			CRCCheck::GenCRC "$R0"
			Pop $R2
			StrCmp $R1 $R2 +2 0
			CopyFiles "$R9" "$R0"
		${Else}
			CopyFiles "$R9" "$R0"
		${EndIf}
	${EndIf}
	Pop $R2
	Pop $R1
	Pop $R0
	Push "continue"
FunctionEnd

Function "hookremove"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R0
	${If} $R6 != ""
		${WordReplace} "$R9" "$hookpath" "$hookpathto" "+1" $R0
		Delete "$R0"
	${EndIf}
	Pop $R0
	Push "continue"
FunctionEnd

/* ${Segment.onInit}
	Nop
!macroend */

${SegmentInit}
	ClearErrors
	ReadINIStr $hookpath "$EXEDIR\$BaseName.ini" "$BaseName" "HookDir"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HookDir" ""
	${If} $hookpath == ""
		StrCpy $hookpath "${HOOKDIR}"
	${EndIf}
	!insertmacro "path_canonicalize" "$EXEDIR\Data" "$hookpath"
	${If} ${Cmd} `IfFileExists "$hookpath\$Bits\*.*"`
		StrCpy $hookpath "$hookpath\$Bits"
	${EndIf}
	ReadEnvStr $hookpathto "ProgramDir"
/* 	ClearErrors
	ReadINIStr $hookpathto "$EXEDIR\$BaseName.ini" "$BaseName" "HooktoDir"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HooktoDir" "" */
	ClearErrors
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "HookType"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HookType" "${HOOKTYPE}"
	StrCpy $strtemp "${HOOKTYPE}"
	${If} ${FileExists} "$hookpath"
		${WordFind} "$strtemp" "|" "#" $0
		${Select} $0
		${Case} 2
			${WordFind} "$strtemp" "|" "+1" $hooktype
			${WordFind} "$strtemp" "|" "-1" $1
		${Case} 1
			${WordFind} "$strtemp" "|" "+1{" $hooktype
			${WordFind} "$strtemp" "|" "+1}" $1
		${Case} $strtemp
			StrCpy $HookType "$0"
			StrCpy $1 ""
		${EndSelect}
		${If} $1 == ""
			StrCpy $1 "${HOOKTYPE}" "" 1
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HookType" "$hooktype|$1"
		${EndIf}
		${If} $hooktype == "keep"
			ReadINIStr $hooklast "$EXEDIR\$BaseName.ini" "$BaseName" "HookLast"
			${If} $hooklast == $hookpath
				${GetParent} "$hookpath" $0
				IfFileExists "$0\keeped" +2 0
				StrCpy $hooktype "no"
			${EndIf}
		${EndIf}
	${EndIf}
!macroend

; Function Pre              ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} RunLocally
; 	${RunSegment} Temp
; 	${RunSegment} Environment
; 	${RunSegment} ExecString
; FunctionEnd
/* ${SegmentPre}
	Nop
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
${SegmentPreExecPrimary}
	${If} ${FileExists} "$hookpath"
		${Switch} $hooktype
		${Case} ""
		${Case} "no"
			${Break}
		${Case} "runbefore"
			${If} $Bits == 32
			${AndIf} $OSarch != 64
				; ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable
				; StrCpy $0 "$EXEDIR\App\$0"
				; ${Execute} "$0" "" $1
				; ${If} $1 != 0
				; 	${GetProcessName} "$1" $0
				; 	${ProcessWaitClose} "$0" "3000" $0
				; 	${If} $0 == -1
				; 		${CloseProcess} "$1" $0
				; 	${EndIf}
				; ${EndIf}
				; ReadEnvStr $0 "ProgramPath"
				ExecDos::exec /TIMEOUT=1000 "$ProgramExecutable" "" ""
			${EndIf}
		${CaseElse}
			ClearErrors
			${Locate} "$hookpath" "/G=0 /L=F /M=*.*" "hookadd"
			IfErrors 0 +3
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HookLast" "$hookpath|error"
			Goto +2
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "HookLast" "$hookpath"
			${If} $hooktype == "keep"
			${AndIfNot} ${Errors}
				${GetParent} "$hookpath" $0
				IfFileExists "$0\keeped" +4 0
				FileOpen $1 "$0\keeped" w
				FileWrite $1 ""
				FileClose $1
			${EndIf}
		${EndSwitch}
	${EndIf}
!macroend

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
	${If} $hooktype != "keep"
		ClearErrors
		${Locate} "$hookpath" "/G=0 /L=F /M=*.*" "hookremove"
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