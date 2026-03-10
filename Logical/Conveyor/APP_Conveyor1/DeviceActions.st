ACTION addNewObjects:
	
	// overflow handling
	IF MC_ReadActualPosition_0.Position < LastProductPosition THEN
		LastProductPosition := LastProductPosition - Period;
	END_IF
	
	IF MC_ReadActualPosition_0.Position <  LastProductPosition	+ ProductGap THEN
		RETURN;
	END_IF
	
	IF Multipick THEN	
		MC_BR_TrackingFrameCreate_0.Parameters.Translation.Y := 80 - UDINT_TO_LREAL(createCnt MOD 2) * 160;
		createCnt := createCnt + 1;
		
		IF createCnt MOD 2 = 0 THEN
			LastProductPosition := MC_ReadActualPosition_0.Position;
		END_IF
		
	ELSE
		IF RandomCreation THEN
			MC_BR_TrackingFrameCreate_0.Parameters.Translation.Y := (UINT_TO_LREAL((TIM_musec()*10) MOD 160) - 80);
			MC_BR_TrackingFrameCreate_0.Parameters.Orientation.Angle3 := (UINT_TO_LREAL((TIM_musec()*10) MOD 178)-89);
		ELSE
			MC_BR_TrackingFrameCreate_0.Parameters.Translation.Y := 0;
			MC_BR_TrackingFrameCreate_0.Parameters.Orientation.Angle3 := 0;
		END_IF
		LastProductPosition := MC_ReadActualPosition_0.Position;
	END_IF

	
	// simulate two diffent product types
	MC_BR_TrackingFrameCreate_0.Parameters.Attribute := 2#0001;
	IF (TIM_ticks() MOD 2) = 1 THEN
		MC_BR_TrackingFrameCreate_0.Parameters.Attribute := 2#0011;
	END_IF;
		
	// Add frame in the buffer
	MC_BR_TrackingFrameCreate_0.Parameters.LatchedPath.Position := MC_ReadActualPosition_0.Position;
	MC_BR_TrackingFrameCreate_0.Execute	:= TRUE;
	
END_ACTION
