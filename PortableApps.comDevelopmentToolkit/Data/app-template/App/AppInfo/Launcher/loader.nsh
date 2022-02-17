${SegmentFile}

!define LOADERDIR "$EXEDIR\Data\Loader"
!define LOADER "Loader.exe"
Var loaderpath
Var loaderpathto
Var loaderflag
Var loaderwait

; LangString LoaderMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString LoaderMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

!ifmacrondef path_canonicalize
Var macro_t
Var strtemp
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

Function "loadercopy"
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
		${WordReplace} "$R9" "$loaderpath" "$loaderpathto" "+1" $R0
		; MessageBox MB_OK "$R0"
		ClearErrors
		${If} ${FileExists} "$R0"
			md5dll::GetMD5File "$R9"
			Pop $R1
			md5dll::GetMD5File "$R0"
			Pop $R2
		${EndIf}
		${If} ${FileExists} "$R0"
			StrCmp $R1 $R2 +2 0
			CopyFiles "$R9" "$R0"
		${Else}
			CopyFiles "$R9" "$R0"
		${EndIf}
		IfErrors 0 +2
		StrCpy $loaderflag "loadererror"
	${EndIf}
	Pop $R2
	Pop $R1
	Pop $R0
	Push "continue"
FunctionEnd

Function "loaderremove"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R0
	${If} $R6 != ""
		ClearErrors
		${WordReplace} "$R9" "$loaderpath" "$loaderpathto" "+1" $R0
		${If} ${FileExists} "$R0"
			Delete "$R0"
		${EndIf}
		IfErrors 0 +2
		StrCpy $loaderflag "removeerror"
	${EndIf}
	Pop $R0
	Push "continue"
FunctionEnd

/* ${Segment.onInit}
	nop
!macroend */

${SegmentInit}
	ClearErrors
	ReadINIStr $loaderpath "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderDir"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderDir" "${LOADERDIR}"
	${If} $loaderpath == ""
		StrCpy $loaderpath "${LOADERDIR}"
	${EndIf}
	!insertmacro "path_canonicalize" "$EXEDIR\Data" "$loaderpath"
	IfFileExists "$loaderpath\$Bits\*.*" 0 +2
	StrCpy $loaderpath "$loaderpath\$Bits"
	ClearErrors
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderFlag"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderFlag" "|64/32/no/nokeep"
	StrCpy $strtemp "|64/32/no/nokeep"
	ClearErrors
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "Loader"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "Loader" "${LOADER}"
	StrCpy $0 "${LOADER}"
	${If} $0 != ""
	${AndIf} ${FileExists} "$loaderpath\$0"
		${WordFind} "$strtemp" "|" "#" $0
		${Select} $0
		${Case} 2
			${WordFind} "$strtemp" "|" "+1" $1
			${WordFind} "$strtemp" "|" "-1" $2
		${Case} 1
			${WordFind} "$strtemp" "|" "+1{" $1
			${WordFind} "$strtemp" "|" "+1}" $2
			${If} $2 == ""
				StrCpy $2 "64/32/no/nokeep"
			${EndIf}
		${Case} $strtemp
			StrCpy $1 $0
			StrCpy $2 "64/32/no/nokeep"
		${EndSelect}
		${If} $1 != "no"
		${AndIf} $1 != $Bits
			ReadEnvStr $loaderpathto "ProgramDir"
			${Locate} "$loaderpath" "/L=FD /G=1" "loadercopy"
			${If} $loaderflag != "loadererror"
			${AndIf} $1 != "nokeep"
				WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderFlag" "$Bits|$2"
			${EndIf}
			ReadINIStr $3 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64"
			${If} $Bits == 64
			${AndIf} $3 != ""
				${GetFileName} "$3" $loaderwait
			${Else}
				ReadINIStr $3 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable"
				${GetFileName} "$3" $loaderwait
			${EndIf}
			StrCpy $0 "1"
			${Do}
				ClearErrors
				ReadINIStr $3 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "WaitForEXE$0"
				${IfThen} ${Errors} ${|} ${ExitDo} ${|}
				${If} $3 == $loaderwait
					StrCpy $loaderwait ""
					${ExitDo}
				${EndIf}
				IntOp $0 $0 + 1
			${Loop}
			${If} $loaderwait != ""
				WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "WaitForEXE$0" "$loaderwait"
			${EndIf}
		${EndIf}
		ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "Loader"
		ReadINIStr $3 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64"
		${If} $1 != "no"
		${AndIf} $Bits == 64
		${AndIf} $3 != ""
			${GetParent} "$3" $2
			${If} $2 != ""
				StrCpy $0 "$2\$0"
			${EndIf}
			${If} ${FileExists} "$EXEDIR\App\$0"
				${ConfigWrite} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "; ProgramExecutable64=" "$3" $2
				WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "ProgramExecutable64" "$0"
			${EndIf}
		${ElseIf} $1 != "no"
			ReadINIStr $3 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable"
			${GetParent} "$3" $2
			${If} $2 != ""
				StrCpy $0 "$2\$0"
			${EndIf}
			${If} ${FileExists} "$EXEDIR\App\$0"
				${ConfigWrite} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "; ProgramExecutable=" "$3" $2
				WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable" "$0"
			${EndIf}
		${EndIf}
	${EndIf}
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
	ReadINIStr $loaderpath "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderDir"
	!insertmacro "path_canonicalize" "$EXEDIR\Data" "$loaderpath"
	IfFileExists "$loaderpath\$Bits\*.*" 0 +2
	StrCpy $loaderpath "$loaderpath\$Bits"
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "Loader"
	${If} $0 != ""
	${AndIf} ${FileExists} "$loaderpath\$0"
		ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderFlag"
		${WordFind} "$strtemp" "|" "+1" $1
		${If} $1 == "nokeep"
			ReadEnvStr $loaderpathto "ProgramDir"
			${Locate} "$loaderpath" "/L=FD /G=1" "loaderremove"
		${EndIf}
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64"
		${If} $1 != "no"
		${AndIf} $Bits == 64
		${AndIf} $0 != ""
			${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "; ProgramExecutable64=" $0
			${If} $0 != ""
				WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64" "$0"
			${EndIf}
		${ElseIf} $1 != "no"
			${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "; ProgramExecutable=" $0
			${If} $0 != ""
				WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable" "$0"
			${EndIf}
		${EndIf}
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