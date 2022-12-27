${SegmentFile}

!ifndef VERSION_NUM
	!searchparse "${NSIS_VERSION}" "v" "VERSION_NUM"
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

!define ATTRIBCHECK "path"
!define ATTRIBOPRATE1 "timestamp"
!define ATTRIBOPRATE2 "is_enabled"
!define XPATHCHECK "/root/apps/item"

Var wallpath
Var wallpara
Var walltype

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

!macro NsisXmlAddCall _FILE _XPATH _ATTRIB _VAR
	Push `${_FILE}`
	Push `${_XPATH}`
	Push `${_ATTRIB}`
	Push `${_VAR}`
	${CallArtificialFunction} NsisXmlAdd_
!macroend
!define NsisXmlAdd '!insertmacro NsisXmlAddCall'
!macro NsisXmlAdd_
	Exch $7 ;_VAR
	Exch
	Exch $6 ;_ATTRIB
	Exch
	Exch 2
	Exch $5 ;_XPATH
	Exch 2
	Exch 3
	Exch $4 ;_FILE
	Exch 3
	Push $0
	Push $1
	Push $2
	Push $3
	push $8
	Push $9
	nsisXML::create
	nsisXML::load "$4"
	IntCmp $0 0 ${__MACRO__}error
	nsisXML::select `$5[@$6="$7"]`
	IntCmp $2 0 0 ${__MACRO__}find ${__MACRO__}find
	${WordFind} "$5" "/" "*" $8
	StrCmp $5 $8 0 +3
	nsisXML::release "$0"
	Goto ${__MACRO__}error
	${WordFind} "$5" "/" "+$8{" $8
	nsisXML::select `$8`
	IntCmp $2 0 0 +3 +3
	nsisXML::release "$0"
	Goto ${__MACRO__}error
	${WordFind} "$5" "/" "-1" $8
	nsisXML::createElement "$8"
	nsisXML::setAttribute "$6" "$7"
	System::Call '*(&i2,&i2,&i2,&i2,&i2,&i2,&i2,&i2) i .r8'
	System::Call 'kernel32::GetLocalTime(i)i(r8)'
	System::Call 'kernel32::SystemTimeToFileTime(i,*l)i(r8,.r9)'
	System::Free $8
	system::Int64Op $9 / 10000000
	Pop $9
	system::Int64Op $9 - 11644473600
	Pop $9
	nsisXML::setAttribute "${ATTRIBOPRATE1}" "$9"
	nsisXML::appendChild
	${__MACRO__}find:
	nsisXML::getAttribute "${ATTRIBOPRATE2}"
	StrCmp $3 "true" 0 +2
	nsisXML::setAttribute "${ATTRIBOPRATE2}" ""
	nsisXML::save "$4"
	nsisXML::release "$0"
	Goto ${__MACRO__}End
	${__MACRO__}error:
	SetErrors
	${__MACRO__}End:
	Pop $9
	Pop $8
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	Pop $7
	Pop $6
	Pop $5
	Pop $4
!macroend

!macro NsisXmlDelCall _FILE _XPATH _ATTRIB _VAR
	Push `${_FILE}`
	Push `${_XPATH}`
	Push `${_ATTRIB}`
	Push `${_VAR}`
	${CallArtificialFunction} NsisXmlDel_
!macroend
!define NsisXmlDel '!insertmacro NsisXmlDelCall'
!macro NsisXmlDel_
	Exch $7 ;_VAR
	Exch
	Exch $6 ;_ATTRIB
	Exch
	Exch 2
	Exch $5 ;_XPATH
	Exch 2
	Exch 3
	Exch $4 ;_FILE
	Exch 3
	Push $0
	Push $1
	Push $2
	Push $3
	push $8
	Push $9
	nsisXML::create
	nsisXML::load "$4"
	IntCmp $0 0 ${__MACRO__}error
	nsisXML::select '$5[@$6="$7"]'
	IntCmp $2 0 0 ${__MACRO__}find ${__MACRO__}find
	nsisXML::release "$0"
	Goto ${__MACRO__}error
	${__MACRO__}find:
	nsisXML::parentNode
	nsisXML::removeChild
	nsisXML::save "$4"
	nsisXML::release "$0"
	Goto ${__MACRO__}End
	${__MACRO__}error:
	SetErrors
	${__MACRO__}End:
	Pop $9
	Pop $8
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	Pop $7
	Pop $6
	Pop $5
	Pop $4
