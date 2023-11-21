
!include "x64.nsh"
!include "UserForEachINIPair.nsh"

Var SecString
Var SecVaule
Var SrcUncFlag
Var DstUncFlag
Var SrcNtfsFlag
Var DstNtfsFlag
Var OsFlag
Var OptFlag
Var usedexe
Var linksrcname

!define CUSTOM_LINK 'yes'
!define IniItemMove '!insertmacro IniItemMove'
!define PathIsNTFS '!insertmacro PathIsNTFS'
!define PathIsUNC '!insertmacro PathIsUNC'
!define DstDirCheck '!insertmacro DstDirCheck'

!define USERINIPATH "$EXEDIR\$BaseName.ini"
!define LAUNCHERINIPATH "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini"
!define LINKSEC "DirectoriesLink"
!define MOVESEC "DirectoriesMove"
!define FILESEC "FilesMove"
!define FLAGFILE "sym_link.ini"
!define LINKINIPATH "$EXEDIR\LinkStatus.ini"
!define LINKOPTSEC "$BaseName"
!define LINKINITEMP "$EXEDIR\$BaseName_LinkTemp.ini"
!define SYBEXE "NTLinksMaker.exe"
!define SYBEXE64 "NTLinksMaker64.exe"
!define SYBDIR "$EXEDIR\Data\NTLinksMaker"
!define SYBSWITCH1 "/q /n /b"
!define SYBSWITCH2 "/q /n /b /s"
!define FSFLAG "NTFS"

LangString LinkMessage1 1033 'Error while configuring link configuration file.'
LangString LinkMessage1 2052 '配置链接配置文件时出错。'
LangString LinkMessage2 1033 'The $4 directory program is already running. \
									Do not run it at the same time. Please exit!'
LangString LinkMessage2 2052 '$4 目录程序已运行，不要同时运行，请退出！'

!macro PathIsUNC _PATH _FLAG
	Push $0
	Push $1
	${GetRoot} ${_PATH} $0
	StrCpy $0 "$0\"
	System::Call 'Kernel32::GetDriveType(t r0)i.r1'
	; MessageBox MB_OK "$1"
	${If} $1 = 4
		StrCpy ${_FLAG} "isunc"
	${Else}
		StrCpy ${_FLAG} "notunc"
	${EndIf}
	Pop $1
	Pop $0
!macroend

!macro PathIsNTFS _PATH _FLAG
	Push $0
	Push $1
	${GetRoot} ${_PATH} $0
	StrCpy $0 "$0\"
	System::Call 'Kernel32::GetVolumeInformation(t "$0",t,i ${NSIS_MAX_STRLEN},*i,*i,*i,t.r1,i ${NSIS_MAX_STRLEN})i.r0'
	; MessageBox MB_OK "$1"
	${If} $0 <> 0
		${If} $1 == ${FSFLAG}
			StrCpy ${_FLAG} "isntfs"
		${Else}
			StrCpy ${_FLAG} "notntfs"
		${EndIf}
	${Else}
		StrCpy ${_FLAG} "false"
	${EndIf}
	Pop $1
	Pop $0
!macroend

Function "linklevel"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	Push $R4
	Push $R5
	${WordReplace} "$R9" "$R1" "$R2" "+1" $R4
	${GetFileAttributes} "$3" "REPARSE_POINT" $R5
	${If} $R5 == 1
		${If} $R6 == ""
			RMDir "$R4"
		${Else}
			Delete "$R4"
		${EndIf}
	${EndIf}
	Pop $R5
	Pop $R4
	Push "continue"
FunctionEnd

!macro DstDirCheck _SRCPATH _DSTPATH
	Push $1
	Push $2
	Push $3
	Push $4
	Push $R1
	Push $R2
	${WordFind} "${_SRCPATH}" "," "#" $1
	ExpandEnvStrings $R2 "${_DSTPATH}"
	${If} $1 == ${_SRCPATH}
		${If} ${FileExists} "$R2"
			; ${GetFileAttributes} "$1" "REPARSE_POINT" $2
			${GetFileAttributes} "$R2" "DIRECTORY" $2
			${If} $2 == "1"
				${If} ${FileExists} "$R2\${FLAGFILE}"
					RMDir "$R2"
				${Else}
					Rename "$R2" "$R2_$BaseName"
				${EndIf}
			${Else}
				Rename "$R2" "$R2_$BaseName"
			${EndIf}
		${EndIf}
	${ElseIf} $1 == 2
		${WordFind} "${_SRCPATH}" "," "+1" $R1
		ExpandEnvStrings $R1 "$R1"
		${GetRoot} "$R1" $2
		${If} $2 == ""
			StrCpy $R1 "$EXEDIR\Data\$R1"
		${EndIf}
		${Locate} "$R1" "/G=1" "linklevel"
	${EndIf}
	Pop $R2
	Pop $R1
	Pop $4
	Pop $3
	Pop $2
	Pop $1
