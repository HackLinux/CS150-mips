module maskdec(	input [3:0] 		MaskOp,
		output reg [1:0]	MaskControlE,
		output reg [1:0]	LBLHEnableM);

  always @(*)
	case(MaskOp)		4'b0000: begin			// no mask
			MaskControlE = 2'b00; 	
			LBLHEnableM = 2'b00;
		end
		4'b0001: begin			// LB
			MaskControlE = 2'b00; 	
			LBLHEnableM = 2'b01;	
		end
		4'b0010: begin  		// LH
			MaskControlE = 2'b00; 	
			LBLHEnableM = 2'b10;	
		end
		4'b0011: begin			// LW
			MaskControlE = 2'b00; 	
			LBLHEnableM = 2'b00;
		end
		4'b0100: begin			// LBU
			MaskControlE = 2'b00; 	
			LBLHEnableM = 2'b00;
		end
		4'b0101: begin			// LHU
			MaskControlE = 2'b00; 	
			LBLHEnableM = 2'b00;
		end
		4'b0110: begin			// SB
			MaskControlE = 2'b01; 	
			LBLHEnableM = 2'b00;	
		end
		4'b0111: begin			// SH
			MaskControlE = 2'b10; 	
			LBLHEnableM = 2'b00;	
		end
		4'b1000: begin			// SW
			MaskControlE = 2'b11; 	
			LBLHEnableM = 2'b00;	
		end
		4'b1001-4'b1111: begin	//UNDEFINED BEHAVIOR;
			MaskControlE = 2'b00; 	//UNDEFINED BEHAVIOR;
			LBLHEnableM = 2'b00; //UNDEFINED BEHAVIOR;
		end //UNDEFINED BEHAVIOR;
//		default: 						//ERROR!
    	endcase
endmodule
