module datapath(	input		clk, reset,
			input		JumpE,
			input		JALValE, JALDstE, 
			input [1:0]	PCBranchAddrE,
			input		RegWriteE, 
			input		SignOrZeroE,
			input		RegDstE,
			input [1:0]	ALUSrcE, 
			input		MemToRegE,
			input [4:0]	ALUControlE,
			input [1:0]	MaskControlE,
			input [1:0]	LBLHEnableE,
			output [31:0] 	PCI,
			input  [31:0] 	InstrI,
			output [31:0]   InstrE,
			output 		ZeroE,
			output [3:0] 	MaskM,
			output [31:0] 	ALUOutM, WriteDataM,
			input  [31:0] 	ReadDataM,
			input		ForwardAE,
			input		ForwardBE,
			output [4:0] RsE,
			output [4:0] RtE,
			output [4:0] WriteRegM,
			output		RegWriteM);

  wire [31:0] PCNextI, PCPlus4I, PCPlus4E, PCBranchE, 
					PCBranchM, ResultM, MaskDataM, WriteDataE;
  wire [31:0] SignImmE, SignImmSh;
  wire [31:0] RSValE, PCBranchCompE;
  wire [25:0] JumpSh;
  wire  [4:0]	WriteRegE, WriteRegMWire;
  wire MemToRegM, JALDstM, JALValM;
  wire [3:0] MaskE;
  wire [1:0] LBLHEnableM;

  wire [31:0] WD3, RTValE, SrcBMuxE, ImmSh;
  wire [4:0] A3;
  wire [31:0] SrcA, SrcB, ALUOutE;

	assign RsE = InstrI[25:21];
	assign RtE = InstrI[20:16];
	assign WriteRegM = WriteRegMWire;

	flopr #(32) pcreg(	clk, reset, PCNextI, PCI);


	// next PC logic
	adder pcadd1(	PCI, 32'b0100, PCPlus4I);
			//PC Branch Datapath (Lowest Path)
  		//PCBranch mux: 01
  	signext se(	InstrE[15:0], SignOrZeroE, SignImmE);
  	sl2 immsh(	SignImmE, SignImmSh);
  	adder pcadd2(	PCPlus4E, SignImmSh, PCBranchCompE);
		//PCBranch mux: 11



  	sl2 #(26) jsh(	InstrE[25:0], JumpSh);
  	mux4 pcbrmux(	RSValE, PCBranchCompE, PCPlus4E, {InstrE[31:28], JumpSh, 2'b00}, PCBranchAddrE, PCBranchE);
		//PCNextI mux
  	mux2 pcmux(	PCPlus4I, PCBranchM, JumpM, PCNextI);


	flopr #(64) IXsave(clk, reset, {InstrI, PCPlus4I}, {InstrE, PCPlus4E});


	// register file logic
	regfile regfile(	clk, RegWriteM, InstrE[25:21], InstrE[20:16], A3, WD3, RSValE, RTValE);
			//Register File Datapath (Middle Path)
		//Left Mux
	mux2 #(5) wrmux(InstrE[20:16], InstrE[15:11], RegDstE, WriteRegE);
		//Far-Right Mux
	mux2 resmux(	ALUOutM, MaskDataM, MemToRegM, ResultM);
		//A3 Input Mux
	mux2 #(5) a3mux(WriteRegMWire, 5'b11111, JALDstM, A3);
		//WD3 Input Mux
	mux2 wd3mux(	ResultM, PCPlus4E, JALValM, WD3);
  	// ALU logic
		//ALUSrc mux: 10
	assign ImmSh = {InstrE[15:0], 16'b0};
		//ALUSrcE mux
	mux4 srcbmux(RTValE, SignImmE, ImmSh, {27'b0, InstrE[10:6]}, ALUSrcE, SrcBMuxE);
		//SrcA mux
	mux2 srcahazmux(RSValE, ResultM, ForwardAE, SrcA);
		//SrcB mux
	mux2 srcbhazmux(SrcBMuxE, ResultM, ForwardBE, SrcB);
		//ALU
	alu alu(SrcA, SrcB, ALUControlE, ZeroE, ALUOutE);

	// Mask logic
		//writemask
	writemask writemask(ALUOutE, RTValE, MaskControlE, MaskE, WriteDataE);
		//maskapply
	maskapply maskapply(ReadDataM, LBLHEnableM, MaskDataM);


	flopr #(112) XMsave(clk, reset, {MaskE, ALUOutE, WriteDataE, WriteRegE, PCBranchE, RegWriteE, MemToRegE, LBLHEnableE, JALValE, JALDstE, JumpE}, {MaskM, ALUOutM, WriteDataM, WriteRegMWire, PCBranchM, RegWriteM, MemToRegM, LBLHEnableM, JALValM, JALDstM, JumpM});


endmodule
