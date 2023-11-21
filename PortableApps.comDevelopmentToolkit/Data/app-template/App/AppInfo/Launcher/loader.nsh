${SegmentFile}

!define LOADERFLAG "|[no]/copy/link/nokeep"
!define LOADERDIR "loader"
!define LOADER "loader.exe"
!ifndef LINKEXE
!define LINKEXE "NTLinksMaker\NTLinksMaker.exe|NTLinksMaker32.exe/NTLinksMaker64.exe"
!define LINKPARA `/q /n /b /sr? "{<src_file>|@<src_list_utf16>}" "<dst_path>"`
!endif
Var loaderpath
Var loaderpathto
Var loaderflag
Var loaderlast
Var loaderwait
Var linkexe
Var linkpara

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

Function "loaderadd"
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
		${If} ${FileExists} "$R0"
			md5dll::GetMD5File "$R9"
			Pop $R1
			md5dll::GetMD5File "$R0"
			Pop $R2
		${EndIf}
		IfFileExists "$R0" 0 +2
		StrCmp $R1 $R2 SKIP 0
		${Switch} $loaderflag
		${Case} "copy"
		${Case} "nokeep"
			CopyFiles "$R9" "$R0"
			${Break}
		${Case} "link"
			${WordReplace} $linkpara "{<src_file>|@<src_list_utf16>}" "$R9" "+" $linkpara
			${WordReplace} $linkpara "<dst_path>" "$R0" "+" $linkpara
			ExecDos::exec '"$linkexe" $linkpara' "" ""
			Pop $R2
			StrCmp $R2 "0" +2 0
			SetErrors
		${EndSwitch}
	${EndIf}
	SKIP:
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
		${WordReplace} "$R9" "$loaderpath" "$loaderpathto" "+1" $R0
		${If} ${FileExists} "$R0"
			Delete "$R0"
		${EndIf}
	${EndIf}
	Pop $R0
	Push "continue"
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
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderFlag" "${LOADERFLAG}"
	StrCpy $strtemp "${LOADERFLAG}"
	ClearErrors
	ReadINIStr $loaderlast "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderLast"
	IfErrors 0 +2
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderLast" ""
	ClearErrors
	ReadINIStr $linkexe "$EXEDIR\$BaseName.ini" "$BaseName" "LinkExe"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LinkExe" "${LINKEXE}"
	StrCpy $linkexe "${LINKEXE}"
	ClearErrors
	ReadINIStr $linkexe "$EXEDIR\$BaseName.ini" "$BaseName" "LinkPara"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LinkPara" `${LINKPARA}`
	StrCpy $linkpara `${LINKPARA}`
	${WordFind} $linkexe "|" "+1{" $0
	${If} $0 != ""
		${WordFind} $linkexe "|" "+1}" $1
		${If} $1 != ""
			${WordFind} $1 "/" "#" $2
			${Select} $2
			${Case} "2"
				${WordFind} $1 "/" "+1{" $3
				${WordFind} $1 "/" "+1}" $4
				!insertmacro "path_canonicalize" "$EXEDIR\Data" "$0"
				${GetParent} "$0" $2
				${IfNot} ${FileExists} "$0"
				${AndIf} ${RunningX64}
				${AndIf} ${FileExists} "$2\$4"
					Rename "$2\$4" "$0"
				${ElseIfNot} ${FileExists} "$0"
				${AndIfNot} ${RunningX64}
				${AndIf} ${FileExists} "$2\$3"
					Rename "$2\$3" "$0"
				${ElseIf} ${FileExists} "$0"
				${AndIf} ${RunningX64}
				${AndIf} ${FileExists} "$2\$4"
				${AndIfNot} ${FileExists} "$2\$3"
					Rename "$0" "$2\$3"
					Rename "$2\$4" "$0"
				${ElseIf} ${FileExists} "$0"
				${AndIfNot} ${RunningX64}
				${AndIf} ${FileExists} "$2\$3"
				${AndIfNot} ${FileExists} "$2\$4"
					Rename "$0" "$2\$4"
					Rename "$2\$3" "$0"
				${ElseIf} ${FileExists} "$0"
				${AndIf} ${FileExists} "$2\$3"
				${AndIf} ${FileExists} "$2\$4"
					Delete "$0"
					${If} ${RunningX64}
						Rename "$2\$4" "$0"
					${Else}
						Rename "$2\$3" "$0"
					${EndIf}
				${EndIf}
			${Case} "1"
				${WordFind} $1 "/" "+1{" $3
				!insertmacro "path_canonicalize" "$EXEDIR\Data" "$0"
				${GetParent} "$0" $2
				${IfNot} ${FileExists} "$0"
				${AndIf} ${FileExists} "$2\$3"
					Rename "$2\$" "$0"
				${EndIf}
			${EndSelect}
		${EndIf}
	${EndIf}
	StrCpy $linkexe "$0"
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
			${WordFind} "$strtemp" "|" "+1" $loaderflag
			${WordFind} "$strtemp" "|" "-1" $1
		${Case} 1
			${WordFind} "$strtemp" "|" "+1{" $loaderflag
			${WordFind} "$strtemp" "|" "+1}" $1
		${Case} $strtemp
			StrCpy $loaderflag $0
			StrCpy $1 ""
		${EndSelect}
		${If} $1 == ""
			StrCpy $1 "${LOADERFLAG}" "" 1
			WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderFlag" "$loaderflag|$1"
		${EndIf}
		ReadINIStr $loaderlast "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderLast"
	${EndIf}
