PROGRAM _CYCLIC	
	DefineLinks;
	
	CASE State OF
		
		/////////////////////////////////////////////////////////////////////////////
		STATE_WAIT:
		/////////////////////////////////////////////////////////////////////////////
			IF  Start THEN
				State := STATE_RESET;
				MC_Power_0.Enable := FALSE;
			END_IF

		/////////////////////////////////////////////////////////////////////////////
		STATE_RESET:
		////////////////////////////////////////////////////////////////////////////
			MC_Reset_0.Execute := TRUE;
			MC_BR_TrackingPathReset_0.Execute := TRUE;
			
			IF MC_Reset_0.Done AND MC_BR_TrackingPathReset_0.Done THEN
				State := STATE_POWER;
			END_IF
			
			
			
		/////////////////////////////////////////////////////////////////////////////
		STATE_POWER:
		////////////////////////////////////////////////////////////////////////////
			MC_Power_0.Enable := TRUE;
			IF MC_Power_0.Status THEN
				State := STATE_HOME;
			END_IF
			
		/////////////////////////////////////////////////////////////////////////////
		STATE_HOME:
		////////////////////////////////////////////////////////////////////////////
			MC_Home_0.Execute := TRUE;
			IF MC_Home_0.Done THEN
				MC_MoveVelocity_0.Velocity := SetVelocity;
				MC_MoveVelocity_0.Acceleration := SetVelocity/10;
				MC_MoveVelocity_0.Deceleration := SetVelocity/10;
				MC_MoveVelocity_0.Execute := TRUE;
				State := STATE_PRODUCTION;
			END_IF	
				
		///////////////////////////////////////////////////////////////////////////////
		STATE_PRODUCTION: 
		///////////////////////////////////////////////////////////////////////////////
			
			IF MC_MoveVelocity_0.Velocity <> SetVelocity AND MC_MoveVelocity_0.InVelocity THEN
				MC_MoveVelocity_0.Velocity := SetVelocity;
				MC_MoveVelocity_0.Execute := TRUE;
			END_IF
						
			IF MC_ReadStatus_0.Error OR MC_ReadStatus_0.ErrorStop THEN
				State := STATE_ERROR;

			ELSIF NOT Start THEN
				MC_Stop_0.Execute := TRUE;
				IF MC_Stop_0.Done THEN
					State := STATE_WAIT;
				END_IF
			END_IF
			
		///////////////////////////////////////////////////////////////////////////////
		STATE_ERROR:
		///////////////////////////////////////////////////////////////////////////////
			MC_Power_0.Enable := FALSE;
			MC_BR_TrackingPathReset_0.Execute := TRUE;
			
			IF ControlPanel.Input.Reset AND NOT MC_BR_TrackingPathReset_0.Busy THEN
				State := STATE_WAIT;
			END_IF
	END_CASE
	
	

	(* *************************************************************************************************************************** *)
	(* *************************************************************************************************************************** *)
	(* *************************************************************************************************************************** *)

	// Axis commands
	MC_MoveAdditive_0(Axis := LinkAxis);
	MC_MoveVelocity_0(Axis := LinkAxis);
	MC_Stop_0(Axis := LinkAxis);
	MC_Reset_0(Axis := LinkAxis);
	MC_Home_0(Axis := LinkAxis);
	MC_Power_0(Axis := LinkAxis);
	MC_ReadStatus_0(Axis := LinkAxis);
	MC_ReadActualPosition_0(Axis := LinkAxis);
	
	MC_MoveAdditive_0.Execute := FALSE;
	MC_MoveVelocity_0.Execute := FALSE;
	MC_Stop_0.Execute := FALSE;
	MC_Reset_0.Execute := FALSE;
	MC_Home_0.Execute := FALSE;
	MC_Power_0.Enable := MC_Power_0.Enable AND NOT MC_Power_0.Error;
	
	// Trackingpath commands
	MC_BR_TrackingFrameCreate_0(TrackingPath := LinkTrackingPath);
	MC_BR_TrackingFrameDelete_0(TrackingPath := LinkTrackingPath);
	MC_BR_TrackingPathReset_0(TrackingPath := LinkTrackingPath);
	MC_BR_TrackingPathReadStatus_0(TrackingPath := LinkTrackingPath);
	MC_BR_TrackingPathReadInfo_0(TrackingPath := LinkTrackingPath);
	
	MC_BR_TrackingFrameCreate_0.Execute := FALSE;
	MC_BR_TrackingFrameDelete_0.Execute := FALSE;
	MC_BR_TrackingPathReset_0.Execute := FALSE;

END_PROGRAM