;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Description
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
; Checks each platform for willpay and probable data. Hopefully it can eventually illuminate other problems at tote
;

;~~~~~~~~~~~~~~~~~~~~~
;Compile Options
;~~~~~~~~~~~~~~~~~~~~~
SetBatchLines -1 ;Go as fast as CPU will allow
StartUp()
The_ProjectName = SGR Overview
The_VersionName = v0.3.6

;Dependencies
#Include %A_ScriptDir%\Functions
#Include sort_arrays
#Include json_obj
;#Include LVA (Listed under Functions)

;For Debug Only
#Include util_arrays
#Include util_misc

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
;PREP AND STARTUP
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
Sb_RemoteShutDown() ;Allows for remote shutdown
;###Invoke and set Global Variables
StartInternalGlobals()
RecalculateToday = 1

;~~~~~~~~~~~~~~~~~~~~~
;GUI
;~~~~~~~~~~~~~~~~~~~~~
BuildGUI()
LVA_ListViewAdd("GUI_Listview")
;Return


;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
;MAIN PROGRAM STARTS HERE
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

;User pressed Update Button or automatic Timer has expired
UpdateButton:
;DiableAllButtons()

;clear some vars
The_UnknownmessageCounter := 0
;Fn_GUI_UpdateProgress(0)


;Start watching new date at 1:00 AM
Sb_DailyRestart("01") 
;Get today's date and convert into separate vars
	If (RecalculateToday = 1) {
	The_Day := A_DD
	The_Month := A_MM
	The_Year := A_YYYY
	RecalculateToday = 0
	}

;Get user selected or default SGR location and convert into full path to file
Gui, Submit, NoHide
The_SystemName := Fn_QuickRegEx(SGR_Choice,"   (\w+)")
	If (The_SystemName = "" || The_SystemName = "null") {
	Msgbox, There was a problem reading the system name, please check SGR_Locations.txt and try again.
	Return
	}

;Grab delay time for current selected datafeed
Loop, % SGRDatafeeds_Array.MaxIndex()
{
	If (SGRDatafeeds_Array[A_Index,"SystemName"] = The_SystemName) {
	MTPDelay := SGRDatafeeds_Array[A_Index,"Delay"]
	}
}

