
!include x64.nsh
!include servicelibnew.nsh

!ifndef VERSION_NUM
	!searchparse "${NSIS_VERSION}" "v" "VERSION_NUM"
!endif

!define CUSTOM_DEVICE 'yes'
!define DEVICESECPRIF "CustomDev"
!define DEVICECOMSEC "CustomCom"
!define DEVCMDPRIF "Dev"
!ifndef ORDERDELIMITER
	!define ORDERDELIMITER ","
	!define PLACEHOLDER "null"
!endif

Var DeviceServiceName
Var DeviceInf
Var DeviceInfHWID
Var DeviceInfPath
Var DeviceExePath

!ifndef BASEDIRFLAG
	Var FunBaseDir
	!define USEROS "OSMAP"
	!define USERARCH "ARCHMAP"
	!define BASEDIRFLAG "Y"
!endif
Var DevOprateCmd

!ifndef LANGFLAG
	LangString DirMessage1 1033 "Unable to get $0 default path, environment variable $0 not set."
	LangString DirMessage1 2052 "无法获取 $0 的默认路径，环境变量 $0 未设置。"
	!define LANGFLAG "Y"
!endif
LangString DevMessage1 1033 'The file path that executed the command was not found in the current \
program scope.$\n$DevOprateCmd$\nAre you sure you want to proceed? "Yes" to Continue; "No" to Skip.'
LangString DevMessage1 2052 "执行命令的文件路径，在当前程序范围未找到。$\n$DevOprateCmd$\n\
确认是否继续执行？“是”继续执行；“否”跳过执行。"
LangString DevMessage2 1033 'The file path that executed the command was not found in the current \
program scope.$\n$DevOprateCmd$\nAre you sure you want to proceed? "Yes" to Continue; "No" to Skip.'
LangString DevMessage2 2052 "执行命令的文件路径，在当前程序范围未找到。$\n$0\$1$\n\
将跳过执行安装，请确认路径。"

!ifndef FUNFLAG
	Function BaseDir
		Exch $0
		Push $1
		${If} ${RunningX64}
			ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "Launch" "ProgramExecutable64"
			${If} $1 != ""
			${AndIf} ${FileExists} "$EXEDIR\App\$1"
				${GetParent} "$EXEDIR\App\$1" $FunBaseDir
				System::Call 'Kernel32::SetEnvironmentVariable(t r0, t "$FunBaseDir")'
			${ElseIf} $1 == ""
				ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "Launch" "ProgramExecutable"
				${GetParent} "$EXEDIR\App\$1" $FunBaseDir
				System::Call 'Kernel32::SetEnvironmentVariable(t r0, t "$FunBaseDir")'
			${ElseIf} $1 != ""
				Abort "$(DirMessage1)"
			${EndIf}
		${Else}
			ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "Launch" "ProgramExecutable"
			${If} $1 != ""
			${AndIf} ${FileExists} "$EXEDIR\App\$1"
				${GetParent} "$EXEDIR\App\$1" $FunBaseDir
				System::Call 'Kernel32::SetEnvironmentVariable(t r0, t "$FunBaseDir")'
			${Else}
				Abort "$(DirMessage1)"
			${EndIf}
		${EndIf}
		Pop $1
		Exch $0
	FunctionEnd

	Function SetOsArch
		Push $0
		Push $1
		Push $2
		Push $3
		Push $4
		Push $5
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "CustomCom" "ArchMap"
		${If} $0 != ""
			${If} ${RunningX64}
				StrCpy $1 "64"
			${Else}
				StrCpy $1 "32"
			${EndIf}
			${WordFind} "$0" "," "#" $2
			${If} $2 >= 1
				StrCpy $3 "1"
				${Do}
					${WordFind} "$0" "," "+$3" $4
					${WordFind} "$4" "|" "#" $5
					${If} $5 == 2
						${WordFind} "$4" "|" "+1" $5
						${If} $5 == $1
							${WordFind} "$4" "|" "+2" $5
							System::Call 'Kernel32::SetEnvironmentVariable(t "${USERARCH}", t r5)'
						${EndIf}
					${EndIf}
					IntOp $3 $3 + 1
				${LoopUntil} $3 > $2
			${EndIf}
		${EndIf}
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "CustomCom" "OsMap"
		${If} $0 != ""
			${If} ${IsWinXP}
				StrCpy $1 "xp"
			${ElseIf} ${IsWin7}
				StrCpy $1 "7"
			${ElseIf} ${IsWin8}
				StrCpy $1 "8"
