; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "d:\SnapShot\sdlPassolo2018.152\Files\@PROGRAMFILESX86@\SDL Passolo 2018"
!define EXENAME "psl.exe"
!define USERDIR "$APPDATA\SDL\Passolo 2018"

!ifdef NSIS_UNICODE
	!define /file_version MAJOR "${EXEFULLDIR}\${EXENAME}" 0
	!define /file_version MINOR "${EXEFULLDIR}\${EXENAME}" 1
	!define /file_version OPTION "${EXEFULLDIR}\${EXENAME}" 2
	!define /file_version BUILD "${EXEFULLDIR}\${EXENAME}" 3
	!define VER ${MAJOR}.${MINOR}.${OPTION}.${BUILD}
	!undef MAJOR
	!undef MINOR
	!undef OPTION
	!undef BUILD
!else
	!echo "${NSIS_VERSION}"
	!getdllversion "${EXEFULLDIR}\${EXENAME}" Expv_
	!define VER "${Expv_1}.${Expv_2}.${Expv_3}.${Expv_4}"
!endif
!echo "${VER}"
!if ${VER} == "..."
	!undef VER
	!define /date VER "%Y.%m.%d.0"
	; !define VER "18.0.0.0"
!endif

!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /noerrors /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME "}\
, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, LegalCopyright={" LEGALCOPYRIGHT "},"
!searchparse /noerrors /file "ProductInfo.ini" "LegalTrademarks={" LEGALTRADEMARKS "}\
, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /noerrors /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION "}\
, SpecialBuild={" SPECIALBUILD "},"

!define APPNAME "Passolo"				; complete name of program
!define APP "Passolo"					; short name of program without space and accent  this one is used for the final executable an in the directory structure
!define APPEXE "psl.exe"				; main exe name
!define APPEXE64 "psl.exe"				; main exe 64 bit name
!define APPDIR "$EXEDIR"				; main exe relative path
!define APPSWITCH 	``
; !define JAVAHOME	"jre"
; !define JAVAHOME64	"jre64"
!define PSLREGROOT "HKCU"
!define PSLREGSUB "Software\SDL\Passolo 2018\System"
!define PSLREGNAME "Language"
!define IDFILEDIR "System\DnAndroidParser"
!define IDFILE "DnAndroidParser.dll"
!define CNDIR "System_zh-CN"
!define ENDIR "System_en-US"
!define LANGUAGEFILES "system.exe"
!define USERLANGUAGEFILES "user.exe"
!define LANGUAGEROOT "HKLM"
!define LANGUAGESUB "SOFTWARE\Classes\MIME\Database\Rfc1766"
!define LAUNCHERCFG "Passololauncher.ini"
!define APPPATCH "Patch"
!define JAVAREG "Psl_java7z.exe"


; **************************************************************************
; === Best Compression ===
; **************************************************************************
!ifndef NSIS_UNICODE
	Unicode true
!endif
SetCompressor /SOLID lzma
SetCompressorDictSize 32

; **************************************************************************
; === Includes ===
; **************************************************************************

!include "LogicLib.nsh"
!include "x64.nsh"
!include "SetEnvironmentVariable.nsh"
; !include "ForEachPath.nsh"
!include "FileFunc.nsh"
!include "ProcFunc.nsh"
!include "WordFunc.nsh"
; !include "Registry.nsh"


; **************************************************************************
; === Set basic information ===
; **************************************************************************
Name "${APP} Launcher"
OutFile ".\${APP}Launcher${PRODUCTVERSION}.exe"
Icon ".\${EXENAME}${PRODUCTVERSION}.ico"
SilentInstall silent

; **************************************************************************
; === Set version information ===
; **************************************************************************
Caption "${PRODUCTNAME}"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "${PRODUCTNAME}"
VIAddVersionKey Comments "${COMMENTS}"
VIAddVersionKey CompanyName "${COMPANYNAME}"
VIAddVersionKey LegalCopyright "${LEGALCOPYRIGHT}"
VIAddVersionKey FileDescription "${FILEDESCRIPTION}"
VIAddVersionKey FileVersion "${FILEVERSION}"
VIAddVersionKey ProductVersion "${PRODUCTVERSION}"
VIAddVersionKey InternalName "${ORIGINALFILENAME}"
VIAddVersionKey LegalTrademarks "${LEGALTRADEMARKS}"
VIAddVersionKey OriginalFilename "${ORIGINALFILENAME}"

; **************************************************************************
; === Other Actions ===
; **************************************************************************