!macroend

Function InitLink
	${ConfigRead} "${USERINIPATH}" "[${LINKSEC}" $0
	${If} $0 != "]"
		${ConfigWrite} "${USERINIPATH}" "[${LINKSEC}" "]" $1
		${ConfigWrite} "${USERINIPATH}" "[${MOVESEC}" "]" $1
		${ConfigWrite} "${USERINIPATH}" "[${FILESEC}" "]" $1
		${UserForEachINIPair} "${LAUNCHERINIPATH}" "${MOVESEC}" $SecString $SecVaule
			WriteINIStr "${USERINIPATH}" "${LINKSEC}" $SecString $SecVaule
			WriteINIStr "${USERINIPATH}" "${MOVESEC}" $SecString $SecVaule
		${UserNextINIPair}
		${UserForEachINIPair} "${LAUNCHERINIPATH}" "${FILESEC}" $SecString $SecVaule
			WriteINIStr "${USERINIPATH}" "${FILESEC}" $SecString $SecVaule
		${UserNextINIPair}
	${EndIf}
	
	${UserForEachINIPair} "${USERINIPATH}" "${LINKSEC}" $SecString $SecVaule
		${WordFind} "$SecString" "," "+1" $0
		${GetRoot} "$0" $1
		StrCmp $1 "" 0 +2
		StrCpy $0 "$EXEDIR\Data\$0"
		ExpandEnvStrings $0 "$0"
		${IfNot} ${FileExists} "$0\${FLAGFILE}"
			WriteINIStr "$0\${FLAGFILE}" "${FLAGFILE}" "DIR" "$EXEDIR"
		${Else}
			${ConfigRead} "$0\${FLAGFILE}" "DIR=" $1
			${If} $1 != "$EXEDIR"
				${ConfigWrite} "$0\${FLAGFILE}" "DIR=" "$EXEDIR" $2
			${EndIf}
		${EndIf}
	${UserNextINIPair}

	${If} ${RunningX64}
		StrCpy $usedexe "${SYBDIR}\${SYBEXE64}"
	${Else}
		StrCpy $usedexe "${SYBDIR}\${SYBEXE}"
	${EndIf}
FunctionEnd

Function CreateLink
	; Delete "${LINKINITEMP}"
	StrCpy $0 1
	${UserForEachINIPair} "${USERINIPATH}" "${LINKSEC}" $SecString $SecVaule
		ExpandEnvStrings $1 "$SecString"
		ExpandEnvStrings $2 "$SecVaule"
		${WordFind} "$1" "," "+1" $1
		${GetRoot} "$1" $3
		StrCmp $3 "" 0 +2
		StrCpy $1 "$EXEDIR\Data\$1"
		${ConfigRead} "$1\${FLAGFILE}" "DIR=" $3
		${ConfigRead} "$2\${FLAGFILE}" "DIR=" $4
		ClearErrors
