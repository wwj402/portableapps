
Var DllDes
Var DllPath
Var dlldir

!ifndef BASEDIRFLAG
    Var FunBaseDir
    !define BASEDIRFLAG "Y"
!endif

!define REGSVR32SECPRIF "CustomDll"

Function DllPathParse
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

LangString DllMessage1 1033 "Unable to get Dll default path, environment variable not set."
LangString DllMessage1 2052 "无法获取 Dll 的默认路径，环境变量未设置。"

Function RegsvrDll
	${ReadLauncherConfig} $0 Custom Regsvr32
	${If} $0 == true
		ReadEnvStr $dlldir ProgramDir
		StrCpy $FunBaseDir "$dlldir"
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $DllDes ${REGSVR32SECPRIF}$R0 Description
			${If} $Bits == 64
				${ReadLauncherConfig} $DllPath ${REGSVR32SECPRIF}$R0 Path64
				${If} $DllPath == ""
					${ReadLauncherConfig} $DllPath ${REGSVR32SECPRIF}$R0 Path
				${EndIf}
			${Else}
				${ReadLauncherConfig} $DllPath ${REGSVR32SECPRIF}$R0 Path
			${EndIf}
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			Push $DllPath
			Call DllPathParse
			Pop $DllPath
			; ExpandEnvStrings $DllPath "$DllPath"
			${ReadLauncherConfig} $0 ${REGSVR32SECPRIF}$R0 RegType
			${Select} $0
			${Case} "lib"
				RegDLL "$DllPath"
			${CaseElse}
				ExecDos::exec 'regsvr32 /s "$DllPath"' '' ''
			${EndSelect}
			IntOp $R0 $R0 + 1
		${Loop}
	${EndIf}
FunctionEnd

Function UnRegsvrDll
	${ReadLauncherConfig} $0 Custom Regsvr32
	${If} $0 == true
		ReadEnvStr $dlldir ProgramDir
		StrCpy $FunBaseDir "$dlldir"
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $DllDes ${REGSVR32SECPRIF}$R0 Description
			${If} $Bits == 64
				${ReadLauncherConfig} $DllPath ${REGSVR32SECPRIF}$R0 Path64
				${If} $DllPath == ""
					${ReadLauncherConfig} $DllPath ${REGSVR32SECPRIF}$R0 Path
				${EndIf}
			${Else}
				${ReadLauncherConfig} $DllPath ${REGSVR32SECPRIF}$R0 Path
			${EndIf}
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			Push $DllPath
			Call DllPathParse
			Pop $DllPath
			; ExpandEnvStrings $DllPath "$DllPath"
			${ReadLauncherConfig} $0 ${REGSVR32SECPRIF}$R0 RegType
			${Select} $0
			${Case} "lib"
				UnRegDLL "$DllPath"
			${CaseElse}
				ExecDos::exec 'regsvr32 /s /u "$DllPath"' '' ''
			${EndSelect}
			IntOp $R0 $R0 + 1
		${Loop}
	${EndIf}
FunctionEnd

