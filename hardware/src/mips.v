module mips(input         clk, reset,
            input  [31:0] InstrI,
            input  [31:0] ReadDataM,
            output [31:0] PCI,
				output [3:0] MaskM,
            output [31:0] ALUOutM, WriteDataM);



	wire		JALValE, JALDstE, RegWriteE, SignOrZeroE, RegDstE, MemToRegE;
	wire [1:0]	ALUSrcE, MaskControlE, LBLHEnableE, PCBranchAddrE;
	wire [3:0]	ALUControlE;
	wire		RsE, RtE, WriteRegM, ForwardAE, ForwardBE;
	wire [31:0] ALUOutMOut, InstrE;

	assign ALUOutM = ALUOutMOut;

controller	ctrl(	InstrE[31:26], InstrE[5:0], JALValE, JALDstE, PCBranchAddrE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, MemToRegE, ALUControlE, MaskControlE, LBLHEnableE);

datapath 	dpath(	clk, reset, JALValE, JALDstE, PCBranchAddrE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, MemToRegE, ALUControlE, MaskControlE, LBLHEnableE, PCI, InstrI, InstrE, MaskM, ALUOutMOut, WriteDataM, ReadDataM, ForwardAE, ForwardBE, RsE, RtE, WriteRegM);

hazard	h(	RsE, RtE, RegWriteE, WriteRegM, ForwardAE, ForwardBE);

endmodule
