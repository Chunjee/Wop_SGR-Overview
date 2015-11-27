Class Track_Class {
	
	__New(para_Name) {
		;this.Info_Array := []
		;this.MostRecentMessageTypeArray := []
		;msgbox, new track added with %para_Name%
	}


	ExtractTrackCode(para_message) {
		TrackCode := Fn_QuickRegEx(para_message," \d{5}(\w{3})\d{4}\w{3} ")
		If (TrackCode != "null") {
			Return % TrackCode
		} else {
			Return "null"
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


	ExtractMTP(para_message,para_delay) {
		PostTime := Fn_QuickRegEx(para_message,"[\w\d]{3}\W\d{20}(\d{4})")
		l_TimeStamp1 := Fn_QuickRegEx(PostTime,"(\d{2})\d{2}")
		l_TimeStamp2 := Fn_QuickRegEx(PostTime,"\d{2}(\d{2})")
		MTP := Fn_TimeDifference(l_TimeStamp1 . ":" . l_TimeStamp2,1,"m")
		;Msgbox, % l_TimeStamp1 . ":" . l_TimeStamp2
		Return % MTP
	}

	;not working
	ExtractMTP2(para_message,para_delay) {
		PostTime := Fn_QuickRegEx(para_message,"\W\d{20}(\d{4})")
		l_TimeStamp1 := Fn_QuickRegEx(PostTime,"(\d{2})\d{2}")
		l_TimeStamp2 := Fn_QuickRegEx(PostTime,"\d{2}(\d{2})")
		msgbox, % l_TimeStamp1 l_TimeStamp2
		If (l_TimeStamp2 <= 25) {
			Currentday_PRE := "20010102"
		} else {
			Currentday_PRE := "20010101"
		}
		l_TimeStampConverted := Currentday_PRE . l_TimeStamp1 . l_TimeStamp2 . "00"

		l_Now := "20010101" . Fn_QuickRegEx(A_Now,"\d{8}(\d{4})\d{2}") . "00"
		;msgbox, % l_Now "`r-`r" l_TimeStampConverted
		l_Now -= l_TimeStampConverted, m

		MTP := l_Now
		MTP += %para_delay%
		/*
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
	*/
		Return % MTP
	}


	ExtractTotalRaces(para_message) {
		TotalRaces := Fn_QuickRegEx(para_message,"[\w\d]{3}\W\d{6}(\d{2})")
		Return % TotalRaces
	}


	ExtractCurrentRace(para_message) {
		CurrentRace := Fn_QuickRegEx(para_message,"\d{4}[\w\D]{3}\W+(\d{2})")
		Return % CurrentRace
	}

	
	ExtractMessageType(para_message) {
		MessageType := Fn_QuickRegEx(para_Message,"0OD\d{4}([A-Z]{2})")
		Return % MessageType
	}


	ExtractOfficialRace(para_message) {
		if(InStr(para_message,"TRACK      OFFICIAL")) {
			OfficialRace := Fn_QuickRegEx(para_message,"\d{4}[\w\D]{3}\W+(\d{2})")
			if(OfficialRace != "null") {
				Return OfficialRace
			}
		} else {
			Return False
		}
	}


	;DEPRECIATED
	/*
	InsertMessage(para_Message) {
		msgbox, working with %para_Message%
		;Figure out what type of message it is
		MessageType := Fn_QuickRegEx(para_Message,"0OD\d{4}([A-Z]{2})")
		;msgbox, accepted new message for existing track %MessageType%

		If (MessageType = "RN") {
			this.MostRecentMessageTypeArray["RN"] := para_Message

			;Remember this message for total races if more than once race is defined
			TotalRaces_SmokeCheck := Fn_QuickRegEx(para_Message,"\d{4}[\d\w]{3}\W+.+L.\d+(L)")
			If (TotalRaces_SmokeCheck = "L") {
				this.MostRecentMessageTypeArray["RN_AllRaces"] := para_Message
				msgbox, % para_Message
			}
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
	*/

	SetNumberRaces(para_TotalRaces) {
		;msgbox, !!!!!!!trying with %para_TotalRaces%
		this.Info_Array.Races := []
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