!if ${VERSION_NUM} >= 3
			${ElseIf} ${IsWin8.1}
				StrCpy $1 "8.1"
!endif
!if ${VERSION_NUM} >= 3
			${ElseIf} ${IsWin10}
				StrCpy $1 "10"
!endif
			${ElseIf} ${IsWin2003}
				StrCpy $1 "2003"
			${ElseIf} ${IsWin2008}
				StrCpy $1 "2008"
			${ElseIf} ${IsWin2008R2}
				StrCpy $1 "2008R2"
			${ElseIf} ${IsWin2012}
				StrCpy $1 "2012"
!if ${VERSION_NUM} >= 3
			${ElseIf} ${IsWin2012R2}
				StrCpy $1 "2012R2"
!endif
			${Else}
				StrCpy $1 "other"
			${EndIf}
			${WordFind} "$0" "," "#" $2
			${If} $2 >= 1
				StrCpy $3 "1"
				${Do}
					${WordFind} "$0" "," "+$3" $4
					${WordFind} "$4" "|" "#" $5
					${If} $5 == 2
						${WordFind} "$4" "|" "+1" $5
						${If} $5 == $1
							${WordFind} "$4" "|" "+2" $5
							System::Call 'Kernel32::SetEnvironmentVariable(t "${USEROS}", t r5)'
						${EndIf}
					${EndIf}
					IntOp $3 $3 + 1
				${LoopUntil} $3 > $2
			${EndIf}
		${EndIf}
		Pop $5
		Pop $4
		Pop $3
		Pop $2
		Pop $1
		Pop $0
	FunctionEnd

	Function PathParse
		Exch $0
		Push $1
		ExpandEnvStrings $0 "$0"
		${GetRoot} "$0" $1
		${if} $1 == ""
			StrCpy $1 "$FunBaseDir" "" -1
			${If} $1 == "\"
				StrCpy $0 "$FunBaseDir$0"
			${Else}
				StrCpy $0 "$FunBaseDir\$0"
			${EndIf}
			GetFullPathName $0 "$0"
		${Else}
			GetFullPathName $0 "$0"
		${EndIf}
		Pop $1
		Exch $0
	FunctionEnd
	!define FUNFLAG "Y"
!endif

