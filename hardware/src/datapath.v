module datapath(	input		clk, reset,
			input		JALValM, JALDstM, 
			input [1:0]	PCBranchAddrE,
			input		RegWriteM, 
			input		SignOrZeroE,
			input		RegDstE, RegValE,
			input [1:0]	ALUSrcE, 
			input		MemToRegM,
			input [3:0]	ALUControlE,
			input       	JumpM;
	                output [31:0] 	PCI,
        	        input  [31:0] 	InstrI,
                	output [31:0] 	ALUoutE, RTValE,
	                input  [31:0] 	MaskDataM
			input		ForwardAE,
			input		ForwardBE,
			output 		RsE,
			output		RtE,
			output 		RegWriteM,
			output		WriteRegM);

  wire [4:0]  writereg;
  wire [31:0] PCNextI, PCPlus4I, PCBranchE, PCBranchM;
  wire [31:0] SignImmE, SignImmSh;
  wire [31:0] srca, srcb;
  wire [31:0] result;

  wire [31:0] RSValE, PCBranchCompE, A3, WD3, RSValE, RTValE, WriteRegE, SrcBMuxE, ImmSh;
  wire [27:0] JumpSh;
  wire [4:0] WriteRegMuxE;

 	assign RsE = Instr[25:21];
 	assign RtE = Instr[20:16];

  // next PC logic
  flopr #(32) pcreg(clk, reset, PCNextI, PCI);
  adder       pcadd1(PCI, 32'b100, PCPlus4I);
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
	mux2    a3mux(WriteRegM, 32b'11111, JALDestM, A3);
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

//How to implement pipeline register?
//pflopr(input: MaskE, ALUOutE, WriteDataE, WriteRegE, PCBranchE; output: MaskM, ALUOutM, WriteDataM, WriteRegM, PCBranchM)
//also: input: JALValE, JALDestE, RegWriteE, MemToRegE; output: JALValM, JALDestM, RegWriteM, MemToRegM;
endmodule
