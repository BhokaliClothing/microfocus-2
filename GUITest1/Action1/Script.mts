Function SITID
	
Device("Device").App("NEXT-SIT").MobileEdit("SIT_textfield").SetFocus
Device("Device").App("NEXT-SIT").MobileEdit("SIT_textfield").Set ""
Device("Device").App("NEXT-SIT").MobileEdit("SIT_textfield").Set "SIT004"

End Function


Device("Device").App("Home").MobileLabel("NEXT-SIT").Tap
Call SITID
Device("Device").App("NEXT-SIT").MobileButton("Next").Tap
