module controller(	input  [5:0]	Op, Funct,
                  	input        	ZeroE,
			output		JALValE, JALDstE, 
			output [1:0]	PCBranchAddrE,
			output		RegWriteE, 
			output		SignOrZeroE,
			output		RegDstE,
			output [1:0]	ALUSrcE, 
			output		MemToRegE,
			output [3:0]	ALUControlE,
			output [1:0]	MaskControlE,
			output [1:0]	LBLHEnableE);

	wire [1:0] ALUOp;
	wire [3:0] MaskOp;
	wire [3:0] ALUControlSig;
	assign ALUControlE = ALUControlSig;


	maindec mnd(Op, Funct, JALValE, JALDstE, PCBranchAddrE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, MemToRegE, ALUOp, MaskOp);
	aludec  ad(Funct, Op, ALUOp, ALUControlSig);
	maskdec mkd(MaskOp, MaskControlE, LBLHEnableE);

  	

endmodule
