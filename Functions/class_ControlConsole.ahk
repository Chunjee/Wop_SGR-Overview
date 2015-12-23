Class ControlConsole_Class {
	
	__New(para_SystemName) {
		;check for existing JSON file first
		this.Track_Array := []
		this.SystemName := para_SystemName
		this.FirstRun := True

		this.Messages_Array := []
		this.AnonamousRace := new Track_Class("XXX") ;Just used if we want to access some methods
	}


	ImportFiletoDB() {
		this.Track_Array := Fn_ImportDBData(para_DB,"test")
	}
	SaveDBtoFile() {
		Fn_ExportArray(this.Track_Array,"test")
	}


	ImportLatestMessages(para_SGRdirlocation, para_LinesToImport) {
		;;Read the last 2000 lines from the SGR file if the file exists. Returns an array object with each line as an element
		if (FileExist(para_SGRdirlocation)) {

			RawXML := Fn_FileTailRAW(para_SGRdirlocation, para_LinesToImport)
			RawXML := StrReplace(RawXML, "", "")
			RawXML := StrReplace(RawXML, "", "")

				;Append stuff to make it closer to a complete xml file
				If (!InStr(RawXML,"xml version=")) {
					RawXML = <?xml version="1.0" encoding="utf-8" ?>`r`n<Messages>`r`n%RawXML%`r`n</Messages>
				} else {
					;don't append head if grabbed
					RawXML = %RawXML%`r`n</Messages>
				}

			XML_Obj := new xml(RawXML)
			;XML_Obj.viewXML()

			;Not a good solution but keeping as example
			;ITSP_Obj := XML_Obj.getChildren("//Messages")


			this.ITSP_Array := []
			;Find a way to ignore ISTP messages/ids we've already seen
			Loop, % XML_Obj.getChildren("//Messages").MaxIndex() {
				;x := XML_Obj.getChild("//Messages", "element", A_Index)

				this.ITSP_Array[A_Index,"id"] := XML_Obj.selectSingleNode("//Messages/Message[" A_Index "]/@id").text
				this.ITSP_Array[A_Index,"message"] := XML_Obj.selectSingleNode("//Messages/Message[" A_Index "]/@message").text
				;MsgBox, % "Attribute: " x.getAttribute("id") . "`nText: " x.getAttribute("message")
				Fn_GUI_UpdateProgress(A_Index,ITSP_Obj.MaxIndex())
			} 
		} else {
			FileAppend, `n`r%A_Now% - SGR File not created yet at %para_SGRdirlocation%, %A_ScriptDir%\ErrorLog.txt
			LVA_EraseAllCells("GUI_Listview")
			LV_Delete()
			LVA_Refresh("GUI_Listview")
			LV_Add("","SDL file on " . The_SystemName . " not ready") ;this line needs editing
			LV_ModifyCol()
			;Try again after only 30 seconds
			SetTimer, UpdateTimer, -30000
			Return
		}
	}


	ParseMessages() {
		;Read all messages in "buffer" and send them to their track object
		Loop, % this.ITSP_Array.MaxIndex() {
			Fn_GUI_UpdateProgress(A_Index,this.ITSP_Array.MaxIndex())
			message := this.ITSP_Array[A_Index,"message"]
			TrackCode := this.AnonamousRace.ExtractTrackCode(message)
			;this.InsertMessage(message)

			
			;look for existing track
			For Key, Value in this.Track_Array {
				If (this.Track_Array[Key,"TrackCode"] = TrackCode) {

					this.InsertMessage(message)
					;msgbox, % TrackCode "--- " this.Track_Array[Key,"TrackCode"] "   " message
					;This message is now complete; continue to start of next top loop
					Continue 2
				}
			}


			If (TrackCode = "null") {
				FileAppend, `n`r%A_Now% - could not find track code in: %message%, %A_ScriptDir%\ErrorLog.txt
			}
			

			;Not Found; add new track to top Object
			message := this.ITSP_Array[A_Index,"message"]
			TrackCode := this.AnonamousRace.ExtractTrackCode(message)
			;this.InsertMessage(message)
			this.Track_Array[TrackCode,"TrackCode"] := TrackCode
			this.Track_Array[TrackCode,"TrackName"] := this.AnonamousRace.ExtractTrackName(message)
			this.Track_Array[TrackCode,"Object"] := new Track_Class(TrackCode)
			this.Track_Array[TrackCode,"MostRecentMessageTypeArray"] := []
			Continue
		}
		;Clear large array after usage
		this.ITSP_Array := []
	}

	InsertMessage(para_message) {
		;Figure out what type of message it is
		MessageType := Fn_QuickRegEx(para_message,"0OD\d{4}([A-Z]{2})")
		TrackCode := this.AnonamousRace.ExtractTrackCode(para_message)

		if (!IsObject(this.Track_Array[TrackCode,"MostRecentMessageTypeArray"])) {
			this.Track_Array[TrackCode,"MostRecentMessageTypeArray"] := []
		}
		this.Track_Array[TrackCode,"MostRecentMessageTypeArray"][MessageType] := para_message
		

		If (MessageType = "RN") {
			this.RN_Messages(para_message)
			;Remember this message for total races if more than once race is defined
			TotalRaces_SmokeCheck := Fn_QuickRegEx(para_message,"\d{4}[\d\w]{3}\W+.+L.\d+(L)")
			If (TotalRaces_SmokeCheck = "L") {
				this.Track_Array[TrackCode,"MostRecentMessageTypeArray"]["RN_AllRaces"] := para_message
				Return
			}
		}
		Return
	}

	;RN----------------------------------------------------------------------------------------------------------------
	RN_Messages(para_message) {
		TrackCode := this.AnonamousRace.ExtractTrackCode(para_message)
		Race := this.RN_GetRace(para_message)
		Runners := this.RN_GetRunners(para_message)
		Scratches := this.RN_GetScratches(para_message)

		;make sure race array exists
		If (!IsObject(this.Track_Array[TrackCode,"Races"])) {
						this.Track_Array[TrackCode,"Races"] := []
					}

		;add fun info to race array
		this.Track_Array[TrackCode,"Races"][Race,"Runners"] := Runners
		this.Track_Array[TrackCode,"Races"][Race,"Scratches"] := Runners
	}
	RN_GetRace(para_message) {
		TrackCode := this.AnonamousRace.ExtractTrackCode(para_message)
		REG := TrackCode . " (\d{2})"
		l_String := Fn_QuickRegEx(para_message, REG)
		If (l_String != "null") {
			Race := Fn_QuickRegEx(l_String,"0(\d)")
			If (Race = "null") {
				Race := l_String
			}
			Return % Race
		}
	}
	RN_GetRunners(para_message) {
		TrackCode := this.AnonamousRace.ExtractTrackCode(para_message)
		REG := TrackCode . " (\d{6}.+)"
		l_String := Fn_QuickRegEx(para_message, REG)
		If (l_String != "null") {
			l_String := Fn_QuickRegEx(l_String,"\d([LS]+)")
			;While (InStr(l_String,"L") || InStr(l_String,"S")) ;wait no faster to just count length of "LLLLLLSLSLSLL"
			If (l_String != "null") {
				OutputVar := StrLen(l_String)
				Return % OutputVar
			}
		}
	}
	RN_GetScratches(para_message) {
		TrackCode := this.AnonamousRace.ExtractTrackCode(para_message)
		REG := TrackCode . " (\d{6}.+)"
		l_String := Fn_QuickRegEx(para_message, REG)
		;clipboard := para_message
		If (l_String != "null") {
			l_String := Fn_QuickRegEx(l_String,"\d([LS]+)")
			StrReplace(l_String,"S","", OutputVarCount)
		}
		Return % OutputVarCount
	}
	


	UpdateOffLatestMessages() {
	;Grab most recent information for GUI display
		For Key, in this.Track_Array {
			;Use [RI] for Next Post Time
			this.Track_Array[Key,"NextPost"] := this.AnonamousRace.ExtractNextPost(this.Track_Array[Key,"MostRecentMessageTypeArray"].RI)
			;and how many MTP is that?
			this.Track_Array[Key,"MTP"] := this.AnonamousRace.ExtractMTP(this.Track_Array[Key,"MostRecentMessageTypeArray"].RI,"0")

			;Use [RN_AllRaces] for Total Races
			this.Track_Array[Key,"TotalRaces"] := this.AnonamousRace.ExtractTotalRaces(this.Track_Array[Key,"MostRecentMessageTypeArray"].RN_AllRaces)

			;Use [RI] for Current Race
			this.Track_Array[Key,"CurrentRace"] := this.AnonamousRace.ExtractCurrentRace(this.Track_Array[Key,"MostRecentMessageTypeArray"].RI)

			;Use [RI] for Official Race
			this.Track_Array[Key,"OfficialRace"] := this.AnonamousRace.ExtractCurrentRace(this.Track_Array[Key,"MostRecentMessageTypeArray"].RI)


			if (this.Track_Array[Key,"TotalRaces"] = "" || this.Track_Array[Key,"TotalRaces"] = "null") {
				this.Track_Array[Key,"TotalRaces"] := "??"
			}
			this.Track_Array[Key,"GUI_Race"] := this.Track_Array[Key,"CurrentRace"] "/" this.Track_Array[Key,"TotalRaces"]



			;Is Track done with all races?
			if (this.Track_Array[Key,"TotalRaces"] = this.Track_Array[Key,"CurrentRace"]) {
				if (this.Track_Array[Key,"OfficialRace"] = this.Track_Array[Key,"TotalRaces"]) {
					this.Track_Array[Key,"Completed"] := True
				} else {
					;do nothing
				}
			} else {
			this.Track_Array[Key,"Completed"] := False
			}
		}
	}


	LoopAllTracks() {
		For Key, in this.Track_Array {
			if (this.Track_Array[Key,"TotalRaces"] != "??") {
				this.CreatRacesDepth(Key,this.Track_Array[Key,"TotalRaces"])
			}
		}
	}


	CreatRacesDepth(para_TrackCode, para_Races) {
		;strip out any leading 0
		para_Races2 := Fn_QuickRegEx(para_Races,"0(\d)")
			If (para_Races2 != "null") {
				para_Races := para_Races2
			}
		If (this.Track_Array[para_TrackCode,"Races"].MaxIndex() != para_Races) {
			this.Track_Array[para_TrackCode,"Races"] := []
			Loop, % para_Races {
				this.Track_Array[para_TrackCode,"Races"].Insert("Race" . A_Index)
			}
		}
		
	}


	ExportListview() {

		;Clear existing listview
		LVA_EraseAllCells("GUI_Listview")
		LV_Delete()

		;Copy the main array
		this.GUI_Array := this.Track_Array.Clone()

		;Sort the new copy
		Fn_Sort2DArray(this.GUI_Array, "MTP")

		;Loop all tracks and export to listview if all races are finished
		For Key, in this.Track_Array {
			if (this.Track_Array[Key,"Completed"] = False){
				;Export 
				this.ExportLV(Key)
				}
		}


		;Loop all tracks and export to listview if race is not finished
		For Key, in this.Track_Array {
			if (this.Track_Array[Key,"Completed"] = True){
				;Export
				this.ExportLV(Key)
			}
		}


		;resize listview to my happiness
		LV_ModifyCol()
		LV_ModifyCol(1, 170)
		LV_ModifyCol(3, 60)
		LV_ModifyCol(4, 70)
	}


	ExportLV(para_key) {
		LV_Add("",this.GUI_Array[para_key,"TrackName"],this.GUI_Array[para_key,"TrackCode"],this.GUI_Array[para_key,"MTP"],this.GUI_Array[para_key,"GUI_Race"],"",this.Track_Array[para_key,"Odds"],this.Track_Array[para_key,"WillPay"],this.Track_Array[para_key,"Comment"])
	}


	ExpandTrack(para_TrackCode,para_RowNumber) {
		for Key in this.GUI_Array
		{
			this.ExportLV(Key)
			if (para_TrackCode = this.GUI_Array[Key,"TrackCode"]) {
				;Export all races about that track
				Loop, % this.Track_Array[para_TrackCode,"Races"].MaxIndex()	{
					para_RowNumber++
					Runners := this.Track_Array[para_TrackCode,"Races"][A_Index,"Runners"]
					Scratches := this.Track_Array[para_TrackCode,"Races"][A_Index,"Scratches"]
					LV_Insert(para_RowNumber, ,"Race " A_Index "  R:" Runners " S:"Scratches)
				}
			}
		}
	}


	ConsiderEarlyMessages(para_SGRdirlocation,para_LinesToImport) {
		;;Read the
		RawXML := ""
		if (FileExist(para_SGRdirlocation)) {
			File := FileOpen(para_SGRdirlocation, "r")
			Loop, % para_LinesToImport {
				RawXML := RawXML . File.ReadLine()
			}

			RawXML := StrReplace(RawXML, "", "")
			RawXML := StrReplace(RawXML, "", "")
				;Append stuff to make it closer to a complete xml file
				If (!InStr(RawXML,"xml version=")) {
					RawXML = <?xml version="1.0" encoding="utf-8" ?>`r`n<Messages>`r`n%RawXML%`r`n</Messages>
				} else {
					;don't append head if grabbed
					RawXML = %RawXML%`r`n</Messages>
				}

			XML_Obj := new xml(RawXML)


			this.ITSP_Array := []
			;Find a way to ignore ISTP messages/ids we've already seen
			Loop, % XML_Obj.getChildren("//Messages").MaxIndex() {
				;x := XML_Obj.getChild("//Messages", "element", A_Index)

				this.ITSP_Array[A_Index,"id"] := XML_Obj.selectSingleNode("//Messages/Message[" A_Index "]/@id").text
				this.ITSP_Array[A_Index,"message"] := XML_Obj.selectSingleNode("//Messages/Message[" A_Index "]/@message").text
				;MsgBox, % "Attribute: " x.getAttribute("id") . "`nText: " x.getAttribute("message")
				Fn_GUI_UpdateProgress(A_Index,ITSP_Obj.MaxIndex())
			} 
		} else {
			FileAppend, `n`r%A_Now% - SGR File not created yet at %para_SGRdirlocation%, %A_ScriptDir%\ErrorLog.txt
			LVA_EraseAllCells("GUI_Listview")
			LV_Delete()
			LVA_Refresh("GUI_Listview")
			LV_Add("","SDL file on " . The_SystemName . " not ready") ;this line needs editing
			LV_ModifyCol()
			;Try again after only 30 seconds
			SetTimer, UpdateTimer, -30000
			Return
		}
	}


	ReturnTopObject() {
		Return % this.Track_Array
	}
}