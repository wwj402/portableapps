
!include x64.nsh
!include servicelibnew.nsh

!ifndef VERSION_NUM
	!searchparse "${NSIS_VERSION}" "v" "VERSION_NUM"
!endif

!define CUSTOM_SERVICE 'yes'
!define SERVICESECPRIF "CustomServ"
!define SERVICECOMSEC "CustomCom"
!define SERVCMDPRIF "Serv"
!ifndef ORDERDELIMITER
	!define ORDERDELIMITER ","
	!define PLACEHOLDER "null"
!endif

Var ServiceImage
Var ServiceOldImage
Var ServiceName
Var ServiceDepend
Var ServiceUser
Var ServiceDisplay
Var ServiceStartType
Var ServiceServiceType

!ifndef BASEDIRFLAG
	Var FunBaseDir
	!define USEROS "OSMAP"
	!define USERARCH "ARCHMAP"
	!define BASEDIRFLAG "Y"
!endif
Var ServiceInstallType
Var ServInstallCmd
Var ServUninstallCmd
Var ServOprateCmd

!ifndef LANGFLAG
	LangString DirMessage1 1033 "Unable to get $0 default path, environment variable $0 not set."
	LangString DirMessage1 2052 "无法获取 $0 的默认路径，环境变量 $0 未设置。"
	!define LANGFLAG "Y"
!endif
LangString ServMessage1 1033 'The file path that executed the command was not found in the current \
program scope.$\n$ServOprateCmd$\nAre you sure you want to proceed? "Yes" to Continue; "No" to Skip.'
LangString ServMessage1 2052 "执行命令的文件路径，在当前程序范围未找到。$\n$ServOprateCmd$\n\
确认是否继续执行？“是”继续执行；“否”跳过执行。"
LangString ServMessage2 1033 '$servicename service has been installed. $\nClick "yes" to reinstall; $\n\
"No" skip installation.'
LangString ServMessage2 2052 '$ServiceName 服务已经安装。$\n“是”重新安装；$\n“否”跳过安装。'

Function ServiceImagePath
	Exch $0
	Push $1
	Push $2
	ExpandEnvStrings  $0 "$0"
	${GetFileName} $SYSDIR $1
	; MessageBox MB_OK "$0$\n$1"
	${WordFind} "$0" "\" "+1" $2
	${If} $1 == $2
		StrCpy $0 "$WINDIR\$0"
	${EndIf}
	${WordReplace} "$0" "\systemroot" "$WINDIR" "+*" $0
	${WordReplace} "$0" "\??\" "" "+1*" $0

	; MessageBox MB_OK "$0"
	Pop $2
	Pop $1
	Exch $0
FunctionEnd

!ifndef FUNFLAG
	Function BaseDir
		Exch $0
		Push $1
		${If} ${RunningX64}
			ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable64
			${If} $1 != ""
			${AndIf} ${FileExists} "$EXEDIR\App\$1"
				${GetParent} "$EXEDIR\App\$1" $FunBaseDir
				System::Call 'Kernel32::SetEnvironmentVariable(t r0, t "$FunBaseDir")'
			${ElseIf} $1 == ""
				ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable
				${GetParent} "$EXEDIR\App\$1" $FunBaseDir
				System::Call 'Kernel32::SetEnvironmentVariable(t r0, t "$FunBaseDir")'
			${ElseIf} $1 != ""
				Abort "$(DirMessage1)"
			${EndIf}
		${Else}
			ReadINIStr $1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable
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
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" CustomCom ArchMap
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
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" CustomCom OsMap
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
		${EndIf}
		GetFullPathName $0 "$0"
		StrCpy $1 "$0" "" -1
		${If} $1 == "\"
			StrCpy $0 "$0" -1
		${EndIf}
		Pop $1
		Exch $0
	FunctionEnd
	!define FUNFLAG "Y"
!endif

