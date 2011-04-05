module controller(	input  [5:0]	Op, Funct,
			input		SeventeenthBit,
         input        	ZeroE,
			output		JALValE, JALDstE, 
			output [1:0]	PCBranchAddrE,
			output		RegWriteE, 
			output		SignOrZeroE,
			output		RegDstE,
			output [1:0]	ALUSrcE, 
			output		MemToRegE,
			output [4:0]	ALUControlE,
			output [1:0]	MaskControlE,
			output [1:0]	LBLHEnableE,
			output		JumpE);

	wire [1:0] ALUOp;
	wire [3:0] MaskOp;

	maindec mnd(	Op, Funct, JALValE, JALDstE, PCBranchAddrE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, MemToRegE, ALUOp, MaskOp);
	aludec  ad(	Op, Funct, ALUOp, SeventeenthBit, ALUControlE);
	maskdec mkd(	MaskOp, MaskControlE, LBLHEnableE);

	assign JumpE = ALUControlE[4] & ZeroE;

endmodule
