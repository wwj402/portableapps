
Var DllDes
Var DllPath
Var dlldir
Var dllflag
Var regcode
Var regasmpath
Var netversion
Var filetlb

!ifndef BASEDIRFLAG
	Var FunBaseDir
	!define BASEDIRFLAG "Y"
!endif
!ifndef ORDERDELIMITER
	!define ORDERDELIMITER ","
	!define PLACEHOLDER "null"
!endif

!define CUSTOM_DLL 'yes'
!define REGSVR32SECPRIF "CustomDll"
!define REGSUB_CLSID "SOFTWARE\Classes\CLSID"
!define REGSUB_TypeLib "SOFTWARE\Classes\TypeLib"
!define REGSUB_Interface "SOFTWARE\Classes\Interface"
!define NETFRAMEWORK "$WINDIR\Microsoft.NET\Framework"

LangString DllMessage1 1033 "Unable to get Dll default path, environment variable not set."
LangString DllMessage1 2052 "无法获取 Dll 的默认路径，环境变量未设置。"
LangString DllMessage2 1033 'The file to be registered does not exist. Registration will be skipped. $\n$0$\n'
LangString DllMessage2 2052 "要注册的文件不存在，将跳过注册。$\n$0$\n"
LangString DllMessage3 1033 'RegAsm.exe file not found, check if .NET is installed.'
LangString DllMessage3 2052 "RegAsm.exe 文件未找到，请检查是否安装了 .net。"

Function "DllPathParse"
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

Function "getnewest"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $0
	Push $1
	${If} $R6 == ""
		!define SKIP "SKIP${__LINE__}"
		IfFileExists "$R9\RegAsm.exe" 0 ${SKIP}
		StrCpy $0 "$R7" "" 1
		; MessageBox MB_OK "$netversion|$0"
		${If} $netversion == ""
			StrCpy $netversion "$0"
		${Else}
			${VersionCompare} "$0" "$netversion" $1
			${If} $1 = 1
				StrCpy $netversion "$0"
			${EndIf}
		${EndIf}
		${SKIP}:
		!undef SKIP
	${EndIf}
	Pop $1
	Pop $0
	Push "continue"
FunctionEnd

Function "RegasmPath"
	${Locate} "$regasmpath" "/L=D /G=0 /M=v*" "getnewest"
	; MessageBox MB_OK "$regasmpath\v$netversion\RegAsm.exe"
	${If} ${FileExists} "$regasmpath\v$netversion\RegAsm.exe"
		StrCpy $regasmpath "$regasmpath\v$netversion\RegAsm.exe"
	${Else}
		MessageBox MB_OK "$(DllMessage3)"
	${EndIf}
FunctionEnd

