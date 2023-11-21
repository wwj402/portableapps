
!include x64.nsh
!include servicelibnew.nsh

!define DEVICESECPRIF "CustomDev"
!define DEVICECOMSEC "CustomCom"
!ifndef ORDERDELIMITER
    !define ORDERDELIMITER ","
    !define PLACEHOLDER "none"
!endif

Var DeviceName
Var DeviceInf
Var DeviceInfHWID
Var DeviceInfPath
Var DeviceExePath

!ifndef BASEDIRFLAG
    Var FunBaseDir
    !define BASEDIRFLAG "Y"
!endif
Var DevInstallCmd
Var DevUninstallCmd

!ifndef LANGFLAG
    LangString DirMessage1 1033 "Unable to get service and driver default path, environment variable not set."
    LangString DirMessage1 2052 "无法获取服务和驱动的默认路径，环境变量未设置。"
    !define LANGFLAG "Y"
!endif

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
	${ReadLauncherConfig} $0 Custom Device
	${If} $0 == true
		${ReadLauncherConfig} $DevInstallCmd ${DEVICECOMSEC} DevInstallCmd
		${If} $DevInstallCmd != ""
		${AndIf} $DevInstallCmd != ${PLACEHOLDER}
			ReadEnvStr $FunBaseDir DeviceDir
			Push $DevInstallCmd
			call PathParse
			Pop $DevInstallCmd
			${If} $DevInstallCmd != ""
				ExecDos::exec /TOSTACK '$DevInstallCmd' '' ''
			${EndIf}
			Goto SKIPDEVSEC
		${EndIf}
		${ReadLauncherConfig} $DeviceExePath ${DEVICECOMSEC} DevExeDir
		ReadEnvStr $FunBaseDir DeviceDir
		Push $DeviceExePath
		call PathParse
		Pop $DeviceExePath
		${If} ${RunningX64}
			${ReadLauncherConfig} $0 ${DEVICECOMSEC} DevExe64
			StrCpy $DeviceExePath "$DeviceExePath\$0"
		${Else}
			${ReadLauncherConfig} $0 ${DEVICECOMSEC} DevExe
			StrCpy $DeviceExePath "$DeviceExePath\$0"
		${EndIf}
		; MessageBox MB_OK "DeviceExePath=$DeviceExePath"
		${IfThen} $DeviceExePath == "" ${|} Goto SKIPDEVSEC ${|}
		${ReadLauncherConfig} $R2 ${DEVICECOMSEC} DevInsOrder
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
			${ReadLauncherConfig} $DeviceName ${DEVICESECPRIF}$R0 DevName
			${ReadLauncherConfig} $DeviceInf ${DEVICESECPRIF}$R0 DevInf
			${ReadLauncherConfig} $DeviceInfHWID ${DEVICESECPRIF}$R0 DevInfHWID
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ReadLauncherConfig} $DeviceInfPath ${DEVICECOMSEC} InfDir
			ReadEnvStr $FunBaseDir DeviceDir
			Push $DeviceInfPath
			Call PathParse
			Pop $DeviceInfPath
			StrCpy $DeviceInfPath "$DeviceInfPath\$DeviceInf"
			ExecDos::exec /TOSTACK '"$DeviceExePath" status "$DeviceInfHWID"' '' ''
			Pop $0
			Pop $0
			; MessageBox MB_OK "Status $0"
			${If} $0 == "No matching devices found."
				; MessageBox MB_OK '"$DeviceExePath" install "$DeviceInfPath" "$DeviceInfHWID"'
				ExecDos::exec /TOSTACK '"$DeviceExePath" install "$DeviceInfPath" "$DeviceInfHWID"' '' ''
				!insertmacro SERVICE "start" "$DeviceName" ""
			${EndIf}
			${If} $R1 >= 0
				IntOp $R1 $R1 - 1
			${EndIf}
			IntOp $R0 $R0 + 1
			; MessageBox MB_OK "$R0, $R1, $R2"
		${LoopWhile} $R1 != 0
	${EndIf}
	SKIPDEVSEC:
FunctionEnd

Function UnInstallDevice
	${ReadLauncherConfig} $0 Custom Device
	${If} $0 == true
		${ReadLauncherConfig} $DevUninstallCmd ${DEVICECOMSEC} DevUninstallCmd
		${If} $DevUninstallCmd != ""
		${AndIf} $DevUninstallCmd != ${PLACEHOLDER}
			ReadEnvStr $FunBaseDir DeviceDir
			Push $DevUninstallCmd
			call PathParse
			Pop $DevUninstallCmd
			${If} $DevUninstallCmd != ""
				ExecDos::exec /TOSTACK '$DevUninstallCmd' '' ''
			${EndIf}
			Goto SKIPUNDEVSEC
		${EndIf}
		${ReadLauncherConfig} $R2 ${DEVICECOMSEC} DevUninsOrder
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
			${ReadLauncherConfig} $DeviceName ${DEVICESECPRIF}$R0 DevName
			${ReadLauncherConfig} $DeviceInf ${DEVICESECPRIF}$R0 DevInf
			${ReadLauncherConfig} $DeviceInfHWID ${DEVICESECPRIF}$R0 DevInfHWID
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ReadLauncherConfig} $0 ${DEVICESECPRIF}$R0 RemoveFlag
			${If} $0 == true
				ExecDos::exec /TOSTACK '"$DeviceExePath" remove "$DeviceInfHWID"' '' ''
				!insertmacro SERVICE "stop" "$DeviceName" ""
				!insertmacro SERVICE "delete" "$DeviceName" ""
			${Else}
				!insertmacro SERVICE "stop" "$DeviceName" ""
				!insertmacro SERVICE "config" "$DeviceName" "starttype=0x00000003;"
				; Pop $0
				; MessageBox MB_OK "$0"
			${EndIf}
			${If} $R1 >= 0
				IntOp $R1 $R1 - 1
			${EndIf}
			IntOp $R0 $R0 + 1
			; MessageBox MB_OK "$R0, $R1, $R2"
		${LoopWhile} $R1 != 0
	${EndIf}
	SKIPUNDEVSEC:
FunctionEnd