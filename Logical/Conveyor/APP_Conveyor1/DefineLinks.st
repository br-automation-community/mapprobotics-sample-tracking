
ACTION DefineLinks: 
	LinkTrackingPath := ADR(gTrackingPathConveyor_1);
	LinkAxis := ADR(gAxis_Conveyor_1);
	Period := 100000.0;
	
	Reset := ControlPanel.Input.Reset;
	Start := ControlPanel.Input.Start;
	
	ProductGap := 130;
	SetVelocity := LREAL_TO_REAL(ProductGap) / (ControlPanel.Input.PickRate / 60) / 2;
		
END_ACTION
