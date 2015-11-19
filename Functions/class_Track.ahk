Class Track_Class {
	
	__New(para_Name) {
		this.Info_Array := []
		this.MostRecentMessageTypeArray := []
		this.Label := para_Name
		;msgbox, new track added with %para_Name%
	}


	InsertMessage(para_Message) {
		

		;Figure out what type of message it is
		MessageType := Fn_QuickRegEx(para_Message,"0OD\d{4}([A-Z]{2})")
		;msgbox, accepted new message for existing track %MessageType%  

		If (this.Label = "FIM") {
			;msgbox, accepted new message for existing track %MessageType%  
		}

		If (MessageType = "RN") {
			this.MostRecentMessageTypeArray["RN"] := para_Message
			TotalRaces := Fn_QuickRegEx(para_Message,"(([A-Z]|[A-Z0-9]){3})\w+\W+\d{6}(\d{2})",3)
			Return
		}
		If (MessageType = "RI") {
			this.MostRecentMessageTypeArray["RI"] := para_Message
			REG := this.Label . "\d\w+\W+(\d{2})"
			CurrentRace := Fn_QuickRegEx(para_Message,REG)
			;msgbox, % CurrentRace
			;Is this track official?
			If (InStr(FULL_MESSAGE,"OFFICIAL") && this.Label != "null") {
			TrackOfficial := 1
				;Which race is official exactly?
				REG := this.Label . "\d+\w*\W+(\d{2})"
				OfficialRace := Fn_QuickRegEx(FULL_MESSAGE,REG)
			} Else {
			TrackOfficial := 0
			}
			Return
		}
		If (MessageType = "WO") {
			this.MostRecentMessageTypeArray["WO"] := para_Message
			Return
		}
		If (MessageType = "PB") {
			this.MostRecentMessageTypeArray["PB"] := para_Message

			REG := this.Label . "\d+(\s+|\w+)\s\d+(\w+)"
			ProbableType := Fn_QuickRegEx(para_Message,REG,2)
			;msgbox, % ProbableType
			REG := this.Label . "\d+\w+\s\d+\w+\s(\d{2})"
			ProbableRace := Fn_QuickRegEx(para_Message,REG)
			Clipboard := para_Message
			this.SetNumberRaces(ProbableRace)
			Return
		}
		If (MessageType = "PS") {
			this.MostRecentMessageTypeArray["PS"] := para_Message
			Return
		}
		If (MessageType = "PT") {
			this.MostRecentMessageTypeArray["PT"] := para_Message
			Return
		}
		If (MessageType = "SP") {
			this.MostRecentMessageTypeArray["SP"] := para_Message
			Return
		}
		If (MessageType = "WR") {
			this.MostRecentMessageTypeArray["WR"] := para_Message
			Return
		}
		If (MessageType = "WP") {
			this.MostRecentMessageTypeArray["WP"] := para_Message
			Return
		}
		If (MessageType = "RS") {
			this.MostRecentMessageTypeArray["RS"] := para_Message
			Return
		}
		If (MessageType = "FN") {
			this.MostRecentMessageTypeArray["FN"] := para_Message
			Return
		}
		Clipboard := para_Message
		msgbox, didn't understand %MessageType% - %para_Message%
	}

	SetNumberRaces(para_TotalRaces) {
		;msgbox, !!!!!!!trying with %para_TotalRaces%
		this.Info_Arra.Races := []
		Loop, % para_TotalRaces {
			this.Info_Array.Races := []
			Loop, % para_TotalRaces {
				this.Info_Array.Races[A_Index] := "Race " . A_Index
			}
		}
	}
}




;hopefully not needed
Class Races_Class {
	__New() {
		This.Array := []
	}
}