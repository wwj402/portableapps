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
!define NSISXMLSEC "FileWrite_C"

!ifdef XMLWriteAttrib
	!error "XMLWriteAttrib has defined!"
!else
	!macro XMLWriteAttribCall _FILE _XPATH _ATTRIB _VAR
		Push `${_FILE}`
		Push `${_XPATH}`
		Push `${_ATTRIB}`
		Push `${_VAR}`
		${CallArtificialFunction} XMLWriteAttrib_
	!macroend
	!define XMLWriteAttrib '!insertmacro XMLWriteAttribCall'
	!macro XMLWriteAttrib_
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
		push $9
		nsisXML::create
		nsisXML::load "$4"
		IntCmp $0 0 ${__MACRO__}error
		nsisXML::select `$5`
		IntCmp $1 0 0 ${__MACRO__}find ${__MACRO__}find
		${WordFind} "$5" "/" "*" $8
		StrCmp $5 $8 0 +3
		nsisXML::release "$0"
		Goto ${__MACRO__}error
		${WordFind} "$5" "/" "+$8{" $8
		nsisXML::select `$8`
		IntCmp $1 0 0 +3 +3
		nsisXML::release "$0"
		Goto ${__MACRO__}error
		${WordFind} "$5" "/" "-1" $8
		${WordFind2x} "$8" "[" "]" "#" $9
		${Select} $9
		${Case} 1
			${WordFind} "$8" "[" "+1" $9
			nsisXML::createElement "$9"
			nsisXML::appendChild
			${WordFind2x} "$8" "@" "=" "+1" $9
			StrCmp $8 $9 ${__MACRO__}error 0
			${WordFind2x} "$8" "=" "]" "+1" $3
			StrCmp $8 $3 ${__MACRO__}error 0
			nsisXML::parentNode
			nsisXML::setAttribute "$9" "$3"
		${Case} $8
			nsisXML::createElement "$8"
			nsisXML::appendChild
		${EndSelect}
		${__MACRO__}find:
		nsisXML::parentNode
		nsisXML::setAttribute "$6" "$7"
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
!endif
!ifdef XMLWriteText
	!error "XMLWriteText has defined!"
!else
	!macro XMLWriteTextCall _FILE _XPATH _VAR
		Push `${_FILE}`
		Push `${_XPATH}`
		Push `${_VAR}`
		${CallArtificialFunction} XMLWriteText_
	!macroend
	!define XMLWriteText '!insertmacro XMLWriteTextCall'
	!macro XMLWriteText_
		Exch $6 ;_VAR
		Exch
		Exch $5 ;_XPATH
		Exch
		Exch 2
		Exch $4 ;_FILE
		Exch 2
		Push $0
		Push $1
		Push $2
		Push $3
		push $7
		push $8
		nsisXML::create
		nsisXML::load "$4"
		IntCmp $0 0 ${__MACRO__}error
		nsisXML::select `$5`
		IntCmp $1 0 0 ${__MACRO__}find ${__MACRO__}find
		${WordFind} "$5" "/" "*" $7
		StrCmp $5 $7 0 +3
		nsisXML::release "$0"
		Goto ${__MACRO__}error
		${WordFind} "$5" "/" "+$7{" $7
		nsisXML::select `$7`
		IntCmp $1 0 0 +3 +3
		nsisXML::release "$0"
		Goto ${__MACRO__}error
		${WordFind} "$5" "/" "-1" $7
		${WordFind2x} "$7" "[" "]" "#" $8
		${Select} $8
		${Case} 1
			${WordFind} "$7" "[" "+1" $8
			nsisXML::createElement "$8"
			nsisXML::appendChild
			${WordFind2x} "$7" "@" "=" "+1" $8
			StrCmp $7 $8 ${__MACRO__}error 0
			${WordFind2x} "$7" "=" "]" "+1" $3
			StrCmp $7 $3 ${__MACRO__}error 0
			nsisXML::parentNode
			nsisXML::setAttribute "$7" "$3"
		${Case} $7
			nsisXML::createElement "$7"
			nsisXML::appendChild
		${EndSelect}
		${__MACRO__}find:
		nsisXML::parentNode
		nsisXML::setText  "$6"
		nsisXML::save "$4"
		nsisXML::release "$0"
		Goto ${__MACRO__}End
		${__MACRO__}error:
		SetErrors
		${__MACRO__}End:
		Pop $8
		Pop $7
		Pop $3
		Pop $2
		Pop $1
		Pop $0
		Pop $6
		Pop $5
		Pop $4
	!macroend
!endif

; LangString XmlMessage1 1033 "It is possible that the program is exiting.$\r$\nPlease wait for the program to exit completely and then run again."
; LangString XmlMessage1 2052 "可能程序正在退出中。$\r$\n请等待程序完全退出后再次运行。"

/* ${Segment.onInit}
	nop
!macroend */

/* ${SegmentInit}
	nop
!macroend */

/* ${SegmentPre}
	nop
!macroend */

${SegmentPrePrimary}
	StrCpy $R0 0
	${Do}
		; This time we ++ at the start so we can use Continue
		IntOp $R0 $R0 + 1
		ClearErrors
		${ReadLauncherConfig} $0 ${NSISXMLSEC}$R0 Type
		${ReadLauncherConfig} $7 ${NSISXMLSEC}$R0 File
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}

		; Read the remaining items from the config
!ifdef NSISXMLSEC
		${If} $0 == "XML attribute"
			${ReadLauncherConfig} $2 ${NSISXMLSEC}$R0 XPath
			${ReadLauncherConfig} $3 ${NSISXMLSEC}$R0 Attribute
			${ReadLauncherConfig} $4 ${NSISXMLSEC}$R0 Value
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $4
		${ElseIf} $0 == "XML text"
			${ReadLauncherConfig} $2 ${NSISXMLSEC}$R0 XPath
			${ReadLauncherConfig} $3 ${NSISXMLSEC}$R0 Value
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $3
!else
		${If} $0 == "XML attribute"
		${OrIf} $0 == "XML text"
			${Continue}
!endif
		${Else}
			${Continue}
		${EndIf}
		${ParseLocations} $7
		${ForEachFile} $1 $R4 $7
!ifdef NSISXMLSEC
			${If} $0  == "XML attribute"
				${DebugMsg} "Writing configuration to a file with XMLWriteAttrib.$\r$\nFile: $1$\r$\nXPath: `$2`$\r$\nAttrib: `$3`$\r$\nValue: `$4`"
				${XMLWriteAttrib} $1 $2 $3 $4
;				${IfThen} ${Errors} ${|} ${DebugMsg} "XMLWriteAttrib XPath error" ${|}
			${ElseIf} $0 == "XML text"
				${ParseLocations} $3
				${DebugMsg} "Writing configuration to a file with XMLWriteText.$\r$\nFile: $1$\r$\nXPath: `$2`$\r$\n$\r$\nValue: `$3`"
				${XMLWriteText} $1 $2 $3
;				${IfThen} ${Errors} ${|} ${DebugMsg} "XMLWriteText XPath error" ${|}
			${EndIf}
!else
			${Continue}
!endif
		${NextFile}
	${Loop}
!macroend

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

/* ${SegmentPostPrimary}
; !macro ${SegmentSpecial}_PostPrimary
	nop
!macroend */

/* ${SegmentPostSecondary}
; !macro ${SegmentSpecial}_PostSecondary
	Nop
!macroend */

/* ${SegmentPost}
; !macro ${SegmentSpecial}_Post
	Nop
!macroend */

/* ${SegmentUnload}
; !macro ${SegmentSpecial}_Unload
	Nop
!macroend */