!macroend

; Function Pre              ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} RunLocally
; 	${RunSegment} Temp
; 	${RunSegment} Environment
; 	${RunSegment} ExecString
; FunctionEnd
${SegmentPre}
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "Loader"
	${If} ${FileExists} "$loaderpath\$0"
		${Switch} $loaderflag
		${Case} ""
		${Case} "no"
			${Break}
		${Case} "nokeep"
			IfFileExists "$loaderpath\loaded" 0 +2
			Delete "$loaderpath\loaded"
		${Case} "copy"
		${Case} "link"
			ReadEnvStr $loaderpathto "ProgramDir"
			ClearErrors
			${If} $loaderpath == $loaderlast
			${AndIfNot} ${FileExists} "$loaderpath\loaded"
			${OrIf} $loaderpath != $loaderlast
				${Locate} "$loaderpath" "/L=FD /G=1" "loaderadd"
			${EndIf}
			${If} ${Errors}
				WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderLast" "$loaderpath|error"
			${Else}
				WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LoaderLast" "$loaderpath"
			${EndIf}
			${IfNot} ${Errors}
			${AndIfNot} $loaderflag == "nokeep"
			${AndIfNot} ${FileExists} "$loaderpath\loaded"
				FileOpen $0 "$loaderpath\loaded" w
				FileWrite $0 ""
				FileClose $0
			${EndIf}
			ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64"
			${If} $Bits == 64
			${AndIf} $0 != ""
				${GetFileName} "$0" $loaderwait
			${Else}
				ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable"
				${GetFileName} "$0" $loaderwait
			${EndIf}
			StrCpy $0 "1"
			${Do}
				ClearErrors
				ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "WaitForEXE$0"
				${IfThen} ${Errors} ${|} ${ExitDo} ${|}
				${If} $1 == $loaderwait
					StrCpy $loaderwait ""
					${ExitDo}
				${EndIf}
				IntOp $0 $0 + 1
			${Loop}
			${If} $loaderwait != ""
				WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "WaitForEXE$0" "$loaderwait"
			${EndIf}
		${EndSwitch}
		ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "Loader"
		ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64"
		${If} $loaderflag != "no"
		${AndIf} $loaderflag != ""
		${AndIf} $Bits == 64
		${AndIf} $1 != ""
			${GetParent} "$1" $2
			${If} $2 != ""
				StrCpy $0 "$2\$0"
			${EndIf}
			${If} ${FileExists} "$EXEDIR\App\$0"
			${AndIfNot} $0 == $1
				${ConfigWrite} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "; ProgramExecutable64=" "$1" $2
				WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64" "$0"
			${EndIf}
		${ElseIf} $loaderflag != "no"
		${AndIf} $loaderflag != ""
			ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable"
			${GetParent} "$1" $2
			${If} $2 != ""
				StrCpy $0 "$2\$0"
			${EndIf}
			${If} ${FileExists} "$EXEDIR\App\$0"
			${AndIfNot} $0 == $1
				${ConfigWrite} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "; ProgramExecutable=" "$1" $2
				WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable" "$0"
			${EndIf}
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
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" "Loader"
	${If} $0 != ""
	${AndIf} ${FileExists} "$loaderpath\$0"
		${If} $loaderflag == "nokeep"
			ReadEnvStr $loaderpathto "ProgramDir"
			${Locate} "$loaderpath" "/L=FD /G=1" "loaderremove"
		${EndIf}
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64"
		${If} $loaderflag != "no"
		${AndIf} $loaderflag != ""
		${AndIf} $Bits == 64
		${AndIf} $0 != ""
			${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "; ProgramExecutable64=" $0
			${If} $0 != ""
				WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable64" "$0"
			${EndIf}
		${ElseIf} $loaderflag != "no"
		${AndIf} $loaderflag != ""
			${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "; ProgramExecutable=" $0
			${If} $0 != ""
				WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch "ProgramExecutable" "$0"
			${EndIf}
		${EndIf}
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