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

Var mergetype
Var lastflag
Var mergeflag

Function "layoutmerge"
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
	Push $R3
	StrLen $R0 "_$mergeflag"
	StrCpy $R1 "$R7" -$R0
	${If} ${FileExists} "$R8\$R1"
	${AndIf} $mergeflag != $lastflag
	${AndIf} ${FileExists} "$R8\$R1_$lastflag"
		${If} $R6 == ""
			GetFileTime "$R8\$R1" $R2 $R3
			Rename "$R8\$R1" "$R8\$R1_$R3"
		${Else}
			; Delete "$R8\$R1"
			CRCCheck::GenCRC "$R8\$R1"
			Pop $R2
			CRCCheck::GenCRC "$R9"
			Pop $R3
			StrCmp $R2 $R3 +4 0
			CRCCheck::GenCRC "$R8\$R1_$lastflag"
			Pop $R3
			StrCmp $R2 $R3 0 +3
			Delete "$R8\$R1"
			goto +2
			Rename "$R8\$R1" "$R8\$R1_$R2"
		${EndIf}
	${ElseIf} ${FileExists} "$R8\$R1"
	${AndIf} $mergeflag != $lastflag
	${AndIf} $lastflag != ""
		Rename "$R8\$R1" "$R8\$R1_$lastflag"
	${ElseIf} ${FileExists} "$R8\$R1"
		${If} $R6 == ""
			GetFileTime "$R8\$R1" $R2 $R3
			Rename "$R8\$R1" "$R8\$R1_$R3"
		${Else}
			; Delete "$R8\$R1"
			CRCCheck::GenCRC "$R8\$R1"
			Pop $R2
			CRCCheck::GenCRC "$R9"
			Pop $R3
			StrCmp $R2 $R3 0 +3
			Delete "$R8\$R1"
			goto +2
			Rename "$R8\$R1" "$R8\$R1_$R2"
		${EndIf}
	${EndIf}
	Rename "$R9" "$R8\$R1"
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
	Push "continue"
FunctionEnd

; LangString ArchMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString ArchMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

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
	ReadINIStr $mergetype "$EXEDIR\$BaseName.ini" "$BaseName" "MergeType"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "MergeType" "|[no]/arch/language/both"
	StrCpy $mergetype "|[no]/arch/language/both"
/* 	System::Call '*(&i2,&i2,&i2,&i2,&i2,&i2,&i2,&i2) i .r8'
	System::Call 'kernel32::GetLocalTime(i)i(r8)'
	System::Call 'kernel32::SystemTimeToFileTime(i,*l)i(r8,.r9)'
	System::Free $8
	system::Int64Op $9 / 10000000
	Pop $9
	system::Int64Op $9 - 11644473600
	Pop $9 */
!macroend

; Function Pre              ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} RunLocally
; 	${RunSegment} Temp
; 	${RunSegment} Environment
; 	${RunSegment} ExecString
; FunctionEnd
${SegmentPre}
	${WordFind} "$mergetype" "|" "+1{" $mergetype
	${Switch} $mergetype
	${Case} "both"
	${Case} "arch"
		ReadEnvStr $0 "ProgramDir"
		StrCpy $mergeflag "$Bits"
		ReadINIStr $lastflag "$EXEDIR\$BaseName.ini" "$BaseName" "LastArch"
		ClearErrors
		${Locate} "$0" "/L=FD /G=0 /M=*_$mergeflag" "layoutmerge"
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LastArch" "$mergeflag"
	${EndSwitch}
	${Switch} $mergetype
	${Case} "both"
	${Case} "language"
		ReadEnvStr $0 "ProgramDir"
		ReadEnvStr $mergeflag "PAL:LanguageCustom"
		StrCmp $mergeflag "" 0 +2
		StrCpy $mergeflag "$LANGUAGE"
		ReadINIStr $lastflag "$EXEDIR\$BaseName.ini" "$BaseName" "LastLanguage"
		ClearErrors
		${Locate} "$0" "/L=FD /G=0 /M=*_$mergeflag" "layoutmerge"
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "LastLanguage" "$mergeflag"
	${EndSwitch}
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