module controller(	input  [5:0]	Op, Funct,
                  	input        	ZeroE,
			output		JALValE, JALDstE, 
			output [1:0]	PCBranchAddrE,
			output		RegWriteE, 
			output		SignOrZeroE,
			output		RegDstE, RegValE,
			output [1:0]	ALUSrcE, 
			output		MemToRegE,
			output [3:0]	ALUControlE,
			output [1:0]	MaskControlE,
			output [1:0]	LBLHEnableE,
			output       	JumpE);

	wire [1:0] aluop;
	wire [3:0] maskop;

//assign {JumpE, JALValE, JALDstE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, RegValE, PCBranchAddrE, MemToRegE, ALUop, MaskOp} = controls;


	maindec mnd(Op, Funct, JALValE, JALDstE, PCBranchAddrE, RegWriteE, SignOrZeroE, RegDstE, RegValE, ALUSrcE, MemToRegE, ALUOp, MaskOp);
	aludec  ad(Funct, Op, ALUOp, ALUControlE);
	maskdec mkd(MaskOp, MaskControlE, LBLHEnableE);

  	assign JumpE = ALUControlE[3] & ZeroE;

endmodule
