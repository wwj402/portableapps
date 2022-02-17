!include TrimWhite.nsh

Var _User_FEIP_FileHandle
Var _User_FEIP_Line
Var _User_FEIP_LineLength
Var _User_User_FEIP_CharNum
Var _User_FEIP_Char

!macro UserForEachINIPair _INIPATH SECTION KEY VALUE
	!ifdef _UserForEachINIPair_Open
		!error "There is already a UserForEachINIPair clause open!"
	!endif
	!define _UserForEachINIPair_Open
	${If} $_User_FEIP_FileHandle == ""
		FileOpen $_User_FEIP_FileHandle ${_INIPATH} r
	${Else}
		FileSeek $_User_FEIP_FileHandle 0
	${EndIf}
	${Do}
		ClearErrors
		FileRead $_User_FEIP_FileHandle $_User_FEIP_Line
		${TrimNewLines} $_User_FEIP_Line $_User_FEIP_Line
		${If} ${Errors} ; end of file
		${OrIf} $_User_FEIP_Line == "[${SECTION}]" ; right section
			${ExitDo}
		${EndIf}
	${Loop}

	${IfNot} ${Errors} ; right section
		${Do}
			ClearErrors
			FileRead $_User_FEIP_FileHandle $_User_FEIP_Line

			StrCpy $_User_FEIP_LineLength $_User_FEIP_Line 1
			${If} ${Errors} ; end of file
			${OrIf} $_User_FEIP_LineLength == '[' ; new section
				${ExitDo} ; finished
			${EndIf}

			${If} $_User_FEIP_LineLength == ';' ; a comment line
				${Continue}
			${EndIf}

			StrLen $_User_FEIP_LineLength $_User_FEIP_Line
			StrCpy $_User_User_FEIP_CharNum '0'
			${Do}
				StrCpy $_User_FEIP_Char $_User_FEIP_Line 1 $_User_User_FEIP_CharNum
				${IfThen} $_User_FEIP_Char == '=' ${|} ${ExitDo} ${|}
				IntOp $_User_User_FEIP_CharNum $_User_User_FEIP_CharNum + 1
			${LoopUntil} $_User_User_FEIP_CharNum > $_User_FEIP_LineLength

			${TrimNewLines} $_User_FEIP_Line $_User_FEIP_Line

			${If} $_User_FEIP_Char == '='
				StrCpy ${KEY} $_User_FEIP_Line $_User_User_FEIP_CharNum
				IntOp $_User_User_FEIP_CharNum $_User_User_FEIP_CharNum + 1
				StrCpy ${VALUE} $_User_FEIP_Line "" $_User_User_FEIP_CharNum

				; Get rid of any leading or trailing whitespace
				${TrimWhite} ${KEY}
				${TrimWhite} ${VALUE}

				; Get rid of quotes on a quoted string
				; (This leaves whitespace inside intact.)
				StrCpy $_User_User_FEIP_CharNum ${VALUE} 1
				StrCpy $_User_FEIP_Char ${VALUE} "" -1
				${If} $_User_User_FEIP_CharNum == $_User_FEIP_Char
					${If} $_User_FEIP_Char == "'"
					${OrIf} $_User_FEIP_Char == '"'
						StrCpy ${VALUE} ${VALUE} -1 1
					${EndIf}
				${EndIf}
!macroend

!macro UserNextINIPair
	!ifndef _UserForEachINIPair_Open
		!error "There isn't a UserForEachINIPair clause open!"
	!endif
	!undef _UserForEachINIPair_Open
			${EndIf}
		${Loop}
	${EndIf}
	FileClose $_User_FEIP_FileHandle
	StrCpy $_User_FEIP_FileHandle ""
!macroend

!define UserForEachINIPair '!insertmacro UserForEachINIPair'
!define UserNextINIPair '!insertmacro UserNextINIPair'
