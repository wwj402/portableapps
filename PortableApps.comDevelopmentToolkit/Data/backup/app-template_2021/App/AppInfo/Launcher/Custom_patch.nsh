
Var appdir
Var appdir64
Var patchdir
Var commdir
Var suffix
Var tempvar1
Var tempvar2
Var tempvar3
Var tempvar4
!define PATCH "$EXEDIR\Data\Patch"
!define SUFFIX "64"

!macro macro_name _SUFFIX64 _PATH
	StrCpy $patchdir "${_PATH}"
	StrCpy $suffix "${_SUFFIX64}"
	${DirState} "$patchdir" $tempvar1
	${If} tempvar1 = 1;
		ReadINIStr $tempvar1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable64
		${If} $tempvar1 != ""
		${AndIf} ${FileExists} "$EXEDIR\App\$tempvar1"
			${GetParent} "$EXEDIR\App\$tempvar1" $tempvar2
			StrCpy $appdir64 "$tempvar2"
		${EndIf}
		ReadINIStr $tempvar1 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable
		${If} $tempvar1 != ""
		${AndIf} ${FileExists} "$EXEDIR\App\$tempvar1"
			${GetParent} "$EXEDIR\App\$tempvar1" $tempvar2
			StrCpy $appdir "$tempvar2"
		${EndIf}
		${If} $appdir64 != ""
		${AndIf} $appdir != ""
			${Locate} "$patchdir" "/L=FD /M=*.* /G=0" "PatchApp"
		${ElseIf} $appdir64 != ""
			StrCpy $commdir "$appdir64"
			${Locate} "$commdir" "/L=FD /M=*.* /G=1" "PatchComm"
		${ElseIf} $appdir != ""
			StrCpy $commdir "$appdir"
			${Locate} "$commdir" "/L=FD /M=*.* /G=1" "PatchComm"
		${EndIf}
	${EndIf}
!macroend
Function "PatchApp"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	${If} $R6 == ""
		StrLen $tempvar1 "$suffix"
		StrCpy $tempvar2 "$R7" "" -$tempvar1
		${If} $tempvar2 == $suffix
			StrCpy $commdir "$appdir64\$R7" -$tempvar1
			${If} FileExists "$appdir64"
				${Locate} "$R9" "" "PatchComm"
			${EndIf}
		${Else}
			StrCpy $commdir "$appdir64\$R7"
			${If} FileExists "$appdir"
				${Locate} "$R9" "" "PatchComm"
			${EndIf}
		${EndIf}
	${Else}
		StrLen $tempvar1 "$suffix"
		${GetBaseName} "$R7" $tempvar2
		StrCpy $tempvar3 "$tempvar2" "" -$tempvar1
		${If} $tempvar3 == $suffix
			${If} FileExists "$appdir64"
				${GetFileExt} "$R7" $tempvar4
				StrCpy $tempvar3 "$appdir64\$tempvar2" -$tempvar1
				StrCpy $tempvar3 "$tempvar3.$tempvar4"
				md5dll::GetMD5File "$tempvar3"
				Pop $tempvar1
				md5dll::GetMD5File "$R9"
				Pop $tempvar2
				${If} $tempvar1 != $tempvar2
					CopyFiles /SILENT "$R9" "$tempvar3"
				${EndIf}
			${EndIf}
		${Else}
			${If} FileExists "$appdir"
				StrCpy $tempvar3 "$appdir\$R7"
				md5dll::GetMD5File "$tempvar3"
				Pop $tempvar1
				md5dll::GetMD5File "$R9"
				Pop $tempvar2
				${If} $tempvar1 != $tempvar2
					CopyFiles /SILENT "$R9" "$tempvar3"
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}
FunctionEnd
Function "PatchComm"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; Push $var    ; If $var="StopLocate" Then exit from function
	${If} $R6 != ""
		${If} FileExists "$appdir64"
			StrLen $tempvar1 "$patchdir"
			StrCpy $tempvar2 "$R9" "" $tempvar1
			StrCpy $tempvar3 "$appdir64$tempvar2"
			md5dll::GetMD5File "$tempvar3"
			Pop $tempvar1
			md5dll::GetMD5File "$R9"
			Pop $tempvar2
			${If} $tempvar1 != $tempvar2
				CopyFiles /SILENT "$R9" "$tempvar3"
			${EndIf}
		${EndIf}
		${If} FileExists "$appdir"
			StrLen $tempvar1 "$patchdir"
			StrCpy $tempvar2 "$R9" "" $tempvar1
			StrCpy $tempvar3 "$appdir64$tempvar2"
			md5dll::GetMD5File "$tempvar3"
			Pop $tempvar1
			md5dll::GetMD5File "$R9"
			Pop $tempvar2
			${If} $tempvar1 != $tempvar2
				CopyFiles /SILENT "$R9" "$tempvar3"
			${EndIf}
		${EndIf}
	${EndIf}
FunctionEnd
