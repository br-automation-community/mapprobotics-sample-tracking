
TYPE
	ControlPanelInputs : 	STRUCT  (*Command Buttons*)
		Start : BOOL; (*Run a pick and place application demo*)
		Reset : BOOL; (*Stop Execute*)
		PickRate : REAL; (*Velocity for production [ppm]*)
	END_STRUCT;
	ControlPanelType : 	STRUCT  (*Control Panel*)
		Input : ControlPanelInputs; (*Buttons *)
	END_STRUCT;
END_TYPE