Var uilanguage
Var AppID
Var homedir
Var PslFindOutput
Var PslFindPath
Var PslFindPid
Var BaseDir
; Var Macro_temp1
; Var Macro_temp2
; Var PslSpoonFileName
; Var PslSpoonPid
LangString Message1 1033 "${APPEXE} is running. Path $PslFindPath. $\r$\n\
							Please close the program, then run again. "
LangString Message1 2052 "${APPEXE} 正在运行。路径 $PslFindPath。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message2 1033 "${APPEXE} is running. Some files need to be copied. $\r$\n\
							Please close the program, then run again. "
LangString Message2 2052 "${APPEXE} 正在运行。需要拷贝文件。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message3 1033 "${LAUNCHERCFG} UpdatePatch=true$\r$\n\
							Update $1 to software. "
LangString Message3 2052 "${LAUNCHERCFG} UpdatePatch=true$\r$\n\
							更新 $1 到软件。"
LangString Message4 1033 "${LAUNCHERCFG} userjava=true$\r$\n\
							Use custom Java JRE. "
LangString Message4 2052 "${LAUNCHERCFG} userjava=true$\r$\n\
							使用自定义 Java JRE。"


; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"

    IfFileExists "${APPDIR}\${APPPATCH}\*.*" 0 PATCHSKIP1
    ${EnumProcessPaths} "PslFind" $PslFindOutput
    ${Locate} "${APPDIR}\${APPPATCH}" "/L=FD /M=*.*" "AppPatch"
    PATCHSKIP1:

	StrCpy $BaseDir "$EXEDIR"