!macro LibOpration _LIBREG _UNLIBREG _REGTYPE
	${Select} ${_REGTYPE}
	${Case} "dll_x86"
		${If} ${_LIBREG} != "null"
		${AndIf} ${_UNLIBREG} != "null"
			UnRegDLL "${_UNLIBREG}"
			RegDLL "${_LIBREG}"
		${ElseIf} ${_LIBREG} != "null"
			RegDLL "${_LIBREG}"
		${Else}
			UnRegDLL "${_UNLIBREG}"
		${EndIf}
	${Case} "tlb"
		${If} ${_LIBREG} != "null"
		${AndIf} ${_UNLIBREG} != "null"
			TypeLib::UnRegister "${_UNLIBREG}"
			TypeLib::Register "${_LIBREG}"
		${ElseIf} ${_LIBREG} != "null"
			TypeLib::Register "${_LIBREG}"
		${Else}
			TypeLib::UnRegister "${_UNLIBREG}"
		${EndIf}
	${Case} "exe"
		${If} ${_LIBREG} != "null"
		${AndIf} ${_UNLIBREG} != "null"
			ExecWait '"${_UNLIBREG}" /unregserver'
			ExecWait '"${_LIBREG}" /regserver'
		${ElseIf} ${_LIBREG} != "null"
			ExecWait '"${_LIBREG}" /regserver'
		${Else}
			ExecWait '"${_UNLIBREG}" /unregserver'
		${EndIf}
	${Case} "net_dll"
		${If} ${FileExists} "$regasmpath"
			${If} ${_LIBREG} != "null"
			${AndIf} ${_UNLIBREG} != "null"
				ExecWait '"$regasmpath" "${_UNLIBREG}" /codebase /s /u'
				ExecWait '"$regasmpath" "${_LIBREG}" /codebase /s'
			${ElseIf} ${_LIBREG} != "null"
				ExecWait '"$regasmpath" "${_LIBREG}" /codebase /s'
			${Else}
				ExecWait '"$regasmpath" "${_UNLIBREG}" /codebase /s /u'
			${EndIf}
		${EndIf}
	${Case} "net_tlb"
		${If} ${FileExists} "$regasmpath"
			${If} ${_LIBREG} != "null"
			${AndIf} ${_UNLIBREG} != "null"
				${GetFileExt} "${_UNLIBREG}" $filetlb
				${WordReplace} "${_UNLIBREG}" ".$filetlb" ".dll" "-1" $filetlb
				ExecWait '"$regasmpath" "$filetlb" /codebase /tlb /s /u'
				${WordReplace} "${_LIBREG}" ".$filetlb" ".dll" "-1" $filetlb
				ExecWait '"$regasmpath" "$filetlb" /codebase /tlb /s'
			${ElseIf} ${_LIBREG} != "null"
				${GetFileExt} "${_LIBREG}" $filetlb
				${WordReplace} "${_LIBREG}" ".$filetlb" ".dll" "-1" $filetlb
				ExecWait '"$regasmpath" "filetlb" /codebase /tlb /s'
			${Else}
				${GetFileExt} "${_UNLIBREG}" $filetlb
				${WordReplace} "${_UNLIBREG}" ".$filetlb" ".dll" "-1" $filetlb
				ExecWait '"$regasmpath" "$filetlb" /codebase /tlb /s /u'
			${EndIf}
		${EndIf}
	${Case} "skip"
		nop
	${CaseElse}
		${If} ${_LIBREG} != "null"
		${AndIf} ${_UNLIBREG} != "null"
			ExecWait 'regsvr32 /s /u "${_UNLIBREG}"'
			ExecWait 'regsvr32 /s "${_LIBREG}"'
			; ExecDos::exec /DISABLEFSR 'regsvr32 /s /u "${_UNLIBREG}"' '' ''
			; ExecDos::exec /DISABLEFSR 'regsvr32 /s "${_LIBREG}"' '' ''
		${ElseIf} ${_LIBREG} != "null"
			ExecWait 'regsvr32 /s "${_LIBREG}"'
			; ExecDos::exec /DISABLEFSR 'regsvr32 /s "${_LIBREG}"' '' ''
		${Else}
			ExecWait 'regsvr32 /s /u "${_UNLIBREG}"'
			; ExecDos::exec /DISABLEFSR 'regsvr32 /s /u "${_UNLIBREG}"' '' ''
		${EndIf}
	${EndSelect}
!macroend

Function "ManualClean"
	ReadINIStr $2 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${REGSVR32SECPRIF}$R0" "RegRoot"
	${registry::Open} "$2\${REGSUB_Interface}" "/K=0 /V=0 /S=1 /N='$0'" $3
	StrCpy $R1 "1"
	${DoUntil} $3 == 0
		${registry::Find} "$3" $4 $5 $6 $7
		${If} $4 != ""
			${GetParent} "$2\$4" $4
			WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
			"${REGSVR32SECPRIF}$R0" "$R1" "$4"
			IntOp $R1 $R1 + 1
		${EndIf}
	${LoopUntil} $4 == ""
	${registry::Close} "$3"
	${DoUntil} $R1 = 1
		IntOp $R1 $R1 - 1
		ReadINIStr $5 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${REGSVR32SECPRIF}$R0" "$R1"
		; MessageBox MB_OK "$R1=$5"
		SetRegView 32
		${Registry::DeleteKey} "$5" $regcode
		SetRegView 64
		${Registry::DeleteKey} "$5" $regcode
		DeleteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${REGSVR32SECPRIF}$R0" "$R1"
	${Loop}
FunctionEnd

