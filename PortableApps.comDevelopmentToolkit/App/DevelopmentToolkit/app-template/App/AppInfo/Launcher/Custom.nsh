/* $LauncherFile=z:\PortableAppz\ReplaceStudioPortable\App\AppInfo\Launcher\ReplaceStudioPortable.ini
$EXEFILE=ReplaceStudioPortable.exe
$AppID=ReplaceStudioPortable
$BaseName=ReplaceStudioPortable
$EXEDIR=z:\PortableAppz\ReplaceStudioPortable */


${SegmentFile}

${SegmentInit}

	${SetEnvironmentVariable} PORTABLEBASEDIR $EXEDIR
	${SetEnvironmentVariable} PORTABLEBASENAME $BaseName
	SetShellVarContext all
	${SetEnvironmentVariable} ALLUSERDOCUMENTS $DOCUMENTS
	
	IfFileExists "$EXEDIR\App\DefaultData" 0 +3
	IfFileExists "$EXEDIR\Data" +2 0
	CopyFiles "$EXEDIR\App\DefaultData\*.*" "$EXEDIR\Data\*.*"
	
	${LineSum} "$EXEDIR\$BaseName.ini" $0
	${IfNot} ${FileExists} "$EXEDIR\$BaseName.ini"
	${OrIfNot} $0 = 8
		; IfFileExists "$EXEDIR\$BaseName.ini" +8 0
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" UserName ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" AdditionalParameters ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" DisableSplashScreen "true"
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" RunLocally "false"
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" SingleAppInstance ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" SinglePortableAppInstance ""
		WriteINIStr "$EXEDIR\$BaseName.ini" "$BaseName" AlwaysUse32Bit ""
	${EndIf}

	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" AlwaysUse32Bit
	${If} $0 == true
		StrCpy $Bits 32
	${EndIf}
	
	${If} $Bits == 64
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable64
		${If} $0 != ""
		${AndIf} ${FileExists} "$EXEDIR\App\$0"
			${GetParent} "$EXEDIR\App\$0" $1
			${SetEnvironmentVariable} ProgramDir $1
			SetRegView 64
		${Else}
			ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable
			${GetParent} "$EXEDIR\App\$0" $1
			${SetEnvironmentVariable} ProgramDir $1
		${EndIf}
	${EndIf}
	${If} $Bits == 32
		ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch ProgramExecutable	
		${GetParent} "$EXEDIR\App\$0" $1
		${SetEnvironmentVariable} ProgramDir $1
	${EndIf}
	
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" UserName
	${IfNot} ${Errors}
	${AndIf} $0 != ""
		${SetEnvironmentVariable} ProfileUserName $0
	${EndIf}

	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" SingleAppInstance
	${If} $0 == false
		WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch SingleAppInstance $0
	${EndIf}
	ReadINIStr $0 "$EXEDIR\$BaseName.ini" "$BaseName" SinglePortableAppInstance
	${If} $0 == false
		WriteINIStr "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch SinglePortableAppInstance $0
	${EndIf}
	
!macroend

${SegmentPreExec}

	ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\$BaseName.ini" Launch WorkingDirectory
	${IfNot} ${Errors}
	${AndIf} $0 != ""
		${ParseLocations} $0
		IfFileExists $0 +2 0
		CreateDirectory $0
	${EndIf}	

	${ReadLauncherConfig} $0 Environment HOME
	${IfNot} ${Errors}
	${AndIf} $0 != ""
		${ParseLocations} $0
		IfFileExists $0 +2 0
		CreateDirectory $0
	${EndIf}
	
!macroend