; **************************************************************************
; === Define constants ===
; **************************************************************************
!define EXEFULLDIR "d:\SnapShot\ThinAppPortable\Captures\SDL_Trados_Studio_2021_16.0.2.3343\%ProgramFilesDir%\SDL\SDL Trados Studio\Studio16"
!define EXENAME "SDLTradosStudio.exe"
!define USERDIR "d:\Downloads\sdl2021"

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
	; !define /date VER "%Y.%m.%d.0"
	!define VER "16.0.0.0"
!endif

!execute '"ProductInfo.exe" "${EXEFULLDIR}\${EXENAME}"'
!searchparse /noerrors /file "ProductInfo.ini" "Comments={" COMMENTS "}, CompanyName={" COMPANYNAME "}\
, FileDescription={" FILEDESCRIPTION "}, FileVersion={" FILEVERSION "}, LegalCopyright={" LEGALCOPYRIGHT "},"
!searchparse /noerrors /file "ProductInfo.ini" "LegalTrademarks={" LEGALTRADEMARKS "}\
, OriginalFileName={" ORIGINALFILENAME "}, PrivateBuild={" PRIVATEBUILD "}, "
!searchparse /noerrors /file "ProductInfo.ini" "ProductName={" PRODUCTNAME "}, ProductVersion={" PRODUCTVERSION "}\
, SpecialBuild={" SPECIALBUILD "},"

!define APPNAME "SDLTradosStudio"				; complete name of program
!define APP "SDLTradosStudio"					; short name of program without space and accent  this one is used for the final executable an in the directory structure
!define APPEXE "SDLTradosStudio.exe"				; main exe name
!define APPEXE64 "SDLTradosStudio.exe"				; main exe 64 bit name
!define APPDIR "$EXEDIR"				; main exe relative path
!define APPSWITCH 	``
!define LANGUAGEROOT "HKLM"
!define LANGUAGESUB "SOFTWARE\Classes\MIME\Database\Rfc1766"
!define SDLREGROOT "HKCU"
!define SDLREGSUB "Software\Trados\Shared\UI Language"
!define SDLREGNAME "Language"
!define ADDINDIR "SDL plugin installer"
!define LOADER "Loader_SDL Trados Studio 2021_x32-64.exe"
!define LAUNCHERCFG "${APP}launcher.ini"
!define APPPATCH "Patch"
!define USERVER "16.x.x.x"

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

Var SdlFindOutput
Var SdlFindPath
Var SdlFindPid
Var languagestring
Var languagevalue
; var reghandle
; var uilanguage

LangString Message1 1033 "${APPEXE} is running. Path $SdlFindPath. $\r$\n\
							Please close the program, then run again. "
LangString Message1 2052 "${APPEXE} 正在运行。路径 $SdlFindPath。$\r$\n\
							请退出正在运行的程序后，再次运行。"
LangString Message2 1033 "${APPEXE} is running. Some files need to be copied. $\r$\n\
							Please close the program, then run again. "
LangString Message2 2052 "${APPEXE} 正在运行。需要拷贝文件。$\r$\n\
							请退出正在运行的程序后，再次运行。"


; **************************************************************************
; ==== Running ====
; **************************************************************************

Section "Main"

/* 	${registry::Open} "${SDLREGROOT}\${SDLREGSUB}" "/T=REG_SZ /N=on" $reghandle
	${Do}
		${registry::Find} "$reghandle" $1 $2 $3 $4

    ; $var1        "[path]"
    ; $var2        "[value]" or "[key]"
    ; $var3        "[string]"
    ; $var4        "[TYPE]"

		MessageBox MB_OK "$1$\r$\n$2$\r$\n$3$\r$\n$4"
		${If} $3 == "on"
			StrCpy $languagestring $2
			StrCpy $languagevalue $3
			MessageBox MB_OK "$1$\r$\n$2$\r$\n$3$\r$\n$4"
			${ExitDo}
		${EndIf}
	${LoopWhile} $4 != ""
	${registry::Close} "$reghandle" */

	StrCpy $0 0
	${Do}
		ClearErrors
		EnumRegValue $1 ${SDLREGROOT} "${SDLREGSUB}" $0
		ReadRegStr $2 ${SDLREGROOT} "${SDLREGSUB}" $1
		; MessageBox MB_OK "$0$\r$\n$1$\r$\n$2$\r$\n$3"
		${If} $2 == "on"
			StrCpy $languagevalue $1
			StrCpy $languagestring $2
			${ExitDo}
		${EndIf}
		IntOp $0 $0 + 1
	${LoopUntil}  ${Errors}

	${If} $languagevalue == ""
		StrCpy $languagevalue $LANGUAGE
	${EndIf}
	; MessageBox MB_OK "$languagevalue"
