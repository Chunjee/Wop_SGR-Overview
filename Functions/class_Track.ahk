Class Track_Class {
	
	__New(para_Name) {
		this.Info_Array := []
		this.MostRecentMessageTypeArray := []
		this.Label := para_Name
		;msgbox, new track added with %para_Name%
	}


	ExtractTrackCode(para_message) {
		TrackCode := Fn_QuickRegEx(para_message," \d{5}(\w{3})\d{4}\w{3} ")
		If (TrackCode != "null") {
			Return % TrackCode
		} else {
			Return null
		}
	}


	ExtractTrackName(para_message) {
		
		;Need the Track Code to help isolate the track name (see next comment for possible improvement)
			;possible improvement for no track code required: "[A-Z]{2}\d{4}[A-Z]{2}(.*\b)  "
		TrackCode := this.ExtractTrackCode(para_message)

		;Construct new RegEx with found TrackCode
		REG := "[A-Z]{2}\d{4}[A-Z]{2}(.*\b)\W+\d+" . TrackCode

		;Grab TrackName
		TrackName := Fn_QuickRegEx(para_Message,REG)
		Return % TrackName
	}


	ExtractNextPost(para_message) {

	}


	ExtractTotalRaces(para_message) {
		TotalRaces := Fn_QuickRegEx(para_message,"[\w\d]{3}\W\d{4}(\d{2})")
		if (para_message != "") {
			clipboard := para_message
		}
		Return % TotalRaces
	}


	ExtractCurrentRace(para_message) {
		CurrentRace := Fn_QuickRegEx(para_message,"\d{4}[\w\D]{3}\W+(\d{2})")
		Return % CurrentRace
	}

	


	InsertMessage(para_Message) {
		;Figure out what type of message it is
		MessageType := Fn_QuickRegEx(para_Message,"0OD\d{4}([A-Z]{2})")
		;msgbox, accepted new message for existing track %MessageType%

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
			REG := this.Label . "\d+\w+\s\d+\w+\s(\d{2})"
			ProbableRace := Fn_QuickRegEx(para_Message,REG)
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