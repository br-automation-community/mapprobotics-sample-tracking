FUNCTION_BLOCK MC_BR_CyclicDriveErrorDecel (*writes cyclically the deceleration which is used in case of drive error*)
    VAR_INPUT
        Axis : REFERENCE TO McAxisType; (*axis reference*)
        Enable : BOOL; (*FB is active as long as input is set*)
        AdvancedParameters : McAdvCycDriveErrDecParType; (*additional input parameters for optional use with the function block.*)
        CyclicDeceleration : REAL; (*cyclic deceleration that is transferred to the axis*)
    END_VAR
    VAR_OUTPUT
        Valid : BOOL; (*initialization complete, deceleration is beeing transferred cyclically*)
        Busy : BOOL; (*FB is active and needs to be called*)
        Error : BOOL; (*error occurred during operation*)
        ErrorID : DINT; (*error number*)
    END_VAR
    VAR
        Internal : McInternalType;(*internal variable*)
    END_VAR
END_FUNCTION_BLOCK