/* 
	IntFmt $0 "0x%04x" "$languagevalue"
	System::Call "kernel32::LCIDToLocaleName(i r0, t .r1, i 0, l 0) i .r2"
	System::Call "kernel32::LCIDToLocaleName(i r0, t .r1, i r2, l 0) i .r2"
	MessageBox MB_OK "$0, $1, $2"
	${If} $2 == 0
		IntFmt $0 "%04x" "$languagevalue"
		ReadRegStr $1 ${LANGUAGEROOT} "${LANGUAGESUB}" "$0"
		${WordFind} "$1" ";" "+1" $1
		; MessageBox MB_OK "$languagevalue, $0, $1"
	${EndIf}
	StrCpy $uilanguage $1
 */
	${EnumProcessPaths} "SdlFind" $SdlFindOutput

	${If} $SdlFindPath != "${APPDIR}\${APPEXE}"
		SetOverwrite ifdiff
		SetOutPath "${APPDIR}"
		File /nonfatal /r "${USERDIR}\*.dll"
	${Else}
		MessageBox MB_OK "$(Message2)"
		Abort
	${EndIf}

	${Select} $languagevalue
	${Case} 2052
		SetOverwrite ifdiff
		SetOutPath "${APPDIR}\..\..\${ADDINDIR}"
		File "/oname=Sdl.Community.SdlPluginInstaller.exe" "${EXEFULLDIR}\..\..\${ADDINDIR}\Sdl.Community.SdlPluginInstaller.zh-CN.exechs"
	${CaseElse}
		SetOverwrite ifdiff
		SetOutPath "${APPDIR}\..\..\${ADDINDIR}"
		File "/oname=Sdl.Community.SdlPluginInstaller.exe" "${EXEFULLDIR}\..\..\${ADDINDIR}\Sdl.Community.SdlPluginInstaller.exe"
	${EndSelect}

	${GetParameters} $0
    ${Select} $0
    ${Case} "/loader"
        ${If} $SdlFindPath != "${APPDIR}\${APPEXE}"
            SetOverwrite ifdiff
            SetOutPath "${APPDIR}"
            File /nonfatal /r "${USERDIR}\backup\*.*"
            Exec "${APPDIR}\${LOADER}"
        ${Else}
            Abort "$(message2)"
        ${EndIf}
    ${Case} ""
        ${If} $SdlFindPath != "${APPDIR}\${APPEXE}"
            SetOverwrite ifdiff
            SetOutPath "${APPDIR}"
            File /nonfatal /r "${USERDIR}\patch\*.dll"
            Exec "${APPDIR}\${APPEXE}"
        ${Else}
            Abort "$(message2)"
        ${EndIf}
    ${CaseElse}
        ${If} $SdlFindPath != "${APPDIR}\${APPEXE}"
			${WordFind} "$0" " " "#" $1
			${If} $1 > 1
				${WordFind} "$0" " " "+1" $1
				${WordFind} "$0" " " "+2*" $2
				${Select} $1
				${Case} "/loader"
					SetOverwrite ifdiff
            		SetOutPath "${APPDIR}"
          			File /nonfatal /r "${USERDIR}\backup\*.*"
            		Exec '"${APPDIR}\${LOADER}" $2'
				${CaseElse}
					SetOverwrite ifdiff
					SetOutPath "${APPDIR}"
					File /nonfatal /r "${USERDIR}\patch\*.dll"
					Exec '"${APPDIR}\${APPEXE}" $0'
				${EndSelect}
			${Else}
				SetOverwrite ifdiff
				SetOutPath "${APPDIR}"
				File /nonfatal /r "${USERDIR}\patch\*.dll"
				Exec '"${APPDIR}\${APPEXE}" $0'
			${EndIf}
        ${Else}
            Abort "$(message2)"
        ${EndIf}
    ${EndSelect}

SectionEnd

Function "SdlFind"
	; Pop $var1			; matching path string
	; Pop $var2			; matching process PID
	; ...user commands
	; Push [1/0]		; must return 1 on the stack to continue
	; 					; must return some value or corrupt the stack
	; 					; DO NOT save data in $0-$9
	Pop $SdlFindPath
	Pop $SdlFindPid
	; MessageBox MB_OK "$SdlFindPath; $SdlFindPid"
	${If} $SdlFindPath == "${APPDIR}\${APPEXE}"
		Push 0
    ${Else}
	    Push 1
	${EndIf}
FunctionEnd

