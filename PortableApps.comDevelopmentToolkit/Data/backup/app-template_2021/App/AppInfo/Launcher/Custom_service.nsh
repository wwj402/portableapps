
!include x64.nsh
!include servicelibnew.nsh

!define SERVICESECPRIF "CustomServ"
!define SERVICECOMSEC "CustomCom"
!ifndef ORDERDELIMITER
	!define ORDERDELIMITER ","
	!define PLACEHOLDER "none"
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
	!define BASEDIRFLAG "Y"
!endif
Var ServiceInstallType
Var ServInstallCmd
Var ServUninstallCmd

!ifndef LANGFLAG
	LangString DirMessage1 1033 "Unable to get service and driver default path, environment variable not set."
	LangString DirMessage1 2052 "无法获取服务和驱动的默认路径，环境变量未设置。"
	!define LANGFLAG "Y"
!endif

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
		${If} ${RunningX64}
			ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable64
			${If} $0 != ""
			${AndIf} ${FileExists} "$EXEDIR\App\$0"
				${GetParent} "$EXEDIR\App\$0" $FunBaseDir
				${SetEnvironmentVariable} ServiceDir $FunBaseDir
				${SetEnvironmentVariable} DeviceDir $FunBaseDir
			${ElseIf} $0 == ""
				ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable
				${GetParent} "$EXEDIR\App\$0" $FunBaseDir
				${SetEnvironmentVariable} ServiceDir $FunBaseDir
				${SetEnvironmentVariable} DeviceDir $FunBaseDir
			${ElseIf} $0 != ""
				Abort "$(DirMessage1)"
			${EndIf}
		${Else}
			ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable
			${If} $0 != ""
			${AndIf} ${FileExists} "$EXEDIR\App\$0"
				${GetParent} "$EXEDIR\App\$0" $FunBaseDir
				${SetEnvironmentVariable} ServiceDir $FunBaseDir
				${SetEnvironmentVariable} DeviceDir $FunBaseDir
			${Else}
				Abort "$(DirMessage1)"
			${EndIf}
		${EndIf}
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
		${ReadLauncherConfig} $ServInstallCmd ${SERVICECOMSEC} ServInstallCmd
		${If} $ServInstallCmd != ""
		${AndIf} $ServInstallCmd != ${PLACEHOLDER}
			ReadEnvStr $FunBaseDir ServiceDir
			Push $ServInstallCmd
			call PathParse
			Pop $ServInstallCmd
			${If} $ServInstallCmd != ""
				ExecDos::exec /TOSTACK '$ServInstallCmd' '' ''
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
					MessageBox MB_YESNO "$(ServiceMessage2)" IDYES 0 IDNO ServiceNo
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
			${If} $R1 >= 0
				IntOp $R1 $R1 - 1
			${EndIf}
			IntOp $R0 $R0 + 1
			; MessageBox MB_OK "$R0, $R1, $R2"
		${LoopWhile} $R1 != 0
	${EndIf}
	SKIPSERVSEC:
FunctionEnd

Function UnInstallService
	${ReadLauncherConfig} $0 Custom Service
	${If} $0 == true
			${ReadLauncherConfig} $ServUninstallCmd ${SERVICECOMSEC} ServUninstallCmd
			${If} $ServUninstallCmd != ""
			${AndIf} $ServUninstallCmd != ${PLACEHOLDER}
				ReadEnvStr $FunBaseDir ServiceDir
				Push $ServUninstallCmd
				call PathParse
				Pop $ServUninstallCmd
				${If} $ServUninstallCmd != ""
					ExecDos::exec /TOSTACK '$ServUninstallCmd' '' ''
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
					${Select} $ServiceInstallType
					${Case} "cmd"
						ExecDos::exec /TOSTACK 'sc.exe stop $ServiceName' '' ''
						ExecDos::exec /TOSTACK 'sc.exe delete $ServiceName' '' ''
					${CaseElse}
						!insertmacro SERVICE "stop" "$ServiceName" ""
						!insertmacro SERVICE "delete" "$ServiceName" ""
					${EndSelect}
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
	${EndIf}
	SKIPUNSERVSEC:
FunctionEnd