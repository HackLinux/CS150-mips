module mips(input         clk, reset,
            input  [31:0] InstrI,
            input  [31:0] ReadDataM
            output [31:0] PCI,
            output [31:0] MaskM, ALUoutM, WriteDataM);



	wire		JALValM, JALDstM, RegWriteM, SignOrZeroE, RegDstE, RegValE, MemToRegM, JumpM;
	wire [1:0]	ALUSrcE, MaskControlE, LBLHEnableM, PCBranchAddrE;
	wire [3:0]	ALUControlE;
	wire		RsE, RtE, WriteRegM, ForwardAE, ForwardBE, WriteRegM;

controller	c(	InstrE[31:26], InstrE[5:0], ZeroE, JALValM, JALDstM, PCBranchAddrE, RegWriteM, SignOrZeroE, RegDstE, RegValE, ALUSrcE, MemToRegM, ALUControlE, MaskControlE, LBLHEnableM, JumpM);

datapath 	dp(	clk, reset, JALValM, JALDstM, PCBranchAddrE, RegWriteM, SignOrZeroE, RegDstE, RegValE, ALUSrcE, MemToRegM, ALUControlE, JumpM, MaskControlE, LBLHEnableM, PCI, InstrI, MaskM, ALUOutM, WriteDataM, ReadDataM, ForwardAE, ForwardBE, RsE, RtE, RegWriteM, WriteRegM);

hazard	h(	RsE, RtE, RegWriteM, WriteRegM, ForwardAE, ForwardBE);

endmodule
