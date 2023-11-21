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

!define USERFONTSDIR "Windows\Fonts"
!define FONTSMODE "|[no]/autoremove/keep"
Var fontsmode
Var fontspath

; LangString PatchMessage1 1033 "It is possible that the program is exiting.\
; $\r$\nPlease wait for the program to exit completely and then run again."
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

; https://nsis.sourceforge.io/FontInfo_plug-in
; https://nsis.sourceforge.io/Installing_fonts
!macro FontInstallHelper FontFileSrc FontFileDst FontInternalName Resource RegSuffix RegRoot
ClearErrors
${IfNot} ${FileExists} "${FontFileDst}"
	; File "/oname=${FontFileDst}" "${FontFileSrc}"
	CopyFiles "${FontFileSrc}" "${FontFileDst}"
${EndIf}
${IfNot} ${Errors}
	Push $0
	Push "${Resource}"
	Exch $1
	Push "${FontInternalName}${RegSuffix}"
	Exch $2
	Push $9
	StrCpy $9 "Software\Microsoft\Windows NT\CurrentVersion\Fonts"
	!if "${NSIS_CHAR_SIZE}" < 2
	ReadRegStr $0 ${RegRoot} "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
	${IfThen} $0 == "" ${|} StrCpy $9 "Software\Microsoft\Windows\CurrentVersion\Fonts" ${|}
	!endif
	System::Call 'GDI32::AddFontResource(tr1)i.r0'
	${If} $0 <> 0
		WriteRegStr ${RegRoot} "$9" "$2" "$1"
	${Else}
		SetErrors
	${EndIf}
	Pop $9
	Pop $2
	Pop $1
	Pop $0
${Else}
	SetErrors
${EndIf}
!macroend
!macro FontInstallTTF FontFileSrc FontFileName FontInternalName
!insertmacro FontInstallHelper "${FontFileSrc}" "$Fonts\${FontFileName}" "${FontInternalName}" "${FontFileName}" " (TrueType)" HKLM
!macroend
 
!macro FontUninstallHelper FontFileDst FontInternalName Resource RegSuffix RegRoot
System::Call 'GDI32::RemoveFontResource(t"${Resource}")'
DeleteRegValue ${RegRoot} "Software\Microsoft\Windows NT\CurrentVersion\Fonts" "${FontInternalName}${RegSuffix}"
!if "${NSIS_CHAR_SIZE}" < 2
DeleteRegValue ${RegRoot} "Software\Microsoft\Windows\CurrentVersion\Fonts" "${FontInternalName}${RegSuffix}"
!endif
ClearErrors
Delete "${FontFileDst}"
!macroend
!macro FontUninstallTTF FontFileName FontInternalName
!insertmacro FontUninstallHelper "$Fonts\${FontFileName}" "${FontInternalName}" "${FontFileName}" " (TrueType)" HKLM
!macroend

Function "fontsinstall"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $0
	${If} $R6 != ""
		IfFileExists "$Fonts\$R7" SKIP 0
		FontInfo::GetFontName "$R9"
		!insertmacro FontInstallTTF "$R9" "$R7" "$0"
		IfErrors 0 +3
		WriteINIStr "$EXEDIR\$BaseName.ini" "Fonts" "$R7" "error"
		Goto +2
		WriteINIStr "$EXEDIR\$BaseName.ini" "Fonts" "$R7" "installed"
		Goto +2
		SKIP:
		WriteINIStr "$EXEDIR\$BaseName.ini" "Fonts" "$R7" ""
	${EndIf}
	Pop $0
	Push "continue"
FunctionEnd

Function "fontsuninstall"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $0
	${If} $R6 != ""
		ReadINIStr $0 "$EXEDIR\$BaseName.ini" "Fonts" "$R7"
		StrCmp $0 "installed" 0 SKIP
		FontInfo::GetFontName "$R9"
		!insertmacro FontUninstallTTF "$R7" "$0"
		IfErrors 0 +3
		WriteINIStr "$EXEDIR\$BaseName.ini" "Fonts" "$R7" "error"
		Goto +2
		WriteINIStr "$EXEDIR\$BaseName.ini" "Fonts" "$R7" ""
		SKIP:
	${EndIf}
	Pop $0
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
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "FontsMode"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "FontsMode" "${FONTSMODE}"
	StrCpy $strtemp "${FONTSMODE}"
	ClearErrors
	ReadINIStr $fontspath "$EXEDIR\$BaseName.ini" "$BaseName" "UserFontsDir"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "UserFontsDir" "${USERFONTSDIR}"
	StrCpy $fontspath "${USERFONTSDIR}"
!macroend

; Function Pre              ;{{{1
; 	${RunSegment} Custom
; 	${RunSegment} RunLocally
; 	${RunSegment} Temp
; 	${RunSegment} Environment
; 	${RunSegment} ExecString
; FunctionEnd
${SegmentPre}
	${WordFind} "$strtemp" "|" "+1{" $fontsmode
	!insertmacro path_canonicalize "$EXEDIR\App" $fontspath
	${If} $fontsmode != ""
	${AndIf} ${FileExists} "$fontspath"
		${Switch} $fontsmode
		${Case} "keep"
			ReadINIStr $0 "$EXEDIR\$BaseName.ini" "Fonts" "Install"
			${If} $0 == "true"
				${Break}
			${EndIf}
		${Case} "autoremove"
			ClearErrors
			${Locate} "$fontspath" "" "fontsinstall"
			IfErrors 0 +3
			WriteINIStr "$EXEDIR\$BaseName.ini" "Fonts" "Install" "error"
			Goto +2
			WriteINIStr "$EXEDIR\$BaseName.ini" "Fonts" "Install" "true"
		${EndSwitch}
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
	${WordFind} "$strtemp" "|" "+1{" $fontsmode
	!insertmacro path_canonicalize "$EXEDIR\App" $fontspath
	${If} $fontsmode != ""
	${AndIf} ${FileExists} "$fontspath"
		${Switch} $fontsmode
		${Case} "autoremove"
			ClearErrors
			${Locate} "$fontspath" "" "fontsuninstall"
			IfErrors 0 +3
			WriteINIStr "$EXEDIR\$BaseName.ini" "Fonts" "Install" "error"
			Goto +2
			WriteINIStr "$EXEDIR\$BaseName.ini" "Fonts" "Install" ""
		${EndSwitch}
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