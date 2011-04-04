module maskapply(	input [31:0] ReadDataM,
			input [1:0] LBLHEnableM,
			output reg [31:0] MaskDataM);

	always@(*)
		case (LBLHEnableM)
			2'b00: MaskDataM <= ReadDataM;
			2'b01: MaskDataM <= {{24{ReadDataM[7]}}, {ReadDataM[7:0]}};
			2'b10: MaskDataM <= {{16{ReadDataM[15]}}, {ReadDataM[15:0]}};
//			default: $display("Error at time %t: LBHLEnableM: %b", $time, LBHLEnableM);	//ERROR!
		endcase

endmodule