/* 		${If} $4 == ""
			WriteINIStr "${LINKINITEMP}" "LinkTemp" $0 "$SecString|$SecVaule"
			IntOp $0 $0 + 1
		${ElseIf} $3 != $4
		${AndIfNot} ${FileExists} "$4"
			WriteINIStr "${LINKINITEMP}" "LinkTemp" $0 "$SecString|$SecVaule"
			IntOp $0 $0 + 1
		${EndIf} */
		WriteINIStr "${LINKINITEMP}" "LinkTemp" $0 "$SecString|$SecVaule"
		IntOp $0 $0 + 1
		${IfThen} ${Errors} ${|} MessageBox MB_OK "$(LinkMessage1)" ${|}
		${If} ${FileExists} "$4"
		${AndIfNot} $3 == $4
			MessageBox MB_OK "$(LinkMessage2)"
			Quit
		${EndIf}
	${UserNextINIPair}
	StrCpy $0 1
	${Do}
		ClearErrors
		ReadINIStr $1 "${LINKINITEMP}" "LinkTemp" $0
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${WordFind} "$1" "|" "+1" $SecString
		${WordFind} "$1" "|" "-1" $SecVaule
		ExpandEnvStrings $1 "$SecVaule"
		${PathIsUNC} $1 $DstUncFlag
		${If} $DstUncFlag == "isunc"
			StrCpy $OptFlag "copy"
		${ElseIf} $DstUncFlag == "notunc"
			${If} ${AtLeastWinVista}
				StrCpy $osflag "issym"
				StrCpy $OptFlag "link"
			${Else}
				StrCpy $osflag "isjun"
			${EndIf}
		${EndIf}
		${If} $osflag == "isjun"
			${WordFind} "$SecString" "," "+1" $linksrcname
			ExpandEnvStrings $1 "$linksrcname"
			${GetRoot} "$1" $2
			${if} $2 == ""
				StrCpy $1 "$EXEDIR\Data\$1"
			${EndIf}
			GetFullPathName $1 "$1"
			${If} $1 == ""
				StrCpy $SrcNtfsFlag "null"
			${Else}
				${PathIsNTFS} "$1" "$SrcNtfsFlag"
			${EndIf}
			${If} $SrcNtfsFlag == "isntfs"
				StrCpy $OptFlag "link"
			${Else}
				StrCpy $OptFlag "copy"
			${EndIf}
		${EndIf}
		${If} $OptFlag == "link"
			${DstDirCheck} "$SecString" "$SecVaule"
			${WordFind} "$SecString" "," "+1" $linksrcname
			${If} $osflag == "issym"
				ExpandEnvStrings $1 "$linksrcname"
				${GetRoot} "$1" $2
				${if} $2 == ""
					StrCpy $1 "$EXEDIR\Data\$1"
				${EndIf}
				GetFullPathName $1 "$1"
				ExpandEnvStrings $2 $SecVaule
				${WordFind} "$SecString" "," "#" $3
				${If} $3 != $SecString
				${AndIf} $3 > 1
					${WordFind} "$SecString" "," "-1" $3
					ExecDos::exec /TOSTACK '"$usedexe" ${SYBSWITCH2} /l=$3 "$1" "$2"' '' ''
				${Else}
					ExecDos::exec /TOSTACK '"$usedexe" ${SYBSWITCH2} "$1" "$2"' '' ''
				${EndIf}
				Pop $3
				${If} $3 != 0
					StrCpy $OptFlag "copy"
					WriteINIStr "${LINKINIPATH}" "${LINKOPTSEC}" "${LINKOPTSEC}$0" '"Failed||issym||$linksrcname"'
				${Else}
					WriteINIStr "${LINKINIPATH}" "${LINKOPTSEC}" "${LINKOPTSEC}$0" '"Ok||issym||$1"'
					DeleteINIStr "${LAUNCHERINIPATH}" "${MOVESEC}" "$linksrcname"
					ReadINIStr $3 "$2\${FLAGFILE}" "${FLAGFILE}" "INUSE"
					StrCpy $3 "$3$EXEFILE"
					WriteINIStr "$2\${FLAGFILE}" "${FLAGFILE}" "INUSE" "$3"
				${EndIf}
			${Else}
				${WordFind} "$SecString" "," "+1" $linksrcname
				ExpandEnvStrings $1 "$linksrcname"
				${GetRoot} "$1" $2
				${if} $2 == ""
					StrCpy $1 "$EXEDIR\Data\$1"
				${EndIf}
				GetFullPathName $1 "$1"
				ExpandEnvStrings $2 "$SecVaule"
				${WordFind} "$SecString" "," "#" $3
				${If} $3 > 1
					${WordFind} "$SecString" "," "-1" $3
					ExecDos::exec /TOSTACK '"$usedexe" ${SYBSWITCH1} /l=$3 "$1" "$2"' '' ''
				${Else}
					ExecDos::exec /TOSTACK '"$usedexe" ${SYBSWITCH1} "$1" "$2"' '' ''
				${EndIf}
				Pop $3
				${If} $3 != 0
					StrCpy $OptFlag "copy"
					WriteINIStr "${LINKINIPATH}" "${LINKOPTSEC}" "${LINKOPTSEC}$0" '"Failed||isjun||$linksrcname"'
				${Else}
					WriteINIStr "${LINKINIPATH}" "${LINKOPTSEC}" "${LINKOPTSEC}$0" '"Ok||isjun||$1"'
					DeleteINIStr "${LAUNCHERINIPATH}" "${MOVESEC}" "$linksrcname"
					ReadINIStr $3 "$2\${FLAGFILE}" "${FLAGFILE}" "INUSE"
					StrCpy $3 "$3$EXEFILE"
					WriteINIStr "$2\${FLAGFILE}" "${FLAGFILE}" "INUSE" "$3"
				${EndIf}
			${EndIf}
		${EndIf}
		${If} $OptFlag == "copy"
			${WordFind} "$SecString" "," "+1" $1
			${UserForEachINIPair} "${USERINIPATH}" "${MOVESEC}" $2 $3
				StrLen $4 "$1"
				StrCpy $5 "$2" $4
				${If} $5 == $1
					ExpandEnvStrings $2 "$2"
					WriteINIStr "${LAUNCHERINIPATH}" "${MOVESEC}" $2 $3
				${EndIf}
			${UserNextINIPair}
			${UserForEachINIPair} "${USERINIPATH}" "${FILESEC}" $2 $3
				StrLen $4 "$1"
				StrCpy $5 "$2" $4
				${If} $5 == $1
					ExpandEnvStrings $2 "$2"
					WriteINIStr "${LAUNCHERINIPATH}" "${FILESEC}" $2 $3
				${EndIf}
			${UserNextINIPair}
		${ElseIf} $OptFlag == "link"
			${WordFind} "$SecString" "," "+1" $1
			${UserForEachINIPair} "${USERINIPATH}" "${MOVESEC}" $2 $3
				StrLen $4 "$1"
				StrCpy $5 "$2" $4
				${If} $5 == $1
					; WriteINIStr ${USERINIPATH} "${MOVESEC}" $2 $3
					ExpandEnvStrings $2 "$2"
					DeleteINIStr "${LAUNCHERINIPATH}" "${MOVESEC}" $2
				${EndIf}
			${UserNextINIPair}
			${UserForEachINIPair} "${USERINIPATH}" "${FILESEC}" $2 $3
				StrLen $4 "$1"
				StrCpy $5 "$2" $4
				${If} $5 == $1
					; WriteINIStr ${USERINIPATH} "${MOVESEC}" $2 $3
					ExpandEnvStrings $2 "$2"
					DeleteINIStr "${LAUNCHERINIPATH}" "${FILESEC}" $2
				${EndIf}
			${UserNextINIPair}
		${EndIf}
		IntOp $0 $0 + 1
	${Loop}
