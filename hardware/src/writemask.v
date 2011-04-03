module writeMaskE(	input [1:0] MaskEControlE,
			input [31:0] ALUOut,
			input [31:0] WriteData,
			output reg [3:0] MaskE,
			output reg [31:0] WriteDataE);


always@(*)
	case(MaskEControlE)
		2'b00: MaskE <= 4'b0000;
		2'b01: begin
			case(ALUOut[1:0]) 			//SB
				2'b00: MaskE <= 4'b0001;
				2'b01: MaskE <= 4'b0010;
				2'b10: MaskE <= 4'b0100;
				2'b11: MaskE <= 4'b1000;
//				default:				//ERROR!
			endcase
			WriteDataE <= {{WriteData[7:0]}, {WriteData[7:0]}, {WriteData[7:0]}, {WriteData[7:0]}};
		end
		2'b10: begin						//SH
			MaskE <= (ALUOut[1] ? 4'b1100 : 4'b0011);
			WriteDataE <= {{WriteData[15:0]}, {WriteData[15:0]}};
		end							
		2'b11: MaskE <= 4'b1111;				//SW
//		default: 						//ERROR!
	endcase
endmodule
