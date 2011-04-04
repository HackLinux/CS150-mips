module writemask(	input [31:0] ALUOutE,
			input [31:0] RTValE,
			input [1:0] MaskControlE,
			output reg [3:0] MaskE,
			output reg [31:0] WriteDataE);

always@(*)
	case(MaskControlE)
		2'b00: MaskE <= 4'b0000;
		2'b01: begin
			case(ALUOutE[1:0]) 			//SB
				2'b00: MaskE <= 4'b0001;
				2'b01: MaskE <= 4'b0010;
				2'b10: MaskE <= 4'b0100;
				2'b11: MaskE <= 4'b1000;
//				default: $display("Error at time %t: ALUOutE: %b", ALUOutE[1:0]);	//ERROR!
			endcase
			WriteDataE <= {{RTValE[7:0]}, {RTValE[7:0]}, {RTValE[7:0]}, {RTValE[7:0]}};
		end
		2'b10: begin						//SH
			MaskE <= (ALUOutE[1] ? 4'b1100 : 4'b0011);
			WriteDataE <= {{RTValE[15:0]}, {RTValE[15:0]}};
		end							
		2'b11: MaskE <= 4'b1111;				//SW
		default: $display("Error at time %t: MaskControlE: %b", $time, MaskControlE);		//ERROR!

	endcase

endmodule
