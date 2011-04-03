module datapath(	input		clk, reset,
			input		JALValE, JALDstE, 
			input [1:0]	PCBranchAddrE,
			input		RegWriteE, 
			input		SignOrZeroE,
			input		RegDstE, RegValE,
			input [1:0]	ALUSrcE, 
			input		MemToRegE,
			input [3:0]	ALUControlE,
			input       	JumpE,
			input [1:0]	MaskControlE,
			input [1:0]	LBLHEnableE,
			output [31:0] 	PCI,
			input  [31:0] 	InstrI,
			output [3:0] MaskM,
			output [31:0] 	ALUOutMOut, WriteDataM,
			input  [31:0] 	ReadDataM,
			input		ForwardAE,
			input		ForwardBE,
			output 		RsE,
			output		RtE,
			output		WriteRegMOut);

//outputs ALUOutM, WriteDataM

  wire [4:0]  WriteRegM; //wire connecting FF output to module output
  assign WriteRegMOut = WriteRegM;

  wire ALUOutM; //wire connecting FF output to module output
  assign ALUOutMOut = ALUOutM;

  wire [31:0] PCNextI, PCPlus4I, PCBranchE, PCBranchM;
  wire [31:0] SignImmE, SignImmSh;
  wire [31:0] srca, srcb;
  wire [31:0] result;
  wire [31:0] PCIOut; 

  wire [31:0] RSValE, PCBranchCompE, A3, WD3, RSValE, RTValE, WriteRegE, SrcBMuxE, ImmSh;
  wire [27:0] JumpSh;
  wire [4:0] WriteRegMuxE;

  wire [31:0] SrcA, SrcB, ALUOutE;


 	assign RsE = InstrI[25:21];
 	assign RtE = InstrI[20:16];

  // next PC logic
  assign PCI = PCIOut;
  flopr #(32) pcreg(clk, reset, PCNextI, PCIOut);
  adder       pcadd1(PCI, 32'b0100, PCPlus4I);
	//PC Branch Datapath (Lowest Path)
  		//PCBranch mux: 01
  	signext     	se(InstrE[15:0], SignOrZeroE, SignImmE);
  	sl2         	immsh(SignImmE, SignImmSh);
  	adder       	pcadd2(PCPlus4E, SignImmSh, PCBranchCompE);
		//PCBranch mux: 11
  	sl2		jsh(instr[25:0], JumpSh);
  	mux4 		pcbrmux(RSValE, PCBranchCompE, PCPlus4E, {Instr[31:28], JumpSh, 2'b00}, PCBranchAddrE, PCBranchE);
		//PCNextI mux
  	mux2 		pcmux(PCPlus4I, PCBranchM, JumpM, PCNextI);

//How to implement pipeline register?
//pflopr(input: InstrI, PCPlus4I; output: InstrE, PCPlus4E)

  // register file logic
  regfile     rf(clk, RegWriteM, instr[25:21], instr[20:16], A3, WD3, RSValE, RTValE);
	//Register File Datapath (Middle Path)
		//Left Mux
	mux2 #(5)   wrmux(InstrE[20:16], InstrE[15:11], RegDstE, WriteRegMuxE);
		//Middle Mux
	mux2	wrvmux({27'b0, WriteRegMuxE}, RTValE, RegValE, WriteRegE); 
		//Far-Right Mux
	mux2    resmux(ALUOutM, MaskDataM, MemToRegM, ResultM);
		//A3 Input Mux
	mux2 #(5)   a3mux(WriteRegM, 5b'11111, JALDestM, A3);
		//WD3 Input Mux
	mux2    wd3mux(ResultM, PCPlus4E, JALValM, WD3);
  // ALU logic
	//ALUSrc mux: 10
	sl16	luish(InstrE[15:0], ImmSh);
	//ALUSrcE mux
	mux4	srcbmux(RTValE, SignImm, ImmSh, {27'b0, InstrE[10:6]}, ALUSrcE, SrcBMuxE);
	//SrcA mux 
	mux2	srcahazmux(RSValE, ResultM, ForwardAE, SrcA);
	//SrcB mux
	mux2	srcbhazmux(RTValE, ResultM, ForwardBE, SrcB);
	//ALU
	alu	alu(SrcA, SrcB, ALUControlE, ALUOutE, ZeroE);

  // Mask logic
	//writemask
	writemask writemask(MaskControlE, ALUOutE, WriteDataE, MaskE, WriteDataE);
	//maskapply
	maskapply maskapply(ReadDataM, LBLHEnableM, MaskDataM);

//pipeline register
	flopr #(15) XMsave(clk, 
							reset,
							{MaskE, ALUOutE, WriteDataE, 
								WriteRegE, PCBranchE, RegWriteE, 
								MemToRegE, LBLHEnableE, JALValE, JALDstE, JumpE},
							{MaskM, ALUOutM, WriteDataM, 
								WriteRegM, PCBranchM, RegWriteM, 
								MemToRegM, LBLHEnableM, JALValM, JALDstM, JumpM});

	flopr #(2) IXsave(clk, 
							reset,
							{InstrI, PCPlus4I},
							{InstrE, PCPlus4E});

endmodule
