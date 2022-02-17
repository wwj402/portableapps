${SegmentFile}

; patch
!define PATCHDIR "$EXEDIR\Data\Patch"
Var patchpath
Var patchpathto
Var patchflag
; patch
; LangString PatchMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString PatchMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

; patch
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

Function "patchcopy"
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
		${WordReplace} "$R9" "$patchpath" "$patchpathto" "+1" $R0
		; MessageBox MB_OK "$R0"
		ClearErrors
		${If} ${FileExists} "$R0"
			md5dll::GetMD5File "$R9"
			Pop $R1
			md5dll::GetMD5File "$R0"
			Pop $R2
		${EndIf}
		${If} ${FileExists} "$R0.bak"
		${AndIf} ${FileExists} "$R0"
			StrCmp $R1 $R2 +3 0
			CopyFiles "$R0" "$R0.bak"
			CopyFiles "$R9" "$R0"
		${ElseIf} ${FileExists} "$R0"
			StrCmp $R1 $R2 +3 0
			Rename "$R0" "$R0.bak"
			CopyFiles "$R9" "$R0"
		${Else}
			CopyFiles "$R9" "$R0"
		${EndIf}
		IfErrors 0 +2
		StrCpy $patchflag "patcherror"
	${EndIf}
	Pop $R2
	Pop $R1
	Pop $R0
	Push "continue"
FunctionEnd

Function "patchremove"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R0
	${If} $R6 != ""
		${WordReplace} "$R9" "$patchpath" "$patchpathto" "+1" $R0
		ClearErrors
		${If} ${FileExists} "$R0.bak"
		${AndIf} ${FileExists} "$R0"
			Delete "$R0"
			Rename "$R0.bak" "$R0"
		${ElseIf} ${FileExists} "$R0.bak"
			Rename "$R0.bak" "$R0"
		${EndIf}
		IfErrors 0 +2
		StrCpy $patchflag "restoreerror"
	${EndIf}
	Pop $R0
	Push "continue"
FunctionEnd
; patch

/* ${Segment.onInit}
	nop
!macroend */

${SegmentInit}
; patch
	ClearErrors
	ReadINIStr $patchpath "$EXEDIR\$BaseName.ini" "$BaseName" "PatchDir"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchDir" ""
	${If} $patchpath == ""
		StrCpy $patchpath "${PATCHDIR}"
	${EndIf}
	!insertmacro "path_canonicalize" "$EXEDIR\Data" "$patchpath"
	IfFileExists "$patchpath\$Bits\*.*" 0 +2
	StrCpy $patchpath "$patchpath\$Bits"
	ClearErrors
	ReadINIStr $patchpathto "$EXEDIR\$BaseName.ini" "$BaseName" "PatchtoDir"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchtoDir" ""
	ClearErrors
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "PatchFlag"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchFlag" "|64/32/no/restore"
	StrCpy $strtemp "|64/32/no/restore"
	${If} ${FileExists} "$patchpath"
		${WordFind} "$strtemp" "|" "#" $0
		${Select} $0
		${Case} 2
			${WordFind} "$strtemp" "|" "+1" $1
			${WordFind} "$strtemp" "|" "-1" $2
		${Case} 1
			${WordFind} "$strtemp" "|" "+1{" $1
			${WordFind} "$strtemp" "|" "+1}" $2
			${If} $2 == ""
				StrCpy $2 "64/32/no/restore"
			${EndIf}
		${Case} $strtemp
			StrCpy $1 $0
			StrCpy $2 "64/32/no/restore"
		${EndSelect}
		${If} $1 != "no"
		${AndIf} $1 != $Bits
			${If} $patchpathto == ""
				ReadEnvStr $patchpathto "ProgramDir"
			${EndIf}
			!insertmacro "path_canonicalize" "$EXEDIR\App" "$patchpathto"
			${Locate} "$patchpath" "/L=FD /G=1" "patchcopy"
			${If} $patchflag != "patcherror"
			${AndIf} $1 != "restore"
				WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchFlag" "$Bits|$2"
			${EndIf}
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
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "PatchFlag"
	${WordFind} "$strtemp" "|" "+1" $1
	${If} $1 == "restore"
		ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "PatchDir"
		!insertmacro "path_canonicalize" "$EXEDIR\Data" "$patchpath"
		IfFileExists "$patchpath\$Bits\*.*" 0 +2
		StrCpy $patchpath "$patchpath\$Bits"
		ReadINIStr $patchpathto "$EXEDIR\$BaseName.ini" "$BaseName" "PatchtoDir"
		!insertmacro "path_canonicalize" "$EXEDIR\App" "$patchpath"
		${Locate} "$patchpath" "/L=FD /G=1" "patchremove"
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