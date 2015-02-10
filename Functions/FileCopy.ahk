;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Description
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
; Copies a file from CLI argument 1 to CLI arg 2. 
;This exists so that we can copy the file needed without hanging up the main program from long copy times.
;

;~~~~~~~~~~~~~~~~~~~~~
;Compile Options
;~~~~~~~~~~~~~~~~~~~~~
StartUp()
Version_Name = v1.0
The_ProjectName = BackGround_FileCopier

;Dependencies
;None

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
;MAIN PROGRAM STARTS HERE
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

;Command Line Argument 2 can be a path to a settings file. Otherwise check ScriptDir
CLI_Arg1 = %1%
CLI_Arg2 = %2%
	If (CLI_Arg1 != ""||CLI_Arg2 != "") {
	Path_SourceFile = %CLI_Arg1%
	Path_Destfile = %CLI_Arg2%
	} Else {
	ExitApp, 100
	}
	
;Check if supplied arg exists. Quit if not found
	IfExist, %CLI_Arg1%
	{
	
	} Else {
	ExitApp, 101
	}

;Do the Actual File Copy
FileCopy, %CLI_Arg1%, %CLI_Arg2%, 1
ExitApp, 1

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; FUNCTIONS
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

StartUp()
{
#NoEnv
#NoTrayIcon
#SingleInstance force
;#MaxThreads 10
}