Function "RegsvrDll"
	${ReadLauncherConfig} $0 "Custom" "Regsvr32"
	${If} $0 == true
		ReadEnvStr $dlldir "ProgramDir"
		StrCpy $FunBaseDir "$dlldir"
		; ${If} ${RunningX64}
		; 	${DisableX64FSRedirection}
		; 	SetRegView 64
		; ${EndIf}
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $DllDes "${REGSVR32SECPRIF}$R0" "Description"
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ReadLauncherConfig} $0 "${REGSVR32SECPRIF}$R0" "Lib_X64"
			${ReadLauncherConfig} $1 "${REGSVR32SECPRIF}$R0" "RegType"
			${If} ${RunningX64}
			${AndIf} $Bits == 32
			${AndIf} $0 != true
				StrCpy $dllflag "32"
			${ElseIf} ${RunningX64}
			${AndIf} $0 == true
				StrCpy $dllflag "64"
			${ElseIf} $Bits == 64
				StrCpy $dllflag "64"
			${Else}
				StrCpy $dllflag "32"
			${EndIf}
			${If} $dllflag == 64
				${DisableX64FSRedirection}
				SetRegView 64
				${ReadLauncherConfig} $DllPath "${REGSVR32SECPRIF}$R0" "Path64"
				StrCpy $0 "Path64=$DllPath"
				${If} $1 == "net_dll"
				${OrIf} $1 == "net_tlb"
					StrCpy $regasmpath "${NETFRAMEWORK}64"
					Call RegasmPath
				${EndIf}
			${Else}
				${ReadLauncherConfig} $DllPath "${REGSVR32SECPRIF}$R0" "Path"
				StrCpy $0 "Path=$DllPath"
				${If} $1 == "net_dll"
				${OrIf} $1 == "net_tlb"
					StrCpy $regasmpath "${NETFRAMEWORK}"
					Call RegasmPath
				${EndIf}
			${EndIf}
			Push $DllPath
			Call DllPathParse
			Pop $DllPath
			; ExpandEnvStrings $DllPath "$DllPath"
			${If} $DllPath == ""
			${AndIf} $1 != "skip"
				MessageBox MB_OK "$(DllMessage2)"
				IntOp $R0 $R0 + 1
				${Continue}
			${EndIf}
			${ReadLauncherConfig} $0 "${REGSVR32SECPRIF}$R0" "TypeLib"
			${ReadLauncherConfig} $1 "${REGSVR32SECPRIF}$R0" "CLSID"
			${ReadLauncherConfig} $9 "${REGSVR32SECPRIF}$R0" "RegType"
			${ReadLauncherConfig} $8 ${REGSVR32SECPRIF}$R0 OldImage
			${If} $0 != ""
			${AndIf} $0 != ${PLACEHOLDER}
				ReadINIStr $2 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${REGSVR32SECPRIF}$R0" "RegRoot"
				${registry::Open} "$2\${REGSUB_TypeLib}\$0" "/K=1 /V=0 /S=0 /NI='win'" $3
				${If} $3 != 0
					${registry::Find} "$3" $4 $5 $6 $7
					${registry::Close} "$3"
					${If} $4 != ""
						${registry::Read} "$2\$4\$5" "" $6 $7
						${If} $6 != $DllPath
							WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
							"${REGSVR32SECPRIF}$R0" "OldImage" "$6"
							!insertmacro "LibOpration" "$DllPath" "$6" "$9"
						${Else}
							IfFileExists "$8" +2 0
							WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
							"${REGSVR32SECPRIF}$R0" "OldImage" "null"
							!insertmacro "LibOpration" "$DllPath" "null" "$9"
						${EndIf}
					${Else}
						WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
						"${REGSVR32SECPRIF}$R0" "OldImage" "null"
						!insertmacro "LibOpration" "$DllPath" "null" "$9"
					${EndIf}
				${Else}
					WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
					"${REGSVR32SECPRIF}$R0" "OldImage" "null"
					!insertmacro "LibOpration" "$DllPath" "null" "$9"
				${EndIf}
			${ElseIf} $1 != ""
			${AndIf} $1 != ${PLACEHOLDER}
				ReadINIStr $2 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${REGSVR32SECPRIF}$R0" "RegRoot"
				${registry::Open} "$2\${REGSUB_CLSID}\$1" "/K=1 /V=0 /S=0 /NI='InprocServer'" $3
				${If} $3 != 0
					/* ${registry::Find} "[handle]" $var1("[path]") $var2("[value]" or "[key]") \
					$var3("[string]") $var4("[TYPE]") */
					${registry::Find} "$3" $4 $5 $6 $7
					${registry::Close} "$3"
					; MessageBox MB_OK "$2\$4 $5 $6 $7"
					${If} $4 != ""
						; ${registry::Read} "[fullpath]" "[value]" $var1("[string]") $var2("[TYPE]")
						${registry::Read} "$2\$4\$5" "" $6 $7
						${If} $6 != $DllPath
							WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
							"${REGSVR32SECPRIF}$R0" "OldImage" "$6"
							; ${registry::Write} "[fullpath]" "[value]" "[string]" "[TYPE]" $var
							${Registry::Write} "$2\$4\$5" "" "$DllPath" "$7" $regcode
						${Else}
							IfFileExists "$8" +2 0
							WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
							"${REGSVR32SECPRIF}$R0" "OldImage" "null"
						${EndIf}
					${Else}
						WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
						"${REGSVR32SECPRIF}$R0" "OldImage" "null"
						${Registry::Write} "$2\$4\$5" "" "$DllPath" "$7" $regcode
					${EndIf}
				${Else}
					; MessageBox MB_OK "$2\${REGSUB_CLSID}\$1"
					WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
					"${REGSVR32SECPRIF}$R0" "OldImage" "null"
					${Registry::Write} "$2\${REGSUB_CLSID}\$1" "" "$DllDes" "REG_SZ" $regcode
					${Registry::Write} "$2\${REGSUB_CLSID}\$1\InprocServer32" "" "$DllPath" "REG_SZ" $regcode
					${Registry::Write} "$2\${REGSUB_CLSID}\$1\InprocServer32" "ThreadingModel" "both" "REG_SZ" $regcode
				${EndIf}
			${Else}
				!insertmacro "LibOpration" "$DllPath" "null" "$9"
			${EndIf}
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
			IntOp $R0 $R0 + 1
		${Loop}
	${EndIf}
