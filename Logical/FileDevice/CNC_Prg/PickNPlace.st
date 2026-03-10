VAR CONSTANT
	UpperZLevel : LREAL := 100.0;	// Gripper up position
	MidZLevel   : LREAL := 10.0;	// Gripper up position
	MidYLevel   : LREAL := -10.0;	// Gripper up position
	LowerZLevel : LREAL := 0.0;		// Gripper down position
	YProductPos : LREAL := 200;		// position in y coordinate where the product should be placed
END_VAR
	
VAR	
	ParkPos				: McPointType := (Pos:=(X:=-100, Y:=100, 			Z:= UpperZLevel));
	SynchPosUp			: McPointType := (Pos:=(X:=   0, Y:= 0, 			Z:= UpperZLevel));
	SynchPosDown		: McPointType := (Pos:=(X:=   0, Y:= 0, 			Z:= LowerZLevel));
	SynchPosSide		: McPointType := (Pos:=(X:= MidYLevel, Y:= 0, 		Z:= MidZLevel));
	SynchPosSideUP		: McPointType := (Pos:=(X:= MidYLevel, Y:= 0, 		Z:= UpperZLevel));
		
	FrameIn : McTrkFrmIdentType;
	FrameOut : McTrkFrmIdentType;
END_VAR


PROGRAM _MAIN
	
	// Position init, reset frame in case of restart
	SetPCS(MachineFrame);
	MoveLR(ParkPos);
	WaitEndMove();
	
	WaitUntil(TrackingFrameSelect(FrameIn,'Infeed'));				// hold interpreter until a new frame is available 
	REPEAT		

		TrackObjectR(FrameIn, SynchPosUp, 50, 50);					// track on product
		MoveLR(SynchPosDown);										// move to the take position
		WaitTime(0.04);												// Wait cause delay of gripper
		SetM(32);													// Scene - remove product from belt, close gripper
		WaitALAP();													// hold interpreter
		
		Feedrate(5000);												// low feedrate while start	
		MoveL(SynchPosSide);										// move to the side to change frame		
		MoveLR(SynchPosSideUP);										// move up to change frame
		IF NOT TrackingFrameSelect(FrameOut,'Outfeed') THEN			// Need to stop, no objects left
			TrackStopR(MachineFrame, ParkPos, 50, 50);				// Move to a static frame							
			WaitEndMove();											// sync interpreter and program 
			WaitUntil(TrackingFrameSelect(FrameOut,'Outfeed'));		// hold interpreter until a new frame is available 
		END_IF

		TrackObjectR(FrameOut, SynchPosUp, 50, 50);					// move to place position
		MoveLR(SynchPosDown);										// move down on place position
		WaitTime(0.04);												// Wait cause delay of gripper
		SetM(16);													// Scene - place product on belt, open gripper
		WaitALAP();													// hold interpreter 
		TrackingFrameSetAttribute(FrameOut, 1);						// Transfer attribute value
		
		MoveLR(SynchPosUp);											// move up to change frame
		IF NOT TrackingFrameSelect(FrameIn,'Infeed') THEN			// Need to stop, no objects left
			TrackStopR(MachineFrame, ParkPos, 50, 50);				// Move to a static frame							
			WaitEndMove();											// sync interpreter and program 
			WaitUntil(TrackingFrameSelect(FrameIn,'Infeed'));		// hold interpreter until a new frame is available 
		END_IF
		
	UNTIL FALSE END_REPEAT;
	
END_PROGRAM 