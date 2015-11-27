Class ControlConsole_Class {
	
	__New(para_SystemName) {
		;check for existing JSON file first
		this.Track_Array := []
		/*
		For Key, Value in this.Track_Array {
			X := A_Index
		}
		if (X = "") {
			;for clarity only, create empty array if no file was loaded. (first run of today)
			this.Track_Array := []
		} else {
			For Key, Value in this.Track_Array {
				TrackCode := this.Track_Array[Key,"TrackCode"]
				this.Track_Array[Key,"Object"] := new Track_Class(TrackCode)
			}
			;msgbox, objects re-created
			ARRAY_GUI(this.Track_Array)
		}
		*/

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
		if (InStr(para_message,"DOWNS EVE")) {
			clipboard := para_message
			;msgbox, % para_message
			FileAppend, `n`r%TrackCode% - %para_message%, %A_ScriptDir%\ErrorLog.txt
		}

		if (!IsObject(this.Track_Array[TrackCode,"MostRecentMessageTypeArray"])) {
			this.Track_Array[TrackCode,"MostRecentMessageTypeArray"] := []
		}
		this.Track_Array[TrackCode,"MostRecentMessageTypeArray"][MessageType] := para_message
		

		If (MessageType = "RN") {
			;Remember this message for total races if more than once race is defined
			TotalRaces_SmokeCheck := Fn_QuickRegEx(para_message,"\d{4}[\d\w]{3}\W+.+L.\d+(L)")
			If (TotalRaces_SmokeCheck = "L") {
				this.Track_Array[TrackCode,"MostRecentMessageTypeArray"]["RN_AllRaces"] := para_message
			}
		}
		Return
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
				LV_Add("",this.GUI_Array[Key,"TrackName"],this.GUI_Array[Key,"TrackCode"],this.GUI_Array[Key,"MTP"],this.GUI_Array[Key,"GUI_Race"],"",this.Track_Array[Key,"Odds"],this.Track_Array[Key,"WillPay"],this.Track_Array[Key,"Comment"])
				}
			
		}


		;Loop all tracks and export to listview if race is not finished
		For Key, in this.Track_Array {
			if (this.Track_Array[Key,"Completed"] = True){
				;Export 
				LV_Add("",this.GUI_Array[Key,"TrackName"],this.GUI_Array[Key,"TrackCode"],this.GUI_Array[Key,"MTP"],this.GUI_Array[Key,"GUI_Race"],"",this.Track_Array[Key,"Odds"],this.Track_Array[Key,"WillPay"],this.Track_Array[Key,"Comment"])
			}
		}


		;resize listview to my happiness
		LV_ModifyCol()
		LV_ModifyCol(1, 160)
		LV_ModifyCol(3, 60)
		LV_ModifyCol(4, 70)
	}


	FindTrack(para_TrackCode) {

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