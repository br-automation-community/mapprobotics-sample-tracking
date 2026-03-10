ACTION DefineLinks:

	// Define Link to the Robot & Conveyor
	NameAxesGroup	:= 'gAxesGroup_D4r1100R_1';
	LinkAxesGroup	:= ADR(gAxesGroup_D4r1100R_1);
	
	LinkTrackingPath := ADR(gTrackingPathConveyor_1);
	NameTrackingPath := 'gTrackingPathConveyor_1';
	LinkAxisTrackingPath := ADR(gAxis_Conveyor_1);
	
	
	Reset := ControlPanel.Input.Reset;
	Start := ControlPanel.Input.Start;


	MC_BR_MoveProgram_X.Name := 'PickNPlace.st';

				

END_ACTION