Function InstallService
	${ReadLauncherConfig} $0 Custom Service
	${If} $0 == true
		${If} ${RunningX64}
			${DisableX64FSRedirection}
			SetRegView 64
		${EndIf}
		${ReadLauncherConfig} $ServOprateCmd ${SERVICECOMSEC} ServInstallCmd
		${If} $ServOprateCmd != ""
		${AndIf} $ServOprateCmd != ${PLACEHOLDER}
			${ReadLauncherConfig} $1 ${SERVICECOMSEC} CmdDelimiter
			${GetOptions} '$1ServInstallCmd=$ServOprateCmd' '$1ServInstallCmd=' $2
			ReadEnvStr $FunBaseDir ServiceDir
			Push $2
			call PathParse
			Pop $3
			${If} $3 != ""
			${AndIf} ${FileExists} "$3"
				${WordReplace} "$ServOprateCmd" "$2" "$3" "+1" $ServOprateCmd
			${Else}
				MessageBox MB_YESNO "$(ServMessage1)" IDYES +2
				StrCpy $ServOprateCmd ""
			${EndIf}
			${If} $ServOprateCmd != ""
				ExpandEnvStrings $ServOprateCmd "$ServOprateCmd"
				; MessageBox MB_OK "$ServOprateCmd"
				; ExecDos::exec '$ServOprateCmd' '' ''
				; ExecDos::exec /DISABLEFSR '$ServOprateCmd' '' ''
				ExecWait '$ServOprateCmd'
			${EndIf}
			Goto SKIPSERVSEC
		${EndIf}
		${ReadLauncherConfig} $R2 ${SERVICECOMSEC} ServInsOrder
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
			${ReadLauncherConfig} $ServiceName ${SERVICESECPRIF}$R0 Name
			${If} ${RunningX64}
				${ReadLauncherConfig} $ServiceImage ${SERVICESECPRIF}$R0 Path64
				${If} $ServiceImage == ""
					${ReadLauncherConfig} $ServiceImage ${SERVICESECPRIF}$R0 Path
				${EndIf}
			${Else}
				${ReadLauncherConfig} $ServiceImage ${SERVICESECPRIF}$R0 Path
			${EndIf}
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			StrCpy $R3 1
			${Do}
				ClearErrors
				; ${ReadLauncherConfig} $ServOprateCmd ${SERVICESECPRIF}$R0 ${SERVCMDPRIF}$R0Install$R3
				${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
				"${SERVCMDPRIF}$R0Install$R3=" $ServOprateCmd
				${IfThen} ${Errors} ${|} ${ExitDo} ${|}
				${If} $ServOprateCmd != ""
				${AndIf} $ServOprateCmd != ${PLACEHOLDER}
					${ReadLauncherConfig} $1 ${SERVICESECPRIF}$R0 CmdDelimiter
					${GetOptions} '$1Cmd=$ServOprateCmd' '$1Cmd=' $2
					ReadEnvStr $FunBaseDir ServiceDir
					Push $2
					call PathParse
					Pop $3
					${If} $3 != ""
					${AndIf} ${FileExists} "$3"
						${WordReplace} "$ServOprateCmd" "$2" "$3" "+1" $ServOprateCmd
					${Else}
						MessageBox MB_YESNO "$(ServMessage1)" IDYES +2
						StrCpy $ServOprateCmd ""
					${EndIf}
					${If} $ServOprateCmd != ""
						ExpandEnvStrings $ServOprateCmd "$ServOprateCmd"
						; MessageBox MB_OK "$ServOprateCmd"
						; ExecDos::exec '$ServOprateCmd' '' ''
						; ExecDos::exec /DISABLEFSR '$ServOprateCmd' '' ''
						ExecWait '$ServOprateCmd'
					${EndIf}
				${EndIf}
				IntOp $R3 $R3 + 1
			${Loop}
			${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${SERVCMDPRIF}$R0Install1=" $0
			${If} $0 == ""
			${OrIf} $0 == ${PLACEHOLDER}
				ReadEnvStr $FunBaseDir ServiceDir
				Push $ServiceImage
				call PathParse
				Pop $ServiceImage
				${ReadLauncherConfig} $ServiceDisplay ${SERVICESECPRIF}$R0 Display
				${ReadLauncherConfig} $ServiceServiceType ${SERVICESECPRIF}$R0 Type
				${ReadLauncherConfig} $ServiceStartType ${SERVICESECPRIF}$R0 Start
				${ReadLauncherConfig} $ServiceDepend ${SERVICESECPRIF}$R0 Dependencies
				${ReadLauncherConfig} $ServiceUser ${SERVICESECPRIF}$R0 User
				${ReadLauncherConfig} $ServiceInstallType ${SERVICESECPRIF}$R0 InstallType
				StrCmp $ServiceDisplay ${PLACEHOLDER} 0 +2
				StrCpy $ServiceDisplay ""
				StrCmp $ServiceServiceType ${PLACEHOLDER} 0 +2
				StrCpy $ServiceServiceType ""
				StrCmp $ServiceStartType ${PLACEHOLDER} 0 +2
				StrCpy $ServiceStartType ""
				StrCmp $ServiceDepend ${PLACEHOLDER} 0 +2
				StrCpy $ServiceDepend ""
				StrCmp $ServiceUser ${PLACEHOLDER} 0 +2
				StrCpy $ServiceUser ""
				StrCmp $ServiceInstallType ${PLACEHOLDER} 0 +2
				StrCpy $ServiceInstallType ""
				${If} $ServiceUser == LocalService
				${OrIf} $ServiceUser == NetworkService
					StrCpy $ServiceUser "NT AUTHORITY\$ServiceUser"
				${EndIf}

				!insertmacro SERVICE "status" "$ServiceName" ""
				Pop $0
				${If} $0 == false
					${Select} $ServiceInstallType
					${Case} "cmd"
						ExecDos::exec /TOSTACK 'sc.exe create $ServiceName \
						binPath= "$ServiceImage" type= $ServiceServiceType start= $ServiceStartType \
						DisplayName= $ServiceDisplay obj= $ServiceUser depend= $ServiceDepend' '' ''
					${CaseElse}
						!insertmacro SERVICE "create" "$ServiceName" \
						"path=$ServiceImage;depend=$ServiceDepend;user=$ServiceUser;\
						display=$ServiceDisplay;starttype=$ServiceStartType;servicetype=$ServiceServiceType;"
					${EndSelect}
					; Pop $0
					; MessageBox MB_OK "Create service code: $0"
					WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" ${SERVICESECPRIF}$R0 OldImage ""
				${Else}
					ReadRegStr $ServiceOldImage  HKLM "SYSTEM\CurrentControlSet\services\$ServiceName" ImagePath
					Push $ServiceOldImage
					call ServiceImagePath
					Pop $0
					Push $ServiceImage
					call ServiceImagePath
					Pop $1
					${If} $0 != $1
						MessageBox MB_YESNO "$(ServMessage2)" IDYES 0 IDNO ServiceNo
						${Select} $ServiceInstallType
						${Case} "cmd"
							ExecDos::exec /TOSTACK 'sc.exe stop $ServiceName' '' ''
							ExecDos::exec /TOSTACK 'sc.exe delete $ServiceName' '' ''
							ExecDos::exec /TOSTACK 'sc.exe create $ServiceName \
							binPath= "$ServiceImage" type= $ServiceServiceType start= $ServiceStartType \
							DisplayName= $ServiceDisplay obj= $ServiceUser depend= $ServiceDepend' '' ''
						${CaseElse}
							!insertmacro SERVICE "stop" "$ServiceName" ""
							!insertmacro SERVICE "delete" "$ServiceName" ""
							!insertmacro SERVICE "create" "$ServiceName" \
							"path=$ServiceImage;depend=$ServiceDepend;user=$ServiceUser;\
							display=$ServiceDisplay;starttype=$ServiceStartType;servicetype=$ServiceServiceType;"
						${EndSelect}
						; Pop $0
						; MessageBox MB_OK "Create service code: $0"
						WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" ${SERVICESECPRIF}$R0 OldImage "$ServiceOldImage"
						Goto ServiceYes
						ServiceNo:
						WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" ${SERVICESECPRIF}$R0 OldImage "ServiceOldImage"
						ServiceYes:
					${Else}
						WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" ${SERVICESECPRIF}$R0 OldImage ""
					${EndIf}
				${EndIf}
				!insertmacro SERVICE "running" "$ServiceName" ""
				Pop $0
				${IfThen} $0 == false ${|} !insertmacro SERVICE "start" "$ServiceName" "" ${|}
				; Pop $0
				; MessageBox MB_OK "Start service $ServiceName code: $0"
			${EndIf}
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
	SKIPSERVSEC:
FunctionEnd

Function UnInstallService
	${ReadLauncherConfig} $0 Custom Service
	${If} $0 == true
		${If} ${RunningX64}
			${DisableX64FSRedirection}
			SetRegView 64
		${EndIf}
		${ReadLauncherConfig} $ServOprateCmd ${SERVICECOMSEC} ServUninstallCmd
		${If} $ServOprateCmd != ""
		${AndIf} $ServOprateCmd != ${PLACEHOLDER}
			${ReadLauncherConfig} $1 ${SERVICECOMSEC} CmdDelimiter
			${GetOptions} '$0ServUninstallCmd=$ServOprateCmd' '$0ServUninstallCmd=' $2
			ReadEnvStr $FunBaseDir ServiceDir
			Push $2
			call PathParse
			Pop $3
			${If} $3 != ""
					${AndIf} ${FileExists} "$3"
						${WordReplace} "$ServOprateCmd" "$2" "$3" "+1" $ServOprateCmd
					${Else}
						MessageBox MB_YESNO "$(ServMessage1)" IDYES +2
						StrCpy $ServOprateCmd ""
					${EndIf}
					${If} $ServOprateCmd != ""
						ExpandEnvStrings $ServOprateCmd "$ServOprateCmd"
						MessageBox MB_OK "$ServOprateCmd"
						; ExecDos::exec '$ServOprateCmd' '' ''
						; ExecDos::exec /DISABLEFSR '$ServOprateCmd' '' ''
						ExecWait '$ServOprateCmd'
					${EndIf}
			Goto SKIPUNSERVSEC
		${EndIf}
		${ReadLauncherConfig} $R2 ${SERVICECOMSEC} ServUninsOrder
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
			${ReadLauncherConfig} $ServiceName ${SERVICESECPRIF}$R0 Name
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ReadLauncherConfig} $ServiceOldImage ${SERVICESECPRIF}$R0 OldImage
			${ReadLauncherConfig} $ServiceInstallType ${SERVICESECPRIF}$R0 InstallType
			${If} $ServiceOldImage != ""
			${AndIf} $ServiceOldImage != ${PLACEHOLDER}
				ReadRegStr $0 HKLM "SYSTEM\CurrentControlSet\services\$ServiceName" ImagePath
				${If} $0 != $ServiceOldImage
					ReadEnvStr $FunBaseDir ServiceDir
					Push $ServiceOldImage
					call PathParse
					Pop $ServiceOldImage
					${ReadLauncherConfig} $ServiceDisplay ${SERVICESECPRIF}$R0 Display
					${ReadLauncherConfig} $ServiceServiceType ${SERVICESECPRIF}$R0 Type
					${ReadLauncherConfig} $ServiceStartType ${SERVICESECPRIF}$R0 Start
					${ReadLauncherConfig} $ServiceDepend ${SERVICESECPRIF}$R0 Dependencies
					${ReadLauncherConfig} $ServiceUser ${SERVICESECPRIF}$R0 User
					${If} $ServiceUser == LocalService
					${OrIf} $ServiceUser == NetworkService
						StrCpy $ServiceUser "NT AUTHORITY\$ServiceUser"
					${EndIf}
					${Select} $ServiceInstallType
					${Case} "cmd"
						ExecDos::exec /TOSTACK 'sc.exe stop $ServiceName' '' ''
						ExecDos::exec /TOSTACK 'sc.exe delete $ServiceName' '' ''
						ExecDos::exec /TOSTACK 'sc.exe create $ServiceName \
						binPath= "$ServiceOldImage" type= $ServiceServiceType start= $ServiceStartType \
						DisplayName= $ServiceDisplay obj= $ServiceUser depend= $ServiceDepend' '' ''
					${CaseElse}
						!insertmacro SERVICE "stop" "$ServiceName" ""
						!insertmacro SERVICE "delete" "$ServiceName" ""
						!insertmacro SERVICE "create" "$ServiceName" \
						"path=$ServiceOldImage;depend=$ServiceDepend;user=$ServiceUser;\
						display=$ServiceDisplay;starttype=$ServiceStartType;servicetype=$ServiceServiceType;"
					${EndSelect}
					; Pop $0
					; MessageBox MB_OK "Create service code: $0"
				${EndIf}
			${Else}
				${ReadLauncherConfig} $0 ${SERVICESECPRIF}$R0 RemoveFlag
				${If} $0 == true
					StrCpy $R3 1
					${Do}
						ClearErrors
						; ${ReadLauncherConfig} $0 ${SERVICESECPRIF}$R0 uninstall${SERVCMDPRIF}$R3
						${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
						"${SERVCMDPRIF}$R0UnInstall$R3=" $ServOprateCmd
						${IfThen} ${Errors} ${|} ${ExitDo} ${|}
						${If} $ServOprateCmd != ""
						${AndIf} $ServOprateCmd != ${PLACEHOLDER}
							${ReadLauncherConfig} $1 ${SERVICESECPRIF}$R0 CmdDelimiter
							${GetOptions} '$1Cmd=$ServOprateCmd' '$1Cmd=' $2
							ReadEnvStr $FunBaseDir ServiceDir
							Push $2
							call PathParse
							Pop $3
							${If} $3 != ""
							${AndIf} ${FileExists} "$3"
								${WordReplace} "$ServOprateCmd" "$2" "$3" "+1" $ServOprateCmd
							${Else}
								MessageBox MB_YESNO "$(ServMessage1)" IDYES +2
								StrCpy $ServOprateCmd ""
							${EndIf}
							${If} $ServOprateCmd != ""
								ExpandEnvStrings $ServOprateCmd "$ServOprateCmd"
								; MessageBox MB_OK "$ServOprateCmd"
								; ExecDos::exec '$ServOprateCmd' '' ''
								; ExecDos::exec /DISABLEFSR '$ServOprateCmd' '' ''
								ExecWait '$ServOprateCmd'
							${EndIf}
						${EndIf}
						IntOp $R3 $R3 + 1
					${Loop}
					${ConfigRead} "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${SERVCMDPRIF}$R0UnInstall1=" $0
					${If} $0 == ""
					${OrIf} $0 == ${PLACEHOLDER}
						${Select} $ServiceInstallType
						${Case} "cmd"
							ExecDos::exec /TOSTACK 'sc.exe stop $ServiceName' '' ''
							ExecDos::exec /TOSTACK 'sc.exe delete $ServiceName' '' ''
						${CaseElse}
							!insertmacro SERVICE "stop" "$ServiceName" ""
							!insertmacro SERVICE "delete" "$ServiceName" ""
						${EndSelect}
					${EndIf}
				${Else}
					${Select} $ServiceInstallType
					${Case} "cmd"
						ExecDos::exec /TOSTACK 'sc.exe stop $ServiceName' '' ''
						ExecDos::exec /TOSTACK 'sc.exe config $ServiceName start= demand' '' ''
					${CaseElse}
						!insertmacro SERVICE "stop" "$ServiceName" ""
						!insertmacro SERVICE "config" "$ServiceName" "starttype=0x00000003;"
					${EndSelect}
					; Pop $0
					; MessageBox MB_OK "$ServiceName/$0"
				${EndIf}
			${EndIf}
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
	SKIPUNSERVSEC:
FunctionEnd