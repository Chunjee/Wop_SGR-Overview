Class ControlConsole_Class {
	
	__New() {
		;Maybe check for existing JSON file first
		this.Track_Array := []
		;this.Track_Array["1","TrackCode"] := "Blank"

		this.Messages_Array := []
	}

	ImportLatestMessages(para_SGRdirlocation, para_LinesToImport) {
		;;Read the last 2000 lines from the SGR file if the file exists. Returns an array object with each line as an element
		if (FileExist(para_SGRdirlocation)) {

			RawXML := Fn_FileTailRAW(para_SGRdirlocation, para_LinesToImport)
			RawXML := StrReplace(RawXML, "", "")
			RawXML := StrReplace(RawXML, "", "")
			RawXML = <?xml version="1.0" encoding="utf-8" ?>`r`n<Messages>`r`n%RawXML%`r`n</Messages>

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
			FileAppend, `n`r%A_Now% - SGR File not created yet on %The_SystemName%, %A_ScriptDir%\ErrorLog.txt
			LVA_EraseAllCells("GUI_Listview")
			LV_Delete()
			LVA_Refresh("GUI_Listview")
			LV_Add("","SDL file on " . The_SystemName . " not ready")
			LV_ModifyCol()
			;Try again after only 30 seconds
			SetTimer, UpdateTimer, -30000
			Return
		}
	}

	ParseMessages() {
		;Read all messages in "buffer" and send them to their track object
		Loop, % this.ITSP_Array.MaxIndex() {
			TrackCode := Fn_QuickRegEx(this.ITSP_Array[A_Index,"message"]," \d{5}(\w{3})\d{4}\w{3} ")
			X := A_Index
			If (TrackCode = "null") {
				message := this.ITSP_Array[A_Index,"message"]
				FileAppend, `n`r%A_Now% - could not find track code in: %message%, %A_ScriptDir%\ErrorLog.txt
			}

			;Look for an existing match to the track
			Loop, % this.TrackArray.MaxIndex() {
				
				If (this.TrackArray[A_Index,"TrackCode"] = TrackCode) {
					this.TrackArray[A_Index,"Object"].InsertMessage(this.ITSP_Array[X,"message"])
					Continue 2
				}
			}

			Y := this.TrackArray.MaxIndex()
			Y++
			;Not Found; add new track to top Object
			this.TrackArray[Y,"Object"] := new Track_Class(TrackCode)
			this.TrackArray[Y,"TrackCode"] := TrackCode
			this.TrackArray[Y,"Object"].InsertMessage(this.ITSP_Array[X,"message"])
			Continue
		}
	}


	ExtractTrackCode(para_message) {

	}


	FindTrack(para_TrackCode) {

	}


	ConsiderAllMessages() {

	}


	ReturnTopObject() {
		Return % this.TrackArray
	}
}