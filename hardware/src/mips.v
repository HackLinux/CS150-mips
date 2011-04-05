module mips(	input         clk, reset,
		input  [31:0] InstrI,
		input  [31:0] ReadDataM,
		output [31:0] PCI,
		output [3:0]  MaskM,
		output [31:0] ALUOutM, WriteDataM);

//ZeroE

	wire	[4:0] WriteRegM, RsE, RtE;
	wire		ZeroE, JALValE, JALDstE, RegWriteE, SignOrZeroE, RegDstE, MemToRegE, JumpE;
	wire [1:0]	PCBranchAddrE, ALUSrcE, MaskControlE, LBLHEnableE;
	wire [4:0]	ALUControlE;
	wire		ForwardAE, ForwardBE;
	wire [31:0] 	InstrE;

	controller	ctrl(	InstrE[31:26], InstrE[5:0], InstrE[16], ZeroE, JALValE, JALDstE, PCBranchAddrE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, MemToRegE, ALUControlE, MaskControlE, LBLHEnableE, JumpE);

	datapath 	dpath(	clk, reset, JumpE, JALValE, JALDstE, PCBranchAddrE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, MemToRegE, ALUControlE, MaskControlE, LBLHEnableE, PCI, InstrI, InstrE, ZeroE, MaskM, ALUOutM, WriteDataM, ReadDataM, ForwardAE, ForwardBE, RsE, RtE, WriteRegM, RegWriteM);

	hazard		h(	RsE, RtE, WriteRegM, RegWriteM, ForwardAE, ForwardBE);

endmodule