FunctionEnd

Function "UnRegsvrDll"
	${ReadLauncherConfig} $0 Custom Regsvr32
	${If} $0 == true
		ReadEnvStr $dlldir ProgramDir
		StrCpy $FunBaseDir "$dlldir"
		; ${If} ${RunningX64}
		; 	${DisableX64FSRedirection}
		; 	SetRegView 64
		; ${EndIf}
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $DllDes ${REGSVR32SECPRIF}$R0 Description
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ReadLauncherConfig} $0 "${REGSVR32SECPRIF}$R0" "Lib_X64"
			${If} ${RunningX64}
			${AndIf} $Bits == 32
			${AndIf} $0 != true
				StrCpy $dllflag "32"
			${ElseIf} ${RunningX64}
			${AndIf} $0 == true
				StrCpy $dllflag "64"
			${ElseIf} $Bits == 64
				StrCpy $dllflag "64"
			${Else}
				StrCpy $dllflag "32"
			${EndIf}
			${If} $dllflag == 64
				${DisableX64FSRedirection}
				SetRegView 64
				${ReadLauncherConfig} $DllPath ${REGSVR32SECPRIF}$R0 Path64
			${Else}
				${ReadLauncherConfig} $DllPath ${REGSVR32SECPRIF}$R0 Path
			${EndIf}
			Push $DllPath
			Call DllPathParse
			Pop $DllPath
			; ExpandEnvStrings $DllPath "$DllPath"
			${If} $DllPath == ""
				IntOp $R0 $R0 + 1
				${Continue}
			${EndIf}
			${ReadLauncherConfig} $0 "${REGSVR32SECPRIF}$R0" "TypeLib"
			${ReadLauncherConfig} $1 "${REGSVR32SECPRIF}$R0" "CLSID"
			${ReadLauncherConfig} $9 ${REGSVR32SECPRIF}$R0 RegType
			${ReadLauncherConfig} $8 ${REGSVR32SECPRIF}$R0 OldImage
			${If} $0 != ""
			${AndIf} $0 != ${PLACEHOLDER}
				${If} $8 != ""
				${AndIf} $8 != ${PLACEHOLDER}
					!insertmacro "LibOpration" "null" "$DllPath" "$9"
					!insertmacro "LibOpration" "$8" "null" "$9"
				${Else}
					!insertmacro "LibOpration" "null" "$DllPath" "$9"
					ReadINIStr $2 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" \
					"${REGSVR32SECPRIF}$R0" "ManualClean"
					${If} $2 == true
						Call ManualClean
					${EndIf}
				${EndIf}
			${ElseIf} $1 != ""
			${AndIf} $1 != ${PLACEHOLDER}
				ReadINIStr $2 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" "${REGSVR32SECPRIF}$R0" "RegRoot"
				${If} $8 != ""
				${AndIf} $8 != ${PLACEHOLDER}
					${registry::Open} "$2\${REGSUB_CLSID}\$1" "/K=1 /V=0 /S=0 /NI='InprocServer'" $3
					${If} $3 != 0
					; ${registry::Find} "[handle]" $var1("[path]") $var2("[value]" or "[key]") 
						; $var3("[string]") $var4("[TYPE]")
						${registry::Find} "$3" $4 $5 $6 $7
						${registry::Close} "$3"
						${Registry::Write} "$2\$4\$5" "" "$8" "$7" $regcode
					${EndIf}
				${Else}
					${registry::DeleteKey} "$2\${REGSUB_CLSID}\$1" $regcode
					; MessageBox MB_OK "$2\${REGSUB_CLSID}\$1=$regcode" 
				${EndIf}
			${Else}
				!insertmacro "LibOpration" "null" "$DllPath" "$9"
			${EndIf}
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
			IntOp $R0 $R0 + 1
		${Loop}
	${EndIf}
FunctionEnd