;Clear both Objects and re-import any existing data for today (so we don't forget about tracks
Txt_Array := []
AllTracks_Array := Fn_ImportDBData(AllTracks_Array,"MainDB")
IgnoredTracks := Fn_ImportDBData(AllTracks_Array,"IgnoredDB")

;Special variable numbers for progressbar
;WM_USER               := 0x00000400
;PBM_SETMARQUEE        := WM_USER + 10
;PBM_SETSTATE          := WM_USER + 16
;PBS_MARQUEE           := 0x00000008
;PBS_SMOOTH            := 0x00000001
;PBS_VERTICAL          := 0x00000004
;PBST_NORMAL           := 0x00000001
;PBST_ERROR            := 0x00000002
;PBST_PAUSE            := 0x00000003
;STAP_ALLOW_NONCLIENT  := 0x00000001
;STAP_ALLOW_CONTROLS   := 0x00000002
;STAP_ALLOW_WEBCONTENT := 0x00000004
;WM_THEMECHANGED       := 0x0000031A
;Apply special effects to the progressbar for temporary marquee effect
;GuiControl, +%PBS_MARQUEE%, UpdateProgress
;DllCall("User32.dll\SendMessage", "Ptr", MARQ1, "Int", PBM_SETMARQUEE, "Ptr", 1, "Ptr", 50)



SGR_Location = \\%The_SystemName%\tvg\LogFiles\%The_Month%-%The_Day%-%The_Year%\SGRData%The_Month%-%The_Day%-%The_Year%.txt
;Clear temp folder and copy selected SGR datafile from production to temp location
;FilePath_SGRDir = %A_ScriptDir%\Data\Temp\%The_SystemName%


;Read the last 2000 lines from the SGR file. Returns an array object with each line as an element
Txt_Array := Fn_FileTail(SGR_Location, 2000) 

	If (Txt_Array.MaxIndex() <= 100){
	FileAppend, `n`r%A_Now% - Empty Text Array, %A_ScriptDir%\ErrorLog.txt
	Return
	}
	
	
;Remove special options from progressbar and go back to normal
Fn_GUI_UpdateProgress(0)
GuiControl, -hwndMARQ1 -%PBS_MARQUEE%, UpdateProgress


	;Read Each line of the new Txt_Array for relevant messages, pull trackname and trackcode out
	Loop, % Txt_Array.MaxIndex() 
	{
	Fn_GUI_UpdateProgress(A_Index, Txt_Array.MaxIndex())
	MessageLength :=
	TrackCode := 
	TrackName := 
	TimeStamp := 
	MessageType := 
	NextPost := 
	CurrentRace :=
	OfficialRace :=	
	ProbableType :=
	TrackOfficial := 
	TotalRaces := 
	;Faster to read from var than object? Unlikely; what is this comment about?
	FULL_MESSAGE := Txt_Array[A_Index]
		If (StrLen(FULL_MESSAGE) <= 3) {
		FileAppend, `n`r%A_Now% - Very short Message: %FULL_MESSAGE%, %A_ScriptDir%\ErrorLog.txt
		}
		
	
	;Legacy RegEx: "message=...........[A-Z]{2}([a-zA-Z 0-7_]+[a-zA-Z_]([0-9]|\W[0-9]|\W))\W+00\d+([A-Z]|[A-Z0-9]){3}"
	TrackCode := Fn_QuickRegEx(FULL_MESSAGE,"\W{2}00...(\w{3})")
		If (TrackCode != "") {
		REG := "[A-Z]{2}\d+[A-Z]{2}(.*\b)\W+\d+" . TrackCode
		TrackName := Fn_QuickRegEx(FULL_MESSAGE,REG)
		TimeStamp := Fn_QuickRegEx(FULL_MESSAGE,"timestamp=.\d{2}\/\d{2}\/\d{4}\W(\d{2}:\d{2})")
		MessageType := Fn_QuickRegEx(FULL_MESSAGE,"message=...........([A-Z]{2})")
		} Else {
		The_UnknownmessageCounter++
		Continue
		}

		; RI - RACE INFORMATION MESSAGE TYPE ##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##
		If (MessageType = "RI") {
		;Get Next Post time
		NextPost := Fn_QuickRegEx(FULL_MESSAGE,"(\d{4})\d{2}TRACK")
		
		;Get Current Race as shown by RI message
		REG := TrackCode . "\d\w+\W+(\d{2})"
		CurrentRace := Fn_QuickRegEx(FULL_MESSAGE,REG)
			;Is this track official?
			If (InStr(FULL_MESSAGE,"OFFICIAL") && TrackCode != "null") {
			TrackOfficial := 1
				;Which race is official exactly?
				REG := TrackCode . "\d+\w*\W+(\d{2})"
				OfficialRace := Fn_QuickRegEx(FULL_MESSAGE,REG)
			} Else {
			TrackOfficial := 0
			}
		}
		
		;PB - FEATURED PROBABLES MESSAGE TYPE ##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##
		If (MessageType = "PB") {
		REG := TrackCode . "\d+(\s+|\w+)\s\d+(\w+)"
		ProbableType := Fn_QuickRegEx(FULL_MESSAGE,REG,2)
		REG := TrackCode . "\d+\w+\s\d+\w+\s\d{2}"
		ProbableRace := Fn_QuickRegEx(FULL_MESSAGE,REG)
		}
		
		;RN - SCRATCHED RUNNERS MESSAGE TYPE ##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##
		If (MessageType = "RN") {
		TotalRaces := Fn_QuickRegEx(FULL_MESSAGE,"\W+00\d+(([A-Z]|[A-Z0-9]){3})\w+\W+\d{6}(\d{2})",3)
		}
		
		
		
		
		
		
		
		
		
		
		;Determine if this track exists already in AllTracks_Array and select it with Track_Index
;- FIXED - This HAD a weakness that it will not record timestamps until the 2nd message is seen because the track doesn't exist in the array until the 2nd pass.
		If (Track != "null" && TimeStamp != "null" && MessageType != "null") {
		TrackFound_Bool := False
			Loop, % AllTracks_Array.MaxIndex() {
				;If (AllTracks_Array[A_Index,"TrackName"] = Track) {
				If (AllTracks_Array[A_Index,"TrackCode"] = TrackCode) {
				Track_Index := A_Index
				TrackFound_Bool = True
				}
			}
			If (TrackFound_Bool = False && TrackCode != "") {
			Track_Index := AllTracks_Array.MaxIndex()
			Track_Index++
			AllTracks_Array[Track_Index,"TrackCode"] := TrackCode
			}
			
			
			
			;Ok insert data to correct track; New track is done being added/Existing track is selected
			AllTracks_Array[Track_Index,MessageType] := TimeStamp ;Note this is sending timestamp to MessageType not "MessageType"; its an element deeper in the array
			AllTracks_Array[Track_Index,"TimeStamp"] := TimeStamp
			AllTracks_Array[Track_Index,"TrackCode"] := TrackCode
			AllTracks_Array[Track_Index,"TrackName"] := TrackName
				
				; PB - ##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##
				If (MessageType = "PB") {
					;Don't rember
					If (AllTracks_Array[Track_Index,"CurrentRace"] != AllTracks_Array[Track_Index,"ProbableRace"]) {
					AllTracks_Array[Track_Index,"ProbableType"] := ""
					}
					;Nope
					If (MessageType = "PB" && ProbableType != "null") {
					AllTracks_Array[Track_Index,"ProbableType"] := AllTracks_Array[Track_Index,"ProbableType"] . A_Space . ProbableType
					AllTracks_Array[Track_Index,"ProbableRace"] := ProbableRace
					}
					;If the message includes a 99/1 odds for 3 different runners. WEAK
					If (InStr(FULL_MESSAGE,"000099999800009999980000999998")) {
					AllTracks_Array[Track_Index,"PB_99"] := 1
					} Else {
					AllTracks_Array[Track_Index,"PB_99"] := 0
					}
				}
				
				;RI - ##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##
				If (MessageType = "RI") {
					;save the current official flagged race
					If (OfficialRace != "null") {
					AllTracks_Array[Track_Index,"OfficialRace"] := OfficialRace
					}
					;save the CurrentRace
					If (NextPost != "null") {
					AllTracks_Array[Track_Index,"NextPost"] := NextPost
					AllTracks_Array[Track_Index,"CurrentRace"] := CurrentRace
						If (TrackOfficial = 1) {
						AllTracks_Array[Track_Index,"TrackOfficial"] := 1
						}
					}
				}
				
				;RN - ##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##=##
				If (MessageType = "RN") {
					If (TotalRaces != "null" && TotalRaces != "") {
					AllTracks_Array[Track_Index,"TotalRaces"] := TotalRaces
					}
				}
				
		} Else {
		The_UnknownmessageCounter++
		Continue
		}
	}
	Txt_Array := []
;Msgbox, % The_UnknownmessageCounter


;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Start Moving all Track checks and logic here
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
Loop, % AllTracks_Array.MaxIndex() {
	
	; "Score" is used to track how health each track's data is. The score will go negative if there are problems; and positive if it is healthy/finished racing/ignorable
	;All Tracks start with a score of 1
	AllTracks_Array[A_Index,"Score"] := 1
	AllTracks_Array[A_Index,"Comment"] := ""
	AllTracks_Array[A_Index,"Color"] := ""
	AllTracks_Array[A_Index,"Ignored"] := False
	
	;Remove any tracks with no TrackCode. This should always be impossible if our data import is very strong
	If (AllTracks_Array[A_Index,"TrackCode"] = "") {
	Continue
	AllTracks_Array.Remove(A_Index)
	}
	
	;Track is getting close to post time with no probable data?
	MTP := 
	MTP := Fn_QuickRegEx(AllTracks_Array[A_Index,"NextPost"],"(\d{2})") . ":" . Fn_QuickRegEx(AllTracks_Array[A_Index,"NextPost"],"(\d{2})$")
	MTP := Fn_IsTimeClose(MTP,1,"m")
	MTP := MTP - MTPDelay
	AllTracks_Array[A_Index,"MTP"] := MTP
	
	;If (AllTracks_Array[A_Index,"ProbableType"] = "" && MTP < 30) {
	;AllTracks_Array[A_Index,"Color"] := "Orange"
	;AllTracks_Array[A_Index,"Comment"] := "No Probable data for upcoming current race"
	;}
	
	RI := Fn_IsTimeClose(AllTracks_Array[A_Index,"RI"])
	PB := Fn_IsTimeClose(AllTracks_Array[A_Index,"PB"])
	RN := Fn_IsTimeClose(AllTracks_Array[A_Index,"RN"])
	PS := Fn_IsTimeClose(AllTracks_Array[A_Index,"PS"])
	PT := Fn_IsTimeClose(AllTracks_Array[A_Index,"PT"])
	SP := Fn_IsTimeClose(AllTracks_Array[A_Index,"SP"])
	WO := Fn_IsTimeClose(AllTracks_Array[A_Index,"WO"])
	WR := Fn_IsTimeClose(AllTracks_Array[A_Index,"WR"])
	WP := Fn_IsTimeClose(AllTracks_Array[A_Index,"WP"])
	;Msgbox, % MTP
		If (PB > 300 && MTP < 30 || PB = "") {
		AllTracks_Array[A_Index,"Score"] += -100
		AllTracks_Array[A_Index,"Comment"] := "PB MISSING - Feature Probables Messages"
		}
		If (RN > 300 && MTP < 30 || RN = "") {
		AllTracks_Array[A_Index,"Score"] += -100
		AllTracks_Array[A_Index,"Comment"] := "RN MISSING - Scratched Runner Messages"
		}
		If (PS > 300 && MTP < 30 || PS = "") {
		AllTracks_Array[A_Index,"Score"] += -100
		AllTracks_Array[A_Index,"Comment"] := "PS MISSING - Scratched Pools Messages"
		}
		If (PT > 300 && MTP < 30 || PT = "") {
		AllTracks_Array[A_Index,"Score"] += -100
		AllTracks_Array[A_Index,"Comment"] := "PT MISSING - Pool Totals Messages"
		}
		If (SP > 300 && MTP < 30 || SP = "") {
		AllTracks_Array[A_Index,"Score"] := -100
		AllTracks_Array[A_Index,"Comment"] := "SP MISSING - WPS Probables Messages"
		}
		If (WO > 300 && MTP < 30 || WO = "") {
		AllTracks_Array[A_Index,"Score"] += -100
		AllTracks_Array[A_Index,"Comment"] := "WO MISSING - Win Odds Messages"
		}
		If (WR > 300 && MTP < 30 || WR = "") {
		AllTracks_Array[A_Index,"Score"] += -100
		AllTracks_Array[A_Index,"Comment"] := "WR MISSING - WPS Totals Messages"
		}
		If (AllTracks_Array[A_Index,"ProbableType"] = " " && MTP < 10) ;This needs to be improved
		{
		AllTracks_Array[A_Index,"Score"] += -100
		AllTracks_Array[A_Index,"Comment"] := "NextRace Probables late"
		}
		If (RI > 300 || RI = "") {
		AllTracks_Array[A_Index,"Score"] += -1000
		AllTracks_Array[A_Index,"Comment"] := "RI MISSING Race Information Messages"
		}
		;Willpays not required
		;If (WP = "") {
		;AllTracks_Array[A_Index,"Score"] := -100
		;AllTracks_Array[A_Index,"Comment"] := "MISSING WillPay Messages"
		;}
	
		;Is the track super late?
		If (MTP < -20) {
		;AllTracks_Array[A_Index,"Score"] += -100
		AllTracks_Array[A_Index,"Comment"] := "late"
		}
		If (MTP < -30) {
		AllTracks_Array[A_Index,"Comment"] := "LATE!"
		}
		If (MTP < -40) {
		AllTracks_Array[A_Index,"Comment"] := "LATE!"
		AllTracks_Array[A_Index,"Score"] += -100
		}
		If (MTP < -50) {
		AllTracks_Array[A_Index,"Comment"] := "LATE!"
		AllTracks_Array[A_Index,"Score"] += -1000
		}
		
	
	;TRACK COMPLETED?
	If (AllTracks_Array[A_Index,"TotalRaces"] = AllTracks_Array[A_Index,"OfficialRace"] && AllTracks_Array[A_Index,"TotalRaces"] != "") {
	AllTracks_Array[A_Index,"Completed"] := True
	} Else {
	AllTracks_Array[A_Index,"Completed"] := False
	}
	
	
	
	;Track Ignored!?
	X := A_Index
	Loop, % IgnoredTracks.MaxIndex() {
		If (IgnoredTracks[A_Index] = AllTracks_Array[X,"TrackCode"]) {
		AllTracks_Array[X,"Ignored"] := True
		}
	}
}


;Determine color by score
Loop, % AllTracks_Array.MaxIndex() {

	;Color Bad Scores
	If (AllTracks_Array[A_Index,"Score"] > -9999999) {
	AllTracks_Array[A_Index,"Color"] := "Red"
	}
	If (AllTracks_Array[A_Index,"Score"] > -200) {
	AllTracks_Array[A_Index,"Color"] := "Orange"
	}
	If (AllTracks_Array[A_Index,"Score"] > -100) {
	AllTracks_Array[A_Index,"Color"] := "Yellow"
	}
	
	
	;Color Completed Tracks
	If (AllTracks_Array[A_Index,"Completed"] = True) {
	AllTracks_Array[A_Index,"Color"] := "Grey"
	AllTracks_Array[A_Index,"Score"] := 1000
	Continue
	}
	
	
	;Color Ignored Tracks
	If (AllTracks_Array[A_Index,"Ignored"] = True) {
	AllTracks_Array[A_Index,"Color"] := "DarkGrey"
	AllTracks_Array[A_Index,"Score"] := 999
	Continue
	}
	
	
	;Color Good Tracks
	If (AllTracks_Array[A_Index,"Score"] = 1) {
	AllTracks_Array[A_Index,"Color"] := "None"
	}
	If (AllTracks_Array[A_Index,"Score"] > 1) {
	AllTracks_Array[A_Index,"Color"] := "None"
	}
}

;Sort Array so that newest tracks are at the top and completed are at the bottom
Fn_Sort2DArray(AllTracks_Array, "NextPost")
Fn_Sort2DArray(AllTracks_Array, "Score")


;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Write All Data Out to GUI
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
;Clear out the listview for new data to appear in GUI
LVA_EraseAllCells("GUI_Listview")
LV_Delete()
LVA_Refresh("GUI_Listview")

Loop, % AllTracks_Array.MaxIndex() {

	WP := ""
	PB := ""
	
	
	If (AllTracks_Array[A_Index,"ProbableType"] != "null" && AllTracks_Array[A_Index,"PB_99"] != 1)
	{
	PB := AllTracks_Array[A_Index,"ProbableType"]
	}
	If (AllTracks_Array[A_Index,"WP"] != "")
	{
	WP = ✓
	}

;###############Shouldn't this all be happening up in the logic area? Move when time permits###############
;Also work with oldest possible message. Think about it; might not have all types of messages all the time


;Convert last timestamp to easy to work with age of last message
TimeDifference := Fn_IsTimeClose(AllTracks_Array[A_Index,"TimeStamp"],0,"s")
TimeString := " sec"
	;If the last message was more than 60 seconds ago. Must be at least a min old
	If (TimeDifference >= 60 || TimeDifference = "ERROR") {
	TimeDifference := Fn_IsTimeClose(AllTracks_Array[A_Index,"TimeStamp"],0,"m")
	TimeString := " min"
		;If the track hasn't got a new message in 3 mins! LATE!!!!
		If (TimeDifference > 3) {
		;LVA_SetCell("GUI_Listview", A_Index, 5, "ffbe03")
		}
		If (TimeDifference > 5) {
		;LVA_SetCell("GUI_Listview", A_Index, 5, "Red")
		}
		If (TimeDifference >= 60) {
		TimeDifference := Fn_IsTimeClose(AllTracks_Array[A_Index,"TimeStamp"],0,"h")
		TimeString := " hour"
		}
	}
TimeDifference := TimeDifference . TimeString


;;Color Tracks that are missing messages
	If (AllTracks_Array[A_Index,"Color"] = "Red") {
	LVA_SetCell("GUI_Listview", A_Index, 0, "9551ff") ;Previously Red "Red"
	}
	If (AllTracks_Array[A_Index,"Color"] = "Orange") {
	LVA_SetCell("GUI_Listview", A_Index, 0, "5153ff") ;Previously Orange "FF6600"
	}
	If (AllTracks_Array[A_Index,"Color"] = "Yellow") {
	LVA_SetCell("GUI_Listview", A_Index, 0, "5182ff") ;Previously Yellow "FFCC00"
	}
	If (AllTracks_Array[A_Index,"Color"] = "None") {
	LVA_SetCell("GUI_Listview", A_Index, 0, "FFFFFF")
	}
	If (AllTracks_Array[A_Index,"Color"] = "Grey") {
	LVA_SetCell("GUI_Listview", A_Index, 0, "cccccc")
	}
	If (AllTracks_Array[A_Index,"Color"] = "DarkGrey") {
	LVA_SetCell("GUI_Listview", A_Index, 0, "8e8e8e")
	}
	
;;Color late tracks MTP cell
	If (AllTracks_Array[A_Index,"Comment"] = "late") {
	LVA_SetCell("GUI_Listview", A_Index, 3, "FFCC00") ;Yellow
	}
	If (AllTracks_Array[A_Index,"Comment"] = "LATE!") {
	LVA_SetCell("GUI_Listview", A_Index, 3, "FF6600") ;Orange
	}
	
MTP := AllTracks_Array[A_Index,"MTP"]

	;If (AllTracks_Array[A_Index,"Completed"] = False)
	If (1) {
	;Note some fields have extra A_Space or "   " appended to help with LV_ModifyCol() later. modifying each column is resource intensive for overloaded wallboard monitors
	LV_Add("",AllTracks_Array[A_Index,"TrackName"],AllTracks_Array[A_Index,"TrackCode"] . " ",AllTracks_Array[A_Index,"MTP"] . " ",AllTracks_Array[A_Index,"CurrentRace"] . "/" . AllTracks_Array[A_Index,"TotalRaces"],TimeDifference . "   ",PB . "   ",WP . "   ",AllTracks_Array[A_Index,"Comment"])
	}
	
	If(TimeDifference = "") {
	LVA_SetCell("GUI_Listview", A_Index, 3, "Red")
	}
}



;Note some fields have extra A_Space or "   " appended to help with LV_ModifyCol() later. modifying each column is resource intensive for overloaded wallboard monitors
Fn_ExportArray(AllTracks_Array,"MainDB")
LV_ModifyCol()
Sleep 100
LV_ModifyCol(1, 160)
;LV_ModifyCol(2, 52) ;Track Code
;LV_ModifyCol(3, 46) ;MTP
;LV_ModifyCol(5) ;Race
;LV_ModifyCol(6, 50) ;Odds
;LV_ModifyCol(7, 40) ;Willpay
;LV_ModifyCol(8, 400) ;Comment

;Color the Listview
LVA_Refresh("GUI_Listview")
OnMessage("0x4E", "LVA_OnNotify")
Sleep 200
;Guicontrol, +ReDraw, GUI_Listview

DiableAllButtons()
EnableAllButtons()
Return







;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; FUNCTIONS
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
;Dependencies
#Include LVA
Return

;~~~~~~~~~~~~~~~~~~~~~
; Variables
;~~~~~~~~~~~~~~~~~~~~~

StartUp()
{
#NoEnv
#NoTrayIcon
#SingleInstance off
;#MaxThreads 10
}

StartInternalGlobals()
{
global
A_LF := "`n"

;Temp
FileCreateDir, %A_ScriptDir%\Data
FileCreateDir, %A_ScriptDir%\Data\DB
;FileCreateDir, %A_ScriptDir%\Data\Temp ;DEPRECIATED
FileInstall, Data\SGR_Locations.txt, %A_ScriptDir%\Data\SGR_Locations.txt, 0
}


Fn_FileTail(FileName, Lines := 100, NewLine := "`r`n")
{
Static MaxLineLength := 256 ; seems to be a reasonable value to start with
	If !IsObject(File := FileOpen(FileName, "r")){
	Return ""
	
	}
Content := ""
LinesLength := MaxLineLength * Lines * (InStr(File.Encoding, "UTF-8") ? 2 : 1)
FileLength := File.Length
BytesToRead := 0
FoundLines := 0
	While (BytesToRead < FileLength) && !(FoundLines) {
	BytesToRead += LinesLength
		If (BytesToRead < FileLength) {
		File.Pos := FileLength - BytesToRead
		} Else {
		File.Pos := 0
		}
	Content := RTrim(File.Read(), NewLine)
	;Msgbox, % Content
		If (FoundLines := InStr(Content, NewLine, 0, 0, Lines)) {
		Content := SubStr(Content, FoundLines + StrLen(NewLine))
		}
	}
File.Close()
Return (Content <> "" ? StrSplit(Content, NewLine) : Content)
}

Fn_IsTimeClose(para_TimeStamp,para_Reverse := 0,para_ReturnType := "s")
{
;Checks if two timestamps are close to each other; returns difference in seconds by default. para_reverse = 1 subtracks 
l_TimeStamp1 := Fn_QuickRegEx(para_TimeStamp,"(\d{2}):")
l_TimeStamp2 := Fn_QuickRegEx(para_TimeStamp,":(\d{2})")
	If (l_TimeStamp1 != "null" && l_TimeStamp2 != "null") {
	FormatTime, Currentday_PRE,, yyyyMMdd
	l_TimeStampConverted := Currentday_PRE . l_TimeStamp1 . l_TimeStamp2 . 00
		;do for normal or reserve
		If (para_reverse = 0) {
		l_Now := A_Now
		l_Now -= l_TimeStampConverted, %para_ReturnType%
		Difference := l_Now
		} Else {
		l_TimeStampConverted -= A_Now, %para_ReturnType%
		Difference := l_TimeStampConverted
		;Difference := l_TimeStampConverted - A_Now
		}
	Return %Difference%
	Msgbox, %l_TimeStampConverted% - %A_Now%  = %Difference%    # (%l_TimeStamp1%%l_TimeStamp2%)
	}
	Return ERROR
}

Sb_DailyRestart(para_RestartTime)
{
global

;Check every 20 mins - DEPRECIATED. Always check
;SetTimer, DailyRestartCheck, 1200000

The_RestartTime := para_RestartTime
DailyRestartCheck:
	If (The_RestartTime = A_Hour) {
	RecalculateToday = 1
	Debug_Msg("recalculating today")
	}
Return
}


Fn_ImportDBData(para_DB,para_DBlabel)
{
;Imports Existing DB File
global
FormatTime, A_Today, , yyyyMMdd
ExternalDB = %A_ScriptDir%\Data\DB\%A_Today%_%The_SystemName%_%The_VersionName%_%para_DBlabel%.json
	If(FileExist(ExternalDB)) {
	FileRead, MemoryFile, %ExternalDB%
	Temp_Array := Fn_JSONtooOBJ(MemoryFile)
	MemoryFile := []
	} Else {
	Temp_Array := []
	}
Return %Temp_Array%
}

;Export Array as a JSON file
Fn_ExportArray(para_DB,para_DBlabel)
{
global
FormatTime, A_Today, , yyyyMMdd
ExternalDB = %A_ScriptDir%\Data\DB\%A_Today%_%The_SystemName%_%The_VersionName%_%para_DBlabel%.json
	If(FileExist(ExternalDB)) {
	FileDelete, %ExternalDB%
	}
MemoryFile := Fn_JSONfromOBJ(para_DB)
FileAppend, %MemoryFile%, %ExternalDB%
MemoryFile := []
}




;~~~~~~~~~~~~~~~~~~~~~
;GUI
;~~~~~~~~~~~~~~~~~~~~~

BuildGUI()
{
Global
;SetTimer, Menu_File-Restart, -10800000	
;SetTimer, Menu_File-Restart, -240000	;FOR DEBUG ONLY

	;Select blah blah 
	RestartFile_Location := A_ScriptDir . "\Restart.txt"
	If (FileExist(RestartFile_Location)) {
	FileRead, The_MemoryFile, % RestartFile_Location
	The_DefaultSystemName := Fn_QuickRegEx(The_MemoryFile,"SystemName:(\w+)")
	GUI_X := Fn_QuickRegEx(The_MemoryFile,"x:(\d+)")
	GUI_Y := Fn_QuickRegEx(The_MemoryFile,"y:(\d+)")
	FileDelete, % RestartFile_Location
	}
	
;Create Array and fill with data about each Data Collector
SGRDatafeeds_Array := []
	Loop, Read, %A_ScriptDir%\Data\SGR_Locations.txt 
	{
	SystemName := Fn_QuickRegEx(A_LoopReadLine,"#\\\\(.+\d)\\")
	FilePath := Fn_QuickRegEx(A_LoopReadLine,"#(\\\\.+)")
	ShortName := Fn_QuickRegEx(A_LoopReadLine,"(.+)#\d")
	Delay := Fn_QuickRegEx(A_LoopReadLine,"#(\d+)")
	
	If (The_DefaultSystemName != "" && InStr(SystemName,The_DefaultSystemName)) {
	makedefault = 1
	} Else {
	makedefault = 0
	}
		
	;Create small list of display options for dropdown selector
	DataFeed_List .= ShortName . "   " . SystemName . "|"
		;Add extra pipe to first item so it is the default selected by GUI
		If (A_Index = 1 && The_DefaultSystemName = "") {
		DataFeed_List .= "|"
		}
		If (makedefault) {
		DataFeed_List .= "|"
		}
		
	SGRDatafeeds_Array[A_Index,"SystemName"] := SystemName
	SGRDatafeeds_Array[A_Index,"FilePath"] := FilePath
	SGRDatafeeds_Array[A_Index,"ShortName"] := ShortName
	SGRDatafeeds_Array[A_Index,"Delay"] := Delay
	}
	
Gui, Add, Text, x440 y3 w100 +Right, %The_VersionName%
Gui, Add, Tab, x2 y0 h900 w550  , Main|Options

;Main Tab
Gui, Add, Button, x2 y30 w100 h30 gUpdateButton, Update
Gui, Add, Button, x302 y30 w50 h30 gViewDB, View DB

Gui, Font, s13 w700, Arial
Gui, Add, DropDownList, x102 y32 w200 vSGR_Choice, %DataFeed_List%

Gui, Add, Progress, x2 y60 w100 h10 hwndMARQ1 vUpdateProgress, 0
Gui, Font, ;Reset Font to normal


;Main View
Gui, Font, s12 w10, Arial ;Needed so visible from far away
Gui, Add, ListView, x2 y70 w546 h750 Grid +ReDraw gDoubleClick vGUI_Listview, Track|Code|MTP|Race|Last|Odds|WP|Comment




;Options Tab
Gui, Tab, Options
Gui, Add, CheckBox, x10 y30 vGUI_RefreshCheckBox gAutoUpdate Checked, Auto-Update every
Gui, Add, Edit, x122 y28 w30 vGUI_RefreshAmmount Number, 6
Gui, Add, Text, x160 y30, minutes
GUI, Submit, NoHide

;Menu
Menu, FileMenu, Add, &Update Now, UpdateButton
Menu, FileMenu, Add, R&estart`tCtrl+R, Menu_File-Restart
Menu, FileMenu, Add, E&xit`tCtrl+Q, Menu_File-Quit
Menu, MenuBar, Add, &File, :FileMenu  ; Attach the sub-menu that was created above

Menu, HelpMenu, Add, &About, Menu_About
Menu, HelpMenu, Add, &Confluence`tCtrl+H, Menu_Confluence
Menu, MenuBar, Add, &Help, :HelpMenu

Gui, Menu, MenuBar

;Show GUI in last location unless error is encountered. Use middle if screen if so
	If (GUI_X = "null" || GUI_Y = "null" || GUI_X = "" || GUI_Y = ""){
	GUI_X = 0
	GUI_Y = 0
	}
	

Gui, Show, h820 w550, % The_ProjectName
	;Loop, 10 
	;{
	;Gui, Show, x%GUI_X% y%GUI_Y%, % The_ProjectName
	;}
	
	If (InStr(The_ProjectName,"VIA")) {
		Loop, 10 
		{
		Gui, Show, x1919 y-1, % The_ProjectName
		}
	
	}
	If (InStr(The_ProjectName,"NJ")) {
		Loop, 10 
		{
		Gui, Show, x2610 y-1, % The_ProjectName
		}
	
	}

;Start Autoupdate by default
GoSub, AutoUpdate
Return

CheckResults:
Return

MsgTotalScratches:
Msgbox, This shows the total number of coupled entry scratches
Return

MsgUnhandledScratches:
Msgbox, This shows the number of coupled entries that have not been handled
Return

MsgEffectedEntries:
Msgbox, This shows the number of coupled entries effected by scratches (1,1A,1X are considered a single entry)
Return



;Options
AutoUpdate:
GUI, Submit, NoHide
RefreshMilli := 0
RefreshMilli := Fn_QuickRegEx(GUI_RefreshAmmount,"(\d+)")

	If(RefreshMilli >= 1 && GUI_RefreshCheckBox = 1)
	{
	RefreshMilli := RefreshMilli * 60000
	GuiControl,, GUI_RefreshCheckBox, 1
	SetTimer, UpdateButton, %RefreshMilli%
	}
	If(GUI_RefreshCheckBox = 0)
	{
	GuiControl,, GUI_RefreshCheckBox, 0
	SetTimer, UpdateButton, Off
	}
Return

DoubleClick:
;Send Track to Json file so it won't be highlighted
	If A_GuiEvent = DoubleClick
	{		
	;Get the text from the row's fourth field. Runner Name
	LV_GetText(RowText, A_EventInfo, 2)
	RowText = %RowText% ;Remove spaces
		If (RowText != "") {
		;Load any existing DB from other Ops
		IgnoredTracks := Fn_ImportDBData(IgnoredTracks,"IgnoredDB")
			Loop, % IgnoredTracks.MaxIndex() {
				If (RowText = IgnoredTracks[A_Index])
				{
				IgnoredTracks.Remove(A_Index)
				Fn_ExportArray(IgnoredTracks,"IgnoredDB")
				Return
				}
			}
		;Add the new name and Export
		IgnoredTracks.Insert(RowText)
		
		Fn_ExportArray(IgnoredTracks,"IgnoredDB")
		}
	}
Return


;Menu Shortcuts
Menu_Confluence:
Run http://confluence.tvg.com/pages/viewpage.action?pageId=11468878
Return

Menu_About:
Msgbox, Checks selected SGR Datafile for up to date data.
Return

Menu_File-Restart:
Gui, Submit, NoHide
The_SystemName := Fn_QuickRegEx(SGR_Choice,"   (\w+)")
WinGetPos, GUI_X, GUI_Y,,, % The_ProjectName
FileAppend, x:%GUI_X% y:%GUI_Y% SystemName:%The_SystemName%`n`r, %A_ScriptDir%\Restart.txt
Sleep 300
Reload

Menu_File-Quit:
ExitApp


ShiftNotes:
Today:= %A_Now%
FormatTime, CurrentDateTime,, MMddyy
Run \\tvgops\pdxshares\wagerops\Daily Shift Notes\%CurrentDateTime%.xlsx
Return
}

ViewDB:
Array_Gui(AllTracks_Array)
Return


Fn_GUI_UpdateProgress(para_Progress1, para_Progress2 = 0)
{
	;Calculate progress if two parameters input. otherwise set if only one entered
	If (para_Progress2 = 0)
	{
	GuiControl,, UpdateProgress, %para_Progress1%+
	}
	Else
	{
	para_Progress1 := (para_Progress1 / para_Progress2) * 100
	GuiControl,, UpdateProgress, %para_Progress1%
	}

}


DiableAllButtons()
{
GuiControl, disable, Update
}


EnableAllButtons()
{
GuiControl, enable, Update
}


EndGUI()
{
global

Gui, Destroy
}


GuiClose:
ExitApp

;~~~~~~~~~~~~~~~~~~~~~
;Subroutines
;~~~~~~~~~~~~~~~~~~~~~


Sb_FlashGUI()
{
SetTimer, FlashGUI, -1000
Return
FlashGUI:

	Loop, 6
	{
	Gui Flash
	Sleep 500  ;Do not change this value
	}
Return
}

;~~~~~~~~~~~~~~~~~~~~~
;Timers
;~~~~~~~~~~~~~~~~~~~~~

Fn_MouseToolTip(para_Message, 10)
{
Global The_Message := para_Message
ToolTip_X := 0
MouseToolTip:
SetTimer, MouseToolTip, 100
MouseGetPos, M_PosX, M_PosY, WinID
ToolTip, %The_Message%, M_PosX, M_PosY, 1
ToolTip_X += 1
	If(ToolTip_X = 100)
	{
	ToolTip
	SetTimer, MouseToolTip, Off
	}
return
}