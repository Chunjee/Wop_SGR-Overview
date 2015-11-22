Class ControlConsole_Class {
	
	__New(para_SystemName) {
		;check for existing JSON file first
		;this.Track_Array := Fn_ImportDBData(para_DB,"test")
			if (this.Track_Array.MaxIndex() = "") {
				;for clarity only, create empty array if no file was loaded. (first run of today)
				this.Track_Array := []
				msgbox, made new
			}

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
			;TrackCode := Fn_QuickRegEx(this.ITSP_Array[A_Index,"message"]," \d{5}(\w{3})\d{4}\w{3} ")
			TrackCode := this.AnonamousRace.ExtractTrackCode(this.ITSP_Array[A_Index,"message"])
			X := A_Index
			;Look for an existing match to the track
			msgbox, % this.TrackArray.MaxIndex() "alllllllllllf"
			;Array_GUI(this.Track_Array)
			Loop, % this.TrackArray.MaxIndex() {
				If (this.TrackArray[A_Index,"TrackCode"] = TrackCode) {
					this.TrackArray[A_Index,"Object"].InsertMessage(this.ITSP_Array[X,"message"])
					;This message is now complete; continue to start of next top loop
					Continue 2
				}
			}


			If (TrackCode = "null") {
				message := this.ITSP_Array[A_Index,"message"]
				FileAppend, `n`r%A_Now% - could not find track code in: %message%, %A_ScriptDir%\ErrorLog.txt
			}


			Y := this.TrackArray.MaxIndex()
			Y++
			;Not Found; add new track to top Object
			this.TrackArray[Y,"Object"] := new Track_Class(TrackCode)
			this.TrackArray[Y,"Object"].InsertMessage(this.ITSP_Array[X,"message"])

			;lets remember some stuff about this track while we are here
			this.TrackArray[Y,"TrackCode"] := TrackCode
			this.TrackArray[Y,"TrackName"] := this.AnonamousRace.ExtractTrackName(this.ITSP_Array[X,"message"])
			Continue
		}
	}


	UpdateOffLatestMessages() {
	;Grab most recent information for GUI display
		Loop, % this.TrackArray.MaxIndex() {
			;Use [RI] for Next Post Time
			this.TrackArray[A_Index,"NextPost"] := this.AnonamousRace.ExtractNextPost(this.TrackArray[A_Index,"Object"].MostRecentMessageTypeArray.RI)
			;and how many MTP is that?
			this.TrackArray[A_Index,"MTP"] := ""

			;Use [RN_AllRaces] for Total Races
			this.TrackArray[A_Index,"TotalRaces"] := this.AnonamousRace.ExtractTotalRaces(this.TrackArray[A_Index,"Object"].MostRecentMessageTypeArray.RN_AllRaces)

			;Use [RI] for Current Race
			this.TrackArray[A_Index,"CurrentRace"] := this.AnonamousRace.ExtractCurrentRace(this.TrackArray[A_Index,"Object"].MostRecentMessageTypeArray.RI)

			If (this.TrackArray[A_Index,"TotalRaces"] = "" || this.TrackArray[A_Index,"TotalRaces"] = "null") {
				this.TrackArray[A_Index,"GUI_Race"] := this.TrackArray[A_Index,"CurrentRace"] "/??" 
			} else {
				this.TrackArray[A_Index,"GUI_Race"] := this.TrackArray[A_Index,"CurrentRace"] "/" this.TrackArray[A_Index,"TotalRaces"]
			}
		}
	}


	ExportListview() {
		Fn_Sort2DArray(this.TrackArray, "MTP")
		Loop, % this.TrackArray.MaxIndex() {
			LV_Add("",this.TrackArray[A_Index,"TrackName"],this.TrackArray[A_Index,"TrackCode"],this.TrackArray[A_Index,"MTP"],this.TrackArray[A_Index,"GUI_Race"],"",this.TrackArray[A_Index,"Odds"],this.TrackArray[A_Index,"WillPay"],this.TrackArray[A_Index,"Comment"])
			
		}

					;first idea; probably bad
					/*
					LV_Array := []
					Loop, % this.TrackArray.MaxIndex() {

						LV_Array[A_Index,"TrackName"] := this.TrackArray[A_Index,"TrackName"]
						LV_Array[A_Index,"TrackCode"] := this.TrackArray[A_Index,"TrackCode"]
						LV_Array[A_Index,"MTP"] := ""

						;Sort the temporary array
						Fn_Sort2DArray(LV_Array, "MTP")

						;Export to the listview
						Loop, % LV_Array.MaxIndex() {
							;LV_Add("",TrackName,)
							;LV_Add("",AllTracks_Array[A_Index,"TrackName"],AllTracks_Array[A_Index,"TrackCode"] . " ",AllTracks_Array[A_Index,"MTP"] . " ",AllTracks_Array[A_Index,"CurrentRace"] . "/" . AllTracks_Array[A_Index,"TotalRaces"],TimeDifference . "   ",PB . "   ",WP . "   ",AllTracks_Array[A_Index,"Comment"])
						}
					}
					*/

		LV_ModifyCol()
		LV_ModifyCol(1, 160)
		LV_ModifyCol(3, 60)
		LV_ModifyCol(4, 60)
	}


	FindTrack(para_TrackCode) {

	}


	ConsiderAllMessages() {

	}


	ReturnTopObject() {
		Return % this.TrackArray
	}
}