Function InstallDevice
	${ReadLauncherConfig} $0 "Custom" "Device"
	${If} $0 == true
		${If} ${RunningX64}
			${DisableX64FSRedirection}
			SetRegView 64
		${EndIf}
		; ${ReadLauncherConfig} $DevOprateCmd "${DEVICECOMSEC}" "DevInstallCmd"
		${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "DevInstallCmd=" $DevOprateCmd
		; ReadINIStr $DevOprateCmd "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${DEVICECOMSEC}" "DevInstallCmd"
		${If} $DevOprateCmd != ""
		${AndIf} $DevOprateCmd != ${PLACEHOLDER}
			${ReadLauncherConfig} $0 "${DEVICECOMSEC}" "CmdDelimiter"
			${GetOptions} '$0DevOprateCmd=$DevOprateCmd' '$0DevOprateCmd=' $1
			ReadEnvStr $FunBaseDir "DeviceDir"
			Push $1
			call PathParse
			Pop $2
			${If} $2 != ""
			${AndIf} ${FileExists} "$2"
				${WordReplace} "$DevOprateCmd" "$1" "$2" "+1" $DevOprateCmd
			${Else}
				MessageBox MB_YESNO "$(DevMessage1)" IDYES +2
				StrCpy $DevOprateCmd ""
			${EndIf}
			; MessageBox MB_OK '$0||$DevOprateCmd'
			${If} $DevOprateCmd != ""
				ExpandEnvStrings $DevOprateCmd "$DevOprateCmd"
				ExecDos::exec /DISABLEFSR '$DevOprateCmd' '' ''
				; ExecWait '$DevOprateCmd'
			${EndIf}
			Goto SKIPDEVSEC
		${EndIf}
		${ReadLauncherConfig} $0 "${DEVICECOMSEC}" "DevExeDir"
		${If} ${RunningX64}
			${ReadLauncherConfig} $1 "${DEVICECOMSEC}" "DevExe64"
			StrCpy $DeviceExePath "$0\$1"
		${Else}
			${ReadLauncherConfig} $1 "${DEVICECOMSEC}" "DevExe"
			StrCpy $DeviceExePath "$0\$1"
		${EndIf}
		ReadEnvStr $FunBaseDir "DeviceDir"
		Push $DeviceExePath
		call PathParse
		Pop $DeviceExePath
		${If} $DeviceExePath == ""
			ExecShell open "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" SW_SHOWDEFAULT
			MessageBox MB_OK "$(DevMessage2)" IDOK SKIPDEVSEC
		${EndIf}
		${ReadLauncherConfig} $R2 "${DEVICECOMSEC}" "DevInsOrder"
		${If} $R2 != ""
			${WordFind} "$R2" "${ORDERDELIMITER}" "#" $R1
			${If} $R1 < 2
				StrCpy $R0 1
				StrCpy $R1 0
			${EndIf}
		${Else}
			StrCpy $R0 1
			StrCpy $R1 0
		${EndIf}
		${Do}
			${If} $R1 >= 1
				${WordFind} "$R2" "${ORDERDELIMITER}" "-$R1" $R0
			${EndIf}
			ClearErrors
			${ReadLauncherConfig} $DeviceServiceName "${DEVICESECPRIF}$R0" "DevServName"
			${ReadLauncherConfig} $DeviceInf "${DEVICESECPRIF}$R0" "DevInf"
			${ReadLauncherConfig} $DeviceInfHWID "${DEVICESECPRIF}$R0" "DevInfHWID"
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			!insertmacro SERVICE "status" "$DeviceServiceName" ""
			Pop $0
			${ReadLauncherConfig} $1 "${DEVICESECPRIF}$R0" "RemoveFlag"
			; MessageBox MB_OK '$0||$1'
			${If} $0 != false
			${AndIf} $1 != true
				IntOp $R3 $R3 + 1
				${Continue}
			${EndIf}
			StrCpy $R3 1
			${Do}
				ClearErrors
				; ${ReadLauncherConfig} $DevOprateCmd "${DEVICESECPRIF}$R0" "${DEVCMDPRIF}$R0Install$R3"
				${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
				"${DEVCMDPRIF}$R0Install$R3=" $DevOprateCmd
				/* ReadINIStr $DevOprateCmd "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
				"${DEVICESECPRIF}$R0" "${DEVCMDPRIF}Install$R3" */
				; MessageBox MB_OK "${DEVCMDPRIF}$R0Install$R3[Errors]${Errors}"
				${IfThen} ${Errors} ${|} ${ExitDo} ${|}
				${If} $DevOprateCmd != ""
				${AndIf} $DevOprateCmd != ${PLACEHOLDER}
					${ReadLauncherConfig} $1 "${DEVICESECPRIF}$R0" "CmdDelimiter"
					${GetOptions} '$1Cmd=$DevOprateCmd' '$1Cmd=' $2
					ReadEnvStr $FunBaseDir "DeviceDir"
					Push $2
					call PathParse
					Pop $3
					${If} $3 != ""
					${AndIf} ${FileExists} "$3"
						${WordReplace} "$DevOprateCmd" "$2" "$3" "+1" $DevOprateCmd
					${Else}
						MessageBox MB_YESNO "$(DevMessage1)" IDYES +2
						StrCpy $DevOprateCmd ""
					${EndIf}
					${If} $DevOprateCmd != ""
						ExpandEnvStrings $DevOprateCmd "$DevOprateCmd"
						; MessageBox MB_OK "$DevOprateCmd"
						; ExecDos::exec '$DevOprateCmd' '' '$EXEDIR\dev.log'
						ExecDos::exec /DISABLEFSR '$DevOprateCmd' '' '$EXEDIR\dev.log'
						; ExecWait '$DevOprateCmd'
					${EndIf}
				${EndIf}
				IntOp $R3 $R3 + 1
			${Loop}
			${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${DEVCMDPRIF}$R0Install1=" $0
			/* ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${DEVICESECPRIF}$R0" \
			"${DEVCMDPRIF}Install1" */
			${If} $0 == ""
			${OrIf} $0 == ${PLACEHOLDER}
				${ReadLauncherConfig} $DeviceInfPath "${DEVICECOMSEC}" "InfDir"
				StrCpy $DeviceInfPath "$DeviceInfPath\$DeviceInf"
				ReadEnvStr $FunBaseDir "DeviceDir"
				Push $DeviceInfPath
				Call PathParse
				Pop $DeviceInfPath
				; MessageBox MB_OK "$DeviceInfPath"
				ExecDos::exec /DISABLEFSR /TOSTACK '"$DeviceExePath" status "$DeviceInfHWID"' '' ''
				Pop $0
				Pop $0
				; MessageBox MB_OK "Status=$0"
				${If} $0 == "No matching devices found."
					; MessageBox MB_OK '"$DeviceExePath" install "$DeviceInfPath" "$DeviceInfHWID"'
					ExecDos::exec /DISABLEFSR /TOSTACK '"$DeviceExePath" install "$DeviceInfPath" "$DeviceInfHWID"' '' ''
					; Pop $0
					!insertmacro SERVICE "start" "$DeviceServiceName" ""
				${EndIf}
			${EndIf}
			${If} $R1 >= 0
				IntOp $R1 $R1 - 1
			${EndIf}
			IntOp $R0 $R0 + 1
			; MessageBox MB_OK "$R0, $R1, $R2, $R3"
		${LoopWhile} $R1 != 0
		${If} $X64FSRFlag == "disable"
			${DisableX64FSRedirection}
		${Else}
			${EnableX64FSRedirection}
		${EndIf}
		; SetRegView lastused
		${If} $RegViewFlag == 64
			SetRegView 64
		${Else}
			SetRegView 32
		${EndIf}
	${EndIf}
	SKIPDEVSEC:
FunctionEnd

Function UnInstallDevice
	${ReadLauncherConfig} $0 Custom Device
	${If} $0 == true
		${If} ${RunningX64}
			${DisableX64FSRedirection}
			SetRegView 64
		${EndIf}
		; ${ReadLauncherConfig} $DevOprateCmd "${DEVICECOMSEC}" "DevUninstallCmd"
		${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "DevUninstallCmd=" $DevOprateCmd
		; ReadINIStr $DevOprateCmd "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${DEVICECOMSEC}" "DevUninstallCmd"
		${If} $DevOprateCmd != ""
		${AndIf} $DevOprateCmd != ${PLACEHOLDER}
			${ReadLauncherConfig} $0 "${DEVICECOMSEC}" "CmdDelimiter"
			${GetOptions} '$0DevOprateCmd=$DevOprateCmd' '$0DevOprateCmd=' $1
			ReadEnvStr $FunBaseDir "DeviceDir"
			Push $1
			call PathParse
			Pop $2
			${If} $2 != ""
			${AndIf} ${FileExists} "$2"
				${WordReplace} "$DevOprateCmd" "$1" "$2" "+1" $DevOprateCmd
			${Else}
				MessageBox MB_YESNO "$(DevMessage1)" IDYES +2
				StrCpy $DevOprateCmd ""
			${EndIf}
			; MessageBox MB_OK "$0||$DevOprateCmd"
			${If} $DevOprateCmd != ""
				ExpandEnvStrings $DevOprateCmd "$DevOprateCmd"
				; ExecDos::exec '$DevOprateCmd' '' ''
				ExecDos::exec /DISABLEFSR '$DevOprateCmd' '' ''
				; ExecWait '$DevOprateCmd'
			${EndIf}
			Goto SKIPUNDEVSEC
		${EndIf}
		${ReadLauncherConfig} $R2 "${DEVICECOMSEC}" "DevUninsOrder"
		${If} $R2 != ""
			${WordFind} "$R2" "${ORDERDELIMITER}" "#" $R1
			${If} $R1 < 2
				StrCpy $R0 1
				StrCpy $R1 0
			${EndIf}
		${Else}
			StrCpy $R0 1
			StrCpy $R1 0
		${EndIf}
		${Do}
			${If} $R1 >= 1
				${WordFind} "$R2" "${ORDERDELIMITER}" "-$R1" $R0
			${EndIf}
			ClearErrors
			${ReadLauncherConfig} $DeviceServiceName "${DEVICESECPRIF}$R0" "DevServName"
			${ReadLauncherConfig} $DeviceInf "${DEVICESECPRIF}$R0" "DevInf"
			${ReadLauncherConfig} $DeviceInfHWID "${DEVICESECPRIF}$R0" "DevInfHWID"
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ReadLauncherConfig} $0 "${DEVICESECPRIF}$R0" "RemoveFlag"
			${If} $0 == true
				StrCpy $R3 1
				${Do}
					ClearErrors
					; ${ReadLauncherConfig} $DevOprateCmd ${DEVICESECPRIF}$R0 ${DEVCMDPRIF}$R0UnInstall$R3
					${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
					"${DEVCMDPRIF}$R0UnInstall$R3=" $DevOprateCmd
					/* ReadINIStr $DevOprateCmd "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
					"${DEVICESECPRIF}$R0" "${DEVCMDPRIF}UnInstall$R3" */
					${IfThen} ${Errors} ${|} ${ExitDo} ${|}
					${If} $DevOprateCmd != ""
					${AndIf} $DevOprateCmd != ${PLACEHOLDER}
						${ReadLauncherConfig} $1 "${DEVICESECPRIF}$R0" "CmdDelimiter"
						${GetOptions} '$1Cmd=$DevOprateCmd' '$1Cmd=' $2
						ReadEnvStr $FunBaseDir "DeviceDir"
						Push $2
						call PathParse
						Pop $3
						${If} $3 != ""
						${AndIf} ${FileExists} "$3"
							${WordReplace} "$DevOprateCmd" "$2" "$3" "+1" $DevOprateCmd
						${Else}
							MessageBox MB_YESNO "$(DevMessage1)" IDYES +2
							StrCpy $DevOprateCmd ""
						${EndIf}
						${If} $DevOprateCmd != ""
							ExpandEnvStrings $DevOprateCmd "$DevOprateCmd"
							; ExecDos::exec '$DevOprateCmd' '' ''
							; ExecDos::exec /DISABLEFSR '$DevOprateCmd' '' ''
							ExecWait '$DevOprateCmd'
						${EndIf}
					${EndIf}
					IntOp $R3 $R3 + 1
				${Loop}
				${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${DEVCMDPRIF}$R0UnInstall1=" $0
				/* ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${DEVICESECPRIF}$R0" \
				"${DEVCMDPRIF}UnInstall1" */
				${If} $0 != ""
				${AndIf} $0 != ${PLACEHOLDER}
					Goto SKIPUNINF
				${EndIf}
				ExecDos::exec /DISABLEFSR '"$DeviceExePath" remove "$DeviceInfHWID"' '' ''
				!insertmacro SERVICE "stop" "$DeviceServiceName" ""
				!insertmacro SERVICE "delete" "$DeviceServiceName" ""
			${Else}
				${ReadLauncherConfig} $0 "${DEVICESECPRIF}$R0" "StartType"
				${If} $0 != ""
				${AndIf} $0 != ${PLACEHOLDER}
					; !insertmacro SERVICE "stop" "$DeviceServiceName" ""
					!insertmacro SERVICE "config" "$DeviceServiceName" "starttype=$0;"
					; Pop $0
					; MessageBox MB_OK "$0"
				${EndIf}	
			${EndIf}
			SKIPUNINF:
			${If} $R1 >= 0
				IntOp $R1 $R1 - 1
			${EndIf}
			IntOp $R0 $R0 + 1
			; MessageBox MB_OK "$R0, $R1, $R2"
		${LoopWhile} $R1 != 0
		${If} $X64FSRFlag == "disable"
			${DisableX64FSRedirection}
		${Else}
			${EnableX64FSRedirection}
		${EndIf}
		; SetRegView lastused
		${If} $RegViewFlag == 64
			SetRegView 64
		${Else}
			SetRegView 32
		${EndIf}
	${EndIf}
	SKIPUNDEVSEC:
FunctionEnd