
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
!define LINKOPTSEC "LinkStatus"
!define SYBEXE "NTLinksMaker.exe"
!define SYBEXE64 "NTLinksMaker64.exe"
!define SYBDIR "$EXEDIR\Data\NTLinksMaker"
!define SYBSWITCH1 "/q /n /b"
!define SYBSWITCH2 "/q /n /b /s"
!define FSFLAG "NTFS"

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

!macro DstDirCheck _SRCPATH _DSTPATH
	Push $0
	Push $1
	Push $2
	Push $3
	ExpandEnvStrings $0 "${_SRCPATH}"
	${GetRoot} "$0" $1
	${if} $1 == ""
		StrCpy $0 "$EXEDIR\Data\${_SRCPATH}"
		ExpandEnvStrings $0 "$0"
	${EndIf}
	ExpandEnvStrings $1 "${_DSTPATH}"
	${If} ${FileExists} "$1"
		${GetFileAttributes} "$1" "REPARSE_POINT" $2
		${If} $2 == "1"
			${If} ${FileExists} "$1\${FLAGFILE}"
				RMDir "$1"
			${Else}
				Rename "$1" "$1_$BaseName"
			${EndIf}
		${Else}
			${If} ${FileExists} "$1\${FLAGFILE}"
				RMDir "$1"
			${Else}
				Rename "$1" "$1_$BaseName"
			${EndIf}
		${EndIf}
	${EndIf}
	Pop $3
	Pop $2
	Pop $1
	Pop $0
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
		StrCpy $0 "$EXEDIR\Data\$SecString"
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
	Delete "$EXEDIR\linktemp.ini"
	StrCpy $2 1
	${UserForEachINIPair} "${USERINIPATH}" "${LINKSEC}" $SecString $SecVaule
		ClearErrors
		WriteINIStr "$EXEDIR\linktemp.ini" "LinkTemp" $2 "$SecString|$SecVaule"
		${If} ${Errors}
			MessageBox MB_OK "error"
		${EndIf}
		IntOp $2 $2 + 1
	${UserNextINIPair}
	StrCpy $0 1
	${Do}
		ClearErrors
		ReadINIStr $1 "$EXEDIR\linktemp.ini" "LinkTemp" $0
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
			ExpandEnvStrings $1 "$SecString"
			${GetRoot} "$1" $2
			${if} $2 == ""
				StrCpy $1 "$EXEDIR\Data\$SecString"
				ExpandEnvStrings $1 "$1"
				GetFullPathName $1 "$1"
			${Else}
				GetFullPathName $1 "$1"
			${EndIf}
			${PathIsNTFS} $1 $SrcNtfsFlag
			${If} $SrcNtfsFlag == "isntfs"
				StrCpy $OptFlag "link"
			${Else}
				StrCpy $OptFlag "copy"
			${EndIf}
		${EndIf}
		${If} $OptFlag == "link"
			${DstDirCheck} $SecString $SecVaule
			${If} $osflag == "issym"
				ExpandEnvStrings $1 "$SecString"
				${GetRoot} "$1" $2
				${if} $2 == ""
					StrCpy $1 "$EXEDIR\Data\$SecString"
					ExpandEnvStrings $1 "$1"
					GetFullPathName $1 "$1"
				${Else}
					GetFullPathName $1 "$1"
				${EndIf}
				ExpandEnvStrings $2 $SecVaule
				ExecDos::exec /TOSTACK '"$usedexe" ${SYBSWITCH2} "$1" "$2"' '' ''
				Pop $3
				${If} $3 != 0
					StrCpy $OptFlag "copy"
					WriteINIStr "${LINKINIPATH}" ${LINKOPTSEC} ${LINKOPTSEC}$0 '"Failed||issym||$1"'
				${Else}
					WriteINIStr "${LINKINIPATH}" ${LINKOPTSEC} ${LINKOPTSEC}$0 '"Ok||issym||$1"'
				${EndIf}
			${Else}
				ExpandEnvStrings $1 "$SecString"
				${GetRoot} "$1" $2
				${if} $2 == ""
					StrCpy $1 "$EXEDIR\Data\$SecString"
					ExpandEnvStrings $1 "$1"
					GetFullPathName $1 "$1"
				${Else}
					GetFullPathName $1 "$1"
				${EndIf}
				ExpandEnvStrings $2 $SecVaule
				ExecDos::exec /TOSTACK '"$usedexe" ${SYBSWITCH1} "$1" "$2"' '' ''
				Pop $3
				${If} $3 != 0
					StrCpy $OptFlag "copy"
					WriteINIStr "${LINKINIPATH}" ${LINKOPTSEC} ${LINKOPTSEC}$0 '"Failed||isjun||$1"'
				${Else}
					WriteINIStr "${LINKINIPATH}" ${LINKOPTSEC} ${LINKOPTSEC}$0 '"Ok||isjun||$1"'
				${EndIf}
			${EndIf}
		${EndIf}
		${If} $OptFlag == "copy"
			${UserForEachINIPair} "${USERINIPATH}" "${MOVESEC}" $2 $3
				StrLen $4 "$SecString"
				StrCpy $5 "$2" $4
				${If} $5 == $SecString
					WriteINIStr ${LAUNCHERINIPATH} ${MOVESEC} $2 $3
				${EndIf}
			${UserNextINIPair}
			${UserForEachINIPair} "${USERINIPATH}" "${FILESEC}" $2 $3
				StrLen $4 "$SecString"
				StrCpy $5 "$2" $4
				${If} $5 == $SecString
					WriteINIStr ${LAUNCHERINIPATH} ${FILESEC} $2 $3
				${EndIf}
			${UserNextINIPair}
		${ElseIf} $OptFlag == "link"
			${UserForEachINIPair} "${USERINIPATH}" "${MOVESEC}" $2 $3
				StrLen $4 "$SecString"
				StrCpy $5 "$2" $4
				${If} $5 == $SecString
					; WriteINIStr ${USERINIPATH} ${MOVESEC} $2 $3
					DeleteINIStr ${LAUNCHERINIPATH} ${MOVESEC} $2
				${EndIf}
			${UserNextINIPair}
			${UserForEachINIPair} "${USERINIPATH}" "${FILESEC}" $2 $3
				StrLen $4 "$SecString"
				StrCpy $5 "$2" $4
				${If} $5 == $SecString
					; WriteINIStr ${USERINIPATH} ${MOVESEC} $2 $3
					DeleteINIStr ${LAUNCHERINIPATH} ${FILESEC} $2
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
		ReadINIStr $1 "$EXEDIR\linktemp.ini" "LinkTemp" $0
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${WordFind} "$1" "|" "+1" $SecString
		${WordFind} "$1" "|" "-1" $SecVaule
		; MessageBox MB_OK "$SecString$\n$SecVaule"
		ExpandEnvStrings $1 "$SecVaule"
		RMDir "$1"
		${If} ${FileExists} "$1_$BaseName"
			Rename "$1_$BaseName" "$1"
		${EndIf}
		IntOp $0 $0 + 1
	${Loop}
	Delete "$EXEDIR\linktemp.ini"
FunctionEnd


