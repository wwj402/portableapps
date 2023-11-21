/*
$LauncherFile=z:\PortableAppz\ReplaceStudioPortable\App\AppInfo\Launcher\ReplaceStudioPortable.ini
$EXEFILE=ReplaceStudioPortable.exe
$AppID=ReplaceStudioPortable
$BaseName=ReplaceStudioPortable
$EXEDIR=z:\PortableAppz\ReplaceStudioPortable
*/

/* 
Function .onInit          ;{{{1
	${RunSegment} Custom
	${RunSegment} Core
	${RunSegment} Temp
	${RunSegment} Language
	${RunSegment} OperatingSystem
	${RunSegment} RunAsAdmin
FunctionEnd

Function Init             ;{{{1
	${RunSegment} Custom
	${RunSegment} Core
	${RunSegment} PathChecks
	${RunSegment} Settings
	${RunSegment} DriveLetter
	${RunSegment} DirectoryMoving
	${RunSegment} Variables
	${RunSegment} Language
	${RunSegment} Registry
	${RunSegment} Java
	${RunSegment} RunLocally
	${RunSegment} Temp
	${RunSegment} InstanceManagement
	${RunSegment} SplashScreen
	${RunSegment} RefreshShellIcons
FunctionEnd

Function Pre              ;{{{1
	${RunSegment} Custom
	${RunSegment} RunLocally
	${RunSegment} Temp
	${RunSegment} Environment
	${RunSegment} ExecString
FunctionEnd

Function PrePrimary       ;{{{1
	${RunSegment} Custom
	${RunSegment} DriveLetter
	${RunSegment} Variables
	${RunSegment} DirectoryMoving
	${RunSegment} FileWrite
	${RunSegment} FilesMove
	${RunSegment} DirectoriesMove
	;${RunSegment} RegisterDLL
	${RunSegment} RegistryKeys
	${RunSegment} RegistryValueBackupDelete
	${RunSegment} RegistryValueWrite
	${RunSegment} Services
FunctionEnd

Function PreSecondary     ;{{{1
	${RunSegment} Custom
	;${RunSegment} *
FunctionEnd

Function PreExec          ;{{{1
	${RunSegment} Custom
	${RunSegment} RefreshShellIcons
	${RunSegment} WorkingDirectory
FunctionEnd

Function PreExecPrimary   ;{{{1
	${RunSegment} Custom
	${RunSegment} Core
	${RunSegment} SplashScreen
FunctionEnd

Function PreExecSecondary ;{{{1
	${RunSegment} Custom
	;${RunSegment} *
FunctionEnd

Function PostPrimary      ;{{{1
	${RunSegment} Services
	${RunSegment} RegistryValueBackupDelete
	${RunSegment} RegistryKeys
	${RunSegment} RegistryCleanup
	;${RunSegment} RegisterDLL
	${RunSegment} Qt
	${RunSegment} DirectoriesMove
	${RunSegment} FilesMove
	${RunSegment} DirectoriesCleanup
	${RunSegment} RunLocally
	${RunSegment} Temp
	${RunSegment} Custom
FunctionEnd

Function PostSecondary    ;{{{1
	;${RunSegment} *
	${RunSegment} Custom
FunctionEnd

Function Post             ;{{{1
	${RunSegment} RefreshShellIcons
	${RunSegment} Custom
FunctionEnd
 */

${SegmentFile}

!addincludedir "${PACKAGE}\App\AppInfo\Launcher"
!include "x64.nsh"
; !include "Custom_service.nsh"
; !include "Custom_device.nsh"
; !include "Custom_link.nsh"
; !include "Custom_dll.nsh"
; !include "Custom_patch.nsh"

LangString LangMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
LangString LangMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"
Var OSarch