!macro Java_Reg _OS _JAVAPATH
	${If} ${_JAVAPATH} != ""
		Push ${_JAVAPATH}
		Call PathParse
		Pop $Macro_temp1
		${If} $Macro_temp1 != ""
			${If} ${_OS} == 64
				SetRegView 64
				WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion" "1.8"
				WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\1.8" "JavaHome" "$Macro_temp1"
				StrCpy $Macro_temp2 "$Macro_temp1" "" -1
				${If} $Macro_temp2 == "\"
					StrCpy $Macro_temp2 "$Macro_temp1" -1
					WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\1.8" "RuntimeLib" "$Macro_temp2\server\jvm.dll"
				${Else}
					StrCpy $Macro_temp2 "$Macro_temp1"
					WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\1.8" "RuntimeLib" "$Macro_temp2\server\jvm.dll"
				${EndIf}
			${ElseIf} ${_OS} == 32
				SetRegView 32
				WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion" "1.8"
				WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\1.8" "JavaHome" "$Macro_temp1"
				StrCpy $Macro_temp2 "$Macro_temp1" "" -1
				${If} $Macro_temp2 == "\"
					StrCpy $Macro_temp2 "$Macro_temp1" -1
					WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\1.8" "RuntimeLib" "$Macro_temp2\client\jvm.dll"
				${Else}
					StrCpy $Macro_temp2 "$Macro_temp1"
					WriteRegStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\1.8" "RuntimeLib" "$Macro_temp2\client\jvm.dll"
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}	
!macroend

	ReadEnvStr $0 VMDIR
	${If} $0 != ""
		StrCpy $1 "$0" "" -1
		${If} $1 != "\"
			StrCpy $0 "$0\"
		${EndIf}
		${If} ${FileExists} "$0${LAUNCHERCFG}"
			ReadINIStr $1 "$0${LAUNCHERCFG}" "SDL_PSL" "userjava"
			${If} $1 == "true"
				${If} ${RunningX64}
					ReadINIStr $1 "$0${LAUNCHERCFG}" "SDL_PSL" "Java64Path"
					${If} $1 != ""
						MessageBox MB_OK "$(Message4)"
						; ExecDos::exec /TOSTACK '"$EXEDIR\${JAVAREG}" -os=64 -path="$1"'
						ExecWait '"$EXEDIR\${JAVAREG}" -! -os=64 -path="$1"'
						; !insertmacro "Java_Reg" "64" "$1"
					${Else}
						ReadINIStr $1 "$0${LAUNCHERCFG}" "SDL_PSL" "JavaPath"
						${If} $1 != ""
							ExecWait '"$EXEDIR\${JAVAREG}" -! -os=32 -path="$1"'
							; !insertmacro "Java_Reg" "32" "$1"
						${EndIf}
					${EndIf}
				${Else}
					ReadINIStr $1 "$0${LAUNCHERCFG}" "SDL_PSL" "JavaPath"
					${If} $1 != ""
						ExecWait '"$EXEDIR\${JAVAREG}" -! -os=32 -path="$1"'
						; !insertmacro "Java_Reg" "32" "$1"
					${EndIf}
				${EndIf}
			${EndIf}
		${Else}
			WriteINIStr "$0${LAUNCHERCFG}" "SDL_PSL" "JavaPath" ""
			WriteINIStr "$0${LAUNCHERCFG}" "SDL_PSL" "Java64Path" ""
			WriteINIStr "$0${LAUNCHERCFG}" "SDL_PSL" "userjava" "false"
			WriteINIStr "$0${LAUNCHERCFG}" "SDL_PSL" "PatchPath" ""
			WriteINIStr "$0${LAUNCHERCFG}" "SDL_PSL" "UpdatePatch" "false"
		${EndIf}
		ReadINIStr $1 "$0${LAUNCHERCFG}" "SDL_PSL" "UpdatePatch"
		${If} $1 == "true"
			StrCpy $BaseDir "$0"
			ReadINIStr $1 "$0${LAUNCHERCFG}" "SDL_PSL" "PatchPath"
			${If} $1 != ""
				Push $1
				Call PathParse
				Pop $1
				MessageBox MB_OK "$(Message3)"
				${If} $1 != ""
					StrCpy $2 "$1" "" -1
					${If} $2 == "\"
						CopyFiles "$1*.*" "${APPDIR}"
					${Else}
						CopyFiles "$1\*.*" "${APPDIR}"
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}

	ReadEnvStr $homedir PSLHOME
	${IfThen} $homedir == "" ${|} StrCpy $homedir "${APPDIR}" ${|}
	; MessageBox MB_OK "$homedir"
	StrCpy $AppID "Portable"
	${SetEnvironmentVariable} PSLHOME $homedir
	ReadRegDWORD $uilanguage ${PSLREGROOT} "${PSLREGSUB}" ${PSLREGNAME}
	IntFmt $0 "0x%04x" "$uilanguage"
	System::Call "kernel32::LCIDToLocaleName(i r0, t .r1, i 0, l 0) i .r2"
	System::Call "kernel32::LCIDToLocaleName(i r0, t .r1, i r2, l 0) i .r2"
	; MessageBox MB_OK "$uilanguage, $0, $1, $2"
	${If} $2 == 0
		IntFmt $0 "%04x" "$uilanguage"
		ReadRegStr $1 ${LANGUAGEROOT} "${LANGUAGESUB}" "$0"
		${WordFind} "$1" ";" "+1" $1
		; MessageBox MB_OK "$uilanguage, $0, $1"
	${EndIf}

	; MessageBox MB_OK "$uilanguage, $1"
	${Select} $1
	${Case} "zh-CN"
		SetOverwrite on
		SetOutPath "${USERDIR}"
		File /r "${EXEFULLDIR}\zh-CN\*.dat"
	${Case} "de-DE"
		SetOverwrite on
		SetOutPath "${USERDIR}"
		File /r "${EXEFULLDIR}\de-DE\*.dat"
	${Case} "de"
		SetOverwrite on
		SetOutPath "${USERDIR}"
		File /r "${EXEFULLDIR}\de-DE\*.dat"
	; ${Case} "ru-RU"
	; 	SetOverwrite on
	; 	SetOutPath "${USERDIR}"
	; 	File /r "${EXEFULLDIR}\ru-RU\*.dat"
	; ${Case} "ru"
	; 	SetOverwrite on
	; 	SetOutPath "${USERDIR}"
	; 	File /r "${EXEFULLDIR}\ru-RU\*.dat"
	${CaseElse}
		SetOverwrite on
		SetOutPath "${USERDIR}"
		File /r "${EXEFULLDIR}\en-US\*.dat"
	${EndSelect}

	${If} $uilanguage == 2052

		md5dll::GetMD5File "$homedir\${IDFILEDIR}\${IDFILE}"
		Pop $3
		md5dll::GetMD5File "$homedir\${CNDIR}\${IDFILE}"
		Pop $4
		; MessageBox MB_OK "$3||$4"
		${If} $3 != $4

			${EnumProcessPaths} "PslFind" $PslFindOutput
			${GetProcessPath} "${APPEXE}" $0
			; MessageBox MB_OK "$0"
			${If} $0 != "$homedir\${APPEXE}"
				ExecWait "$homedir\${CNDIR}\${LANGUAGEFILES}"
				ExecWait "$homedir\${CNDIR}\${USERLANGUAGEFILES}"
			${Else}
				/* MessageBox MB_YESNO "$(Message2)" IDYES WaitAndRun1 IDNO 0
				Abort
				WaitAndRun1:
				${ProcessWaitClose} "${APPEXE}" "-1" $2
				${ProcessWaitClose} "$PslSpoonFileName" "-1" $2
				ExecWait "$homedir\${CNDIR}\${LANGUAGEFILES}"
				ExecWait "$homedir\${CNDIR}\${USERLANGUAGEFILES}" */
				MessageBox MB_OK "$(Message2)"
				Abort
			${EndIf}

		${EndIf}

	${Else}
		md5dll::GetMD5File "$homedir\${IDFILEDIR}\${IDFILE}"
		Pop $3
		md5dll::GetMD5File "$homedir\${ENDIR}\${IDFILE}"
		Pop $4
		; MessageBox MB_OK "$3||$4"
		${If} $3 != $4
			${EnumProcessPaths} "PslFind" $PslFindOutput
			${GetProcessPath} "${APPEXE}" $0
			; MessageBox MB_OK "$0"
			${If} $0 != "$homedir\${APPEXE}"
				ExecWait "$homedir\${ENDIR}\${LANGUAGEFILES}"
				ExecWait "$homedir\${ENDIR}\${USERLANGUAGEFILES}"
			${Else}
				/* MessageBox MB_YESNO "$(Message2)" IDYES WaitAndRun2 IDNO 0
				Abort
				WaitAndRun2:
				${ProcessWaitClose} "${APPEXE}" "-1" $2
				${ProcessWaitClose} "$PslSpoonFileName" "-1" $2
				ExecWait "$homedir\${ENDIR}\${LANGUAGEFILES}"
				ExecWait "$homedir\${ENDIR}\${USERLANGUAGEFILES}" */
				MessageBox MB_OK "$(Message2)"
				Abort
			${EndIf}

		${EndIf}

	${EndIf}

	${GetParameters} $0
	${If} $0 == ""
		; Exec "$homedir\${APPEXE}"
		; ExecDos::exec /ASYNC /TOSTACK '"$homedir\${APPEXE}"' '' ''
		${Execute} "$homedir\${APPEXE}" "" $1
		; MessageBox MB_OK "$1"
	${Else}
		; Exec '"$homedir\${APPEXE}" "$0"'
		; ExecDos::exec /ASYNC /TOSTACK '"$homedir\${APPEXE}" "$0"' '' ''
		${Execute} '"$homedir\${APPEXE}" "$0"' '' $1
		; MessageBox MB_OK "$1"
	${EndIf}