FunctionEnd

Function RemoveLink
	StrCpy $0 1
	${Do}
		ClearErrors
		ReadINIStr $1 "${LINKINITEMP}" "LinkTemp" $0
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${WordFind} "$1" "|" "+1" $SecString
		${WordFind} "$1" "|" "-1" $SecVaule
		; MessageBox MB_OK "$SecString$\n$SecVaule"
		${WordFind} "$SecString" "," "#" $2
		ExpandEnvStrings $R2 "$SecVaule"
		ReadINIStr $4 "$R2\${FLAGFILE}" "${FLAGFILE}" "INUSE"
		${If} $2 == $SecString
		${AndIf} $4 == $EXEFILE
			${GetFileAttributes} "$R2" "DIRECTORY" $3
			${If} $3 == 1
				RMDir "$R2"
			${Else}
				Delete "$R2"
			${EndIf}
			${If} ${FileExists} "$R2_$BaseName"
				Rename "$R2_$BaseName" "$R2"
			${EndIf}
		${ElseIf} $2 == 2
		${AndIf} $4 == $EXEFILE
			${WordFind} "$SecString" "," "+1" $R1
			ExpandEnvStrings $R1 "$R1"
			${GetRoot} "$R1" $3
			${If} $3 == ""
				StrCpy $R1 "$EXEDIR\Data\$R1"
			${EndIf}
			${Locate} "$R1" "/G=1" "linklevel"
		${EndIf}
		${WordReplace} "$4" "$EXEFILE" "" "+" $4
		WriteINIStr "$R2\${FLAGFILE}" "${FLAGFILE}" "INUSE" "$4"
		IntOp $0 $0 + 1
	${Loop}
	Delete "${LINKINITEMP}"
FunctionEnd