${SegmentInit}

	; Call BaseDir

	${SetEnvironmentVariable} PORTABLEBASEDIR $EXEDIR
	${SetEnvironmentVariable} PORTABLEBASENAME $BaseName
	${SetEnvironmentVariable} PORTABLEEXEFILE $EXEFILE
	SetShellVarContext all
	${SetEnvironmentVariable} ALLUSERDOCUMENTS $DOCUMENTS

	${LineSum} "$EXEDIR\$BaseName.ini" $0
	${IfNot} ${FileExists} "$EXEDIR\$BaseName.ini"
	${OrIf} $0 < 10
		; IfFileExists "$EXEDIR\$BaseName.ini" +10 0
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" UserName ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" AdditionalParameters ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" DisableSplashScreen "true"
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" RunLocally "false"
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" SingleAppInstance ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" SinglePortableAppInstance ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" AlwaysUse32Bit ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" X64RegView ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" X64FSRedirection "true"
	${EndIf}

	${If} ${RunningX64}
		StrCpy $OSarch 64
		/* ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" X64RegView
		${If} $0 == 64
			SetRegView 64
		${EndIf}
		ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" X64FSRedirection
		${If} $0 == false
			${DisableX64FSRedirection}
		${EndIf} */
	${EndIf}

	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" AlwaysUse32Bit
	${If} $0 == true
		StrCpy $Bits 32
	${EndIf}

	${If} $Bits == 64
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable64
		${If} $0 != ""
		${AndIf} ${FileExists} "$EXEDIR\App\$0"
			ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" X64RegView
			${If} $0 == 32
				SetRegView 32
			${Else}
				SetRegView 64
			${EndIf}
			${GetParent} "$EXEDIR\App\$0" $1
			${SetEnvironmentVariable} ProgramDir $1
		${Else}
		 	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" X64RegView
			${If} $0 == 64
				SetRegView 64
			${EndIf}
			ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" X64FSRedirection
			${If} $0 == false
				${DisableX64FSRedirection}
			${EndIf}
			ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable
			${GetParent} "$EXEDIR\App\$0" $1
			${SetEnvironmentVariable} ProgramDir $1
		${EndIf}
	${EndIf}
	${If} $Bits == 32
		${If} $OSarch == 64
			ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" X64RegView
			${If} $0 == 64
				SetRegView 64
			${EndIf}
			ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" X64FSRedirection
			${If} $0 == false
				${DisableX64FSRedirection}
			${EndIf}
		${EndIf}
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable	
		${GetParent} "$EXEDIR\App\$0" $1
		${SetEnvironmentVariable} ProgramDir $1
	${EndIf}

	ClearErrors
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" UserName
	${IfNot} ${Errors}
	${AndIf} $0 != ""
		${SetEnvironmentVariable} ProfileUserName $0
	${EndIf}

	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" SingleAppInstance
	${If} $0 == false
	${OrIf} $0 == true
		WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch SingleAppInstance $0
	${EndIf}
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" SinglePortableAppInstance
	${If} $0 == false
	${OrIf} $0 == true
		WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch SinglePortableAppInstance $0
	${EndIf}

!macroend

${SegmentPre}
	Nop
	; Call CreateLink
!macroend

${SegmentPrePrimary}
	Nop
	; Call InstallDevice
	; Call InstallService
!macroend

${SegmentPreSecondary}

	${GetFileName} $ProgramExecutable $0
	${GetProcessPID} "$0" $1
	${If} $1  <= 0
		ClearErrors
		ReadINIStr $2 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "Custom" "RealRunExe"
		${If} ${Errors}
			MessageBox MB_OK "$(LangMessage1)"
			Quit
		${Else}
			${GetProcessPID} "$2" $1
			${If} $1  <= 0
				MessageBox MB_OK "$(LangMessage1)"
				Quit
			${EndIf}
		${EndIf}
	${EndIf}

!macroend

${SegmentPreExec}

	ClearErrors
	ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch WorkingDirectory
	${IfNot} ${Errors}
	${AndIf} $0 != ""
		ExpandEnvStrings $0 "$0"
		IfFileExists "$0\*.*" +2 0
		CreateDirectory "$0"
	${EndIf}

	ClearErrors
	${ReadLauncherConfig} $0 Environment HOME
	${IfNot} ${Errors}
	${AndIf} $0 != ""
		ExpandEnvStrings $0 "$0"
		IfFileExists "$0\*.*" +2 0
		CreateDirectory "$0"
	${EndIf}

	; Call RegsvrDll

!macroend

${SegmentPreExecPrimary}
	Nop
!macroend

${SegmentPreExecSecondary}
	Nop
!macroend

${OverrideExecute}

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

	; Call UnRegsvrDll

!macroend

${SegmentPostPrimary}
	Nop
	; Call UnInstallDevice
	; Call UnInstallService
	; Call RemoveLink
!macroend

${SegmentPostSecondary}
	Nop
!macroend

${SegmentPost}
	Nop
!macroend