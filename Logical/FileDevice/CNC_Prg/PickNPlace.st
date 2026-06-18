VAR CONSTANT
	UpperZLevel : LREAL := 10.0;	// Gripper up position
	LowerZLevel : LREAL := -10.0;	// Gripper down movement
END_VAR

VAR	

	ParkPos				: McPointType := (Pos:=(X:=	  300, Y:= 100, Z:= 50));
	ParkPosRight		: McAxisTargetType :=(JointAxis:=[45, -90, -20, 0]);
		
	SynchPosUp			: McPointType := (Pos:=(X:=   0, Y:= 0, 			Z:= UpperZLevel));
	SynchPosDown		: McPointType := (Pos:=(X:=   0, Y:= 0, 			Z:= LowerZLevel));
			
	FrameIn : McTrkFrmIdentType;
END_VAR


PROGRAM _MAIN
	
	// Position init, reset frame in case of restart
	SetPCS(MachineFrame);	
	MoveAR(ParkPosRight);
	SetProductLoad('ProductLoad_1');
	Feedrate(1000);
	MoveL(ParkPos);
	WaitEndMove();
	
	WaitUntil(TrackingFrameSelect(FrameIn,'Infeed'));				// hold interpreter until a new frame is available 
	REPEAT		

		TrackObjectR(FrameIn, SynchPosUp, 25, 25);					// track on product
		Relative();
		MoveLR(SynchPosDown);										// move to the take position
		WaitTime(0.075);											// Wait cause delay of gripper
		MoveLR(SynchPosUp);											// move up to change frame
		Absolute();
		
		TrackStopR(FixedPlace, SynchPosUp, 50, 50);					// Move to the fixed place Position
		Relative();
		MoveLR(SynchPosDown);										// move to the take position
		WaitTime(0.2);												// Wait cause delay of gripper
		MoveLR(SynchPosUp);											// move up to change frame
		Absolute();
		WaitALAP();
		
		IF NOT TrackingFrameSelect(FrameIn,'Infeed') THEN			// Need to stop, no objects left	
			MoveLR(ParkPos);								
			WaitEndMove();											// sync interpreter and program 
			WaitUntil(TrackingFrameSelect(FrameIn,'Infeed'));		// hold interpreter until a new frame is available 
		END_IF
		
	UNTIL FALSE END_REPEAT;
	
END_PROGRAM 