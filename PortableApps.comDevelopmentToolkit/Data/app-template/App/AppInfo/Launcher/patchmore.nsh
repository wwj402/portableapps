${SegmentFile}

!ifndef VERSION_NUM
	!searchparse "${NSIS_VERSION}" "v" "VERSION_NUM"
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

!include "x64.nsh"
!define PATCHDIR "$EXEDIR\Data\Patch"
!define PSYBEXENAME "NTLinksMaker"
!define PSYBDIR "$EXEDIR\Data\NTLinksMaker"
!define PSYBSWITCH "/q /n /b /s"
Var patchpath
Var patchpathto
Var patchflag
Var patchtype
Var patchlast

; LangString PatchMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString PatchMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

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
		${If} ${FileExists} "$R0"
			; md5dll::GetMD5File "$R9"
			CRCCheck::GenCRC "$R9"
			Pop $R1
			; md5dll::GetMD5File "$R0"
			CRCCheck::GenCRC "$R0"
			Pop $R2
		${EndIf}
		${If} ${FileExists} "$R0.bak"
		${AndIf} ${FileExists} "$R0"
			StrCmp $R1 $R2 +3 0
			Rename "$R0" "$R0_$R2"
			CopyFiles "$R9" "$R0"
		${ElseIf} ${FileExists} "$R0"
			StrCmp $R1 $R2 +3 0
			Rename "$R0" "$R0.bak"
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
Function "patchlink"
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
		${If} ${FileExists} "$R0"
			${GetFileAttributes} "$R0" "REPARSE_POINT" $R1
			${If} $R1 != 1
				${If} ${FileExists} "$R0.bak"
				${AndIf} ${FileExists} "$R0"
					; md5dll::GetMD5File "$R9"
					CRCCheck::GenCRC "$R9"
					Pop $R1
					; md5dll::GetMD5File "$R0"
					CRCCheck::GenCRC "$R0"
					Pop $R2
					${If} $R1 == $R2
						Delete "$R0"
					${Else}
						Rename "$R0" "$R0_$R2"
					${EndIf}
				${ElseIf} ${FileExists} "$R0"
					Rename "$R0" "$R0.bak"
				${EndIf}
			${Else}
				Delete "$R0"
			${EndIf}
		${EndIf}
		${IfNot} ${FileExists} "$R0"
			${If} ${RunningX64}
				ExecDos::exec '"${PSYBDIR}\${PSYBEXENAME}64.exe" ${PSYBSWITCH} "$R9" "$R0"' '' ''
			${Else}
				ExecDos::exec '"${PSYBDIR}\${PSYBEXENAME}.exe" ${PSYBSWITCH} "$R9" "$R0"' '' ''
			${EndIf}
			Pop $R1
		${EndIf}
		${GetFileAttributes} "$R0" "REPARSE_POINT" $R1
		${If} $R1 != 1
			SetErrors
		${EndIf}
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
	${EndIf}
	Pop $R0
	Push "continue"
FunctionEnd

/* ${Segment.onInit}
	nop
!macroend */

