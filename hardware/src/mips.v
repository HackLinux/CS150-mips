module mips(input         clk, reset,
            input  [31:0] InstrI,
            input  [31:0] ReadDataM,
            output [31:0] PCI,
				output [3:0] MaskM,
            output [31:0] ALUoutM, WriteDataM);



	wire		JALValE, JALDstE, RegWriteE, SignOrZeroE, RegDstE, RegValE, MemToRegM, JumpE;
	wire [1:0]	ALUSrcE, MaskControlE, LBLHEnableE, PCBranchAddrE;
	wire [3:0]	ALUControlE;
	wire		RsE, RtE, WriteRegM, ForwardAE, ForwardBE;

controller	ctrl(	InstrE[31:26], InstrE[5:0], ZeroE, JALValE, JALDstE, PCBranchAddrE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, MemToRegM, ALUControlE, MaskControlE, LBLHEnableE, JumpE);

datapath 	dpath(	clk, reset, JALValE, JALDstE, PCBranchAddrE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, MemToRegE, ALUControlE, JumpE, MaskControlE, LBLHEnableE, PCI, InstrI, MaskM, ALUOutM, WriteDataM, ReadDataM, ForwardAE, ForwardBE, RsE, RtE, WriteRegM);

hazard	h(	RsE, RtE, RegWriteE, WriteRegM, ForwardAE, ForwardBE);

endmodule
