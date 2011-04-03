module controller(	input  [5:0]	Op, Funct,
                  	input        	ZeroE,
			output		JALValM, JALDstM, 
			output [1:0]	PCBranchAddrE,
			output		RegWriteM, 
			output		SignOrZeroE,
			output		RegDstE,
			output [1:0]	ALUSrcE, 
			output		MemToRegM,
			output [3:0]	ALUControlE,
			output [1:0]	MaskControlE,
			output [1:0]	LBLHEnableM
			output       	JumpM);

	wire [1:0] aluop;
	wire [3:0] maskop;

assign {JumpM, JALValM, JALDstM, RegWriteM, 
	SignOrZeroE, RegDstE, ALUSrcE, 
	RegValE, PCBranchAddrE, MemToRegM, 
	ALUop, MaskOp} = controls;


	maindec mnd(Op, Funct, JALValM, JALDstM, PCBranchAddrE, RegWriteM, SignOrZeroE, RegDstE, ALUSrcE, MemToRegM, ALUOp, MaskOp);
	aludec  ad(Funct, ALUOp, ALUControlE);
	maskdec mkd(MaskOp, MaskControlE, LBLHEnableM);

  	assign JumpM = ALUControlE[3] & ZeroE;

endmodule
