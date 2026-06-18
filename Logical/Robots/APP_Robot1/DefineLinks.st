ACTION DefineLinks:

	// Define Link to the Robot & Conveyor
	NameAxesGroup	:= 'gAxesGroup_SRr500_1';
	LinkAxesGroup	:= ADR(gAxesGroup_SRr500_1);
	
	LinkTrackingPath := ADR(gTrackingPathConveyor_1);
	NameTrackingPath := 'gTrackingPathConveyor_1';
	LinkAxisTrackingPath := ADR(gAxis_Conveyor_1);
	
	
	Reset := ControlPanel.Input.Reset;
	Start :=
		(ControlPanel.Input.StartMultipick OR 
		ControlPanel.Input.StartPickNPlace OR 
		ControlPanel.Input.StartPlaceWithConditionalStop OR 
		ControlPanel.Input.StartPrePalletizing OR 
		ControlPanel.Input.StartSorting OR
		ControlPanel.Input.StartMultipickRandom);
	
	IF ControlPanel.Input.StartMultipickRandom THEN
		MC_BR_MoveProgram_X.Name := 'MultipickRandom.st';
	END_IF
	
	IF ControlPanel.Input.StartMultipick THEN
		MC_BR_MoveProgram_X.Name := 'Multipick.st';
	END_IF
	
	IF ControlPanel.Input.StartPickNPlace THEN
		MC_BR_MoveProgram_X.Name := 'PickNPlace.st';
	END_IF
				
	IF ControlPanel.Input.StartPlaceWithConditionalStop THEN
		MC_BR_MoveProgram_X.Name := 'PlaceWithConditionalStop.st';
	END_IF
				
	IF ControlPanel.Input.StartPrePalletizing THEN
		MC_BR_MoveProgram_X.Name := 'PrePalletizing.st';
	END_IF
					
	IF ControlPanel.Input.StartSorting THEN
		MC_BR_MoveProgram_X.Name := 'Sorting.st';
	END_IF

END_ACTION