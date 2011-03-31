module maskdec(	input [1:0] 		MaskOp,
		output reg [1:0]	MaskControlE,
		output reg [1:0]	LBLHEnableM);

  always @(*)
	case(MaskOp)		2'b00: begin			// no mask
			MaskControlE <= 2'b00; 	
			LBLHEnableM <= 2'b00;
		end
		2'b01: begin			// byte
			MaskControlE <= 2'b01; 	
			LBLHEnableM <= 2'b01;	
		end
		2'b10: begin  		     	// half word
			MaskControlE <= 2'b10; 	
			LBLHEnableM <= 2'b10;	
		end
		2'b11: begin			// ??
			// ??
		end
    	endcase
endmodule
