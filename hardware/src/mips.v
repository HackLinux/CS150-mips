module mips(input         clk, reset,
            output [31:0] PCI,
            input  [31:0] InstrE,
            output        MaskControlE,
            output [31:0] ALUoutE, RTValE,
            input  [31:0] MaskDataM);


//	wire		JALValM, JALDstM, RegWriteM, SignOrZeroE, RegDstE, RegValE, MemToRegM, JumpM;
//	wire [1:0]	ALUSrcE, MaskControlE, LBLHEnableM, PCBranchAddrE;
//	wire [3:0]	ALUControlE;

controller	c(	InstrE[31:26], InstrE[5:0], ZeroE, JALValM, JALDstM, PCBranchAddrE, RegWriteM, SignOrZeroE, RegDstE, RegValE, ALUSrcE, MemToRegM, ALUControlE, MaskControlE, LBLHEnableM, JumpM);

//datapath call not complete
datapath 	dp(	clk, reset, JALValM, JALDstM, PCBranchAddrE, RegWriteM, SignOrZeroE, RegDstE, RegValE, ALUSrcE, MemToRegM, ALUControlE, JumpM

//hazard		h(	

//add other modules, e.g. mask, here?  If so, must change input/output at top

endmodule