!macroend

; LangString WallMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString WallMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

/* ${Segment.onInit}
	nop
!macroend */

${SegmentInit}
	ClearErrors
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "WallType"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "WallType" "|[no]/system/simplewall"
	StrCpy $strtemp "|[no]/system/simplewall"
	${WordFind} "$strtemp" "|" "+1{" $walltype
	ClearErrors
	${If} ${RunningX64}
		ReadINIStr $wallpath "$EXEDIR\$BaseName.ini" "$BaseName" "WallPath64"
		IfErrors 0 +2
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "WallPath64" ""
	${EndIf}
	ClearErrors
	${If} $wallpath == ""
		ReadINIStr $wallpath "$EXEDIR\$BaseName.ini" "$BaseName" "WallPath"
		IfErrors 0 +2
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "WallPath" ""
	${EndIf}
	ClearErrors
	ReadINIStr $strtemp "$EXEDIR\$BaseName.ini" "$BaseName" "WallPara"
	IfErrors 0 +3
	WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" "WallPara" "[]|[](enable|disable)"
	StrCpy $strtemp "[]|[](enable|disable)"
	${If} $strtemp != ""
		${WordFind} "$strtemp" "(" "+1" $wallpara
		${WordReplace} "$wallpara" "[" "" "+" $wallpara
		${WordReplace} "$wallpara" "]" "" "+" $wallpara
	${EndIf}
!macroend

${SegmentPre}
	ClearErrors
	${Select} $walltype
	${Case} "system"
		ReadEnvStr $1 "ProgramPath"
		ExecDos::exec /DISABLEFSR 'netsh advfirewall firewall add rule name=\
								"PortableApps_TU" dir=out program="$1" action=block' '' ''
	${Case} "simplewall"
		${If} $wallpath != ""
			!insertmacro "path_canonicalize" "$EXEDIR\App" "$wallpath"
			${If} ${FileExists} "$wallpath"
				${GetParent} "$wallpath" $1
				StrCpy $1 "$1\profile.xml"
				${IfNot} ${FileExists} "$1"
					ExecDos::exec /TIMEOUT=1000 "wallpath" "" ""
				${EndIf}
				ReadEnvStr $2 "ProgramPath"
				${NsisXmlAdd} "$1" "${XPATHCHECK}" "${ATTRIBCHECK}" "$2"
				${WordFind} "$wallpara" "|" "+1{" $0
				${If} $0 == ""
					ExecWait '"$wallpath" -install -temp'
				${Else}
					ExecWait '"$wallpath" $0'
				${EndIf}
			${EndIf}
		${EndIf}
	${EndSelect}
!macroend

/* ${SegmentPrePrimary}
	nop
!macroend */

/* ${SegmentPreSecondary}
	nop
!macroend */

/* ${SegmentPreExec}
	nop
!macroend */

/* ${SegmentPreExecPrimary}
	Nop
!macroend */

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

${SegmentPostPrimary}
	ClearErrors
	${Select} $walltype
	${Case} "system"
		ReadEnvStr $1 "ProgramPath"
		ExecDos::exec /DISABLEFSR 'netsh advfirewall firewall delete rule name=\
								"PortableApps_TU" dir=out program="$1"' '' ''
	${Case} "simplewall"
		${If} $wallpath != ""
			!insertmacro "path_canonicalize" "$EXEDIR\App" "$wallpath"
			${If} ${FileExists} "$wallpath"
				${WordFind} "$wallpara" "|" "+1}" $0
				${If} $0 == ""
					ExecWait '"$wallpath" -uninstall'
				${Else}
					ExecWait '"$wallpath" $0'
				${EndIf}
				${GetParent} "$wallpath" $1
				StrCpy $1 "$1\profile.xml"
				ReadEnvStr $2 "ProgramPath"
				${NsisXmlDel} "$1" "${XPATHCHECK}" "${ATTRIBCHECK}" "$2"
			${EndIf}
		${EndIf}
	${EndSelect}
!macroend

/* ${SegmentPostSecondary}
	Nop
!macroend */

/* ${SegmentPost}
	Nop
!macroend */

/* ${SegmentUnload}
	Nop
!macroend */