SectionEnd

Function "PslFind"
	; Pop $var1			; matching path string
	; Pop $var2			; matching process PID
	; ...user commands
	; Push [1/0]		; must return 1 on the stack to continue
	; 					; must return some value or corrupt the stack
	; 					; DO NOT save data in $0-$9
	Pop $PslFindPath
	Pop $PslFindPid
	; MessageBox MB_OK "$PslFindPath; $PslFindPid"
	${If} $PslFindPath == "$homedir\${APPEXE}"
		/* MessageBox MB_YESNO "$(Message1)" IDYES PslFindYes1 IDNO 0
		Abort
		PslFindYes1:
		MessageBox MB_OK "$PslFindPid; $PslSpoonFileName"
		${TerminateProcess} "$PslFindPid" $R1
		${ProcessWaitClose} "$PslSpoonFileName" "10000" $R1 */
		Push 0
		Abort "$(Message1)"
	${EndIf}
	Push 1
FunctionEnd

Function "PathParse"
	Exch $0
	Push $1
	ExpandEnvStrings $0 "$0"
	${GetRoot} "$0" $1
	${if} $1 == ""
		StrCpy $1 "$BaseDir" "" -1
		${If} $1 == "\"
			StrCpy $0 "$BaseDir$0"
		${Else}
			StrCpy $0 "$BaseDir\$0"
		${EndIf}
	${EndIf}
	GetFullPathName $0 "$0"
	Pop $1
	Exch $0
FunctionEnd

Function "AppPatch"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)

	; $R0-$R5  are not used (save data in them).
	; ...

	; If $var="StopLocate" Then exit from function
	${If} $R6 != ""
		Push $0
		Push $1
		StrLen $0 "${APPDIR}\${APPPATCH}"
		StrCpy $1 "$R9" "" "$0"
		; MessageBox MB_OK "$1"
		Rename "${APPDIR}$1" "${APPDIR}$1.bak"
		StrCpy $1 "$R8" "" "$0"
		ClearErrors
		CopyFiles /SILENT "$R9" "${APPDIR}$1"
		IfErrors +2 0
		Delete "$R9"
		Pop $1
		Pop $0
	${Else}
		Push $0
		${DirState} "$R9" $0
		${If} $0 == 0
			RMDir "$R9"
		${EndIf}
		Pop $0
	${EndIf}
	Push "continue"
FunctionEnd