${SegmentInit}
	ClearErrors
	ReadINIStr $patchpath "$EXEDIR\$BaseName.ini" "$BaseName" "PatchDir"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchDir" ""
	${If} $patchpath == ""
		StrCpy $patchpath "${PATCHDIR}"
	${EndIf}
	!insertmacro "path_canonicalize" "$EXEDIR\Data" "$patchpath"
	ClearErrors
	ReadINIStr $patchpathto "$EXEDIR\$BaseName.ini" "$BaseName" "PatchtoDir"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchtoDir" ""
	ClearErrors
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "PatchFlag"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchFlag" "|[no]/copy/link/restore/linkrestore"
	StrCpy $strtemp "|[no]/copy/link/restore/linkrestore"
	${If} ${FileExists} "$patchpath"
		${WordFind} "$strtemp" "|" "#" $0
		${Select} $0
		${Case} 2
			${WordFind} "$strtemp" "|" "+1" $patchflag
			${WordFind} "$strtemp" "|" "-1" $1
		${Case} 1
			${WordFind} "$strtemp" "|" "+1{" $patchflag
			${WordFind} "$strtemp" "|" "+1}" $1
			${If} $1 == ""
				StrCpy $1 "[no]/copy/link/restore/linkrestore"
				WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchFlag" "$patchflag|$1"
			${EndIf}
		${Case} $strtemp
			StrCpy $patchflag $0
			StrCpy $1 "[no]/copy/link/restore/linkrestore"
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchFlag" "$patchflag|$1"
		${EndSelect}
	${EndIf}
	ClearErrors
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "PatchType"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchType" "|[normal]/arch/language/both"
	StrCpy $strtemp "|[normal]/arch/language/both"
	${If} ${FileExists} "$patchpath"
		${WordFind} "$strtemp" "|" "#" $0
		${Select} $0
		${Case} 2
			${WordFind} "$strtemp" "|" "+1" $patchtype
			${WordFind} "$strtemp" "|" "-1" $1
		${Case} 1
			${WordFind} "$strtemp" "|" "+1{" $patchtype
			${WordFind} "$strtemp" "|" "+1}" $1
			${If} $1 == ""
				StrCpy $1 "[normal]/arch/language/both"
				WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchType" "$patchtype|$1"
			${EndIf}
		${Case} $strtemp
			StrCpy $patchflag $0
			StrCpy $1 "[normal]/arch/language/both"
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchType" "$patchtype|$1"
		${EndSelect}
	${EndIf}
	${Switch} $patchtype
	${Case} "both"
	${Case} "arch"
		StrCpy $patchpath "$patchpath\$Bits"
		StrCpy $patchlast "$patchlast\$Bits"
	${EndSwitch}
!macroend

${SegmentPre}
	${Switch} $patchtype
	${Case} "both"
	${Case} "language"
		ReadEnvStr $0 "PAL:LanguageCustom"
		StrCmp $0 "" 0 +2
		StrCpy $0 "$LANGUAGE"
		StrCpy $patchpath "$patchpath\$0"
		StrCpy $patchlast "$patchlast\$0"
	${EndSwitch}
	${If} ${FileExists} "$patchpath"
		ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "PatchLast"
		${If} $0 != $patchlast
		${AndIf} $patchflag != ""
		${AndIf} $patchflag != "no"
		${AndIf} $patchflag != "link"
		${AndIf} $patchflag != "linkrestore"
			${If} $patchpathto == ""
				ReadEnvStr $patchpathto "ProgramDir"
			${EndIf}
			!insertmacro "path_canonicalize" "$EXEDIR\App" "$patchpathto"
			ClearErrors
			${Locate} "$patchpath" "/L=FD /G=1" "patchcopy"
			IfErrors 0 +3
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchLast" "$patchlast|error"
			goto +2
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchLast" "$patchlast"
		${EndIf}
		${If} $0 != $patchlast
		${AndIf} $patchflag == "link"
		${OrIf} $patchflag == "linkrestore"
			${If} $patchpathto == ""
				ReadEnvStr $patchpathto "ProgramDir"
			${EndIf}
			!insertmacro "path_canonicalize" "$EXEDIR\App" "$patchpathto"
			ClearErrors
			${Locate} "$patchpath" "/L=FD /G=1" "patchlink"
			IfErrors 0 +3
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchLast" "$patchpath|error"
			Goto +2
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "PatchLast" "$patchpath"
		${EndIf}
	${EndIf}
!macroend

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
	${If} $patchflag == "restore"
	${OrIf} $patchflag == "linkrestore"
		ClearErrors
		${Locate} "$patchpath" "/L=FD /G=1" "patchremove"
	${EndIf}
; patch
!macroend

/* ${SegmentPostSecondary}
	Nop
!macroend */

/* ${SegmentPost}
	Nop
!macroend */

/* ${SegmentUnload}
	Nop
!macroend */