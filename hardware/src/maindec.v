module maindec(	input [5:0] 	Op,
		input [5:0] 	Funct,
		output		JALValM, JALDstM, 
		output [1:0]	PCBranchAddrE,
		output		RegWriteM, 
		output		SignOrZeroE,
		output		RegDstE, RegValE,
		output [1:0]	ALUSrcE, 
		output		MemWriteM,
		output		MemToRegM,
		output [1:0]	ALUOp,
		output [1:0]	MaskOp);

reg [8:0] controls;

assign {JumpM, JALValM, JALDstM, RegWriteM, 
	SignOrZeroE, RegDstE, ALUSrcE, 
	RegValE, PCBranchAddrE, MemToRegM, 
	ALUop, MaskOp} = controls;

//assume SignOrZeroE == 0 is zero-extend

always @ (*)
	case(op)
		6'b000001: controls <= 16'b1XXX1X00X0101000; //BLTZ,BGEZ
		6'b000010: controls <= 16'b1XXXXXXXX11XXX00; //J
		6'b000011: controls <= 16'b111XXXXXX11XXX00; //JAL
		6'b000100: controls <= 16'b1XXX1X00X0101000; //BEQ
		6'b000101: controls <= 16'b1XXX1X00X0101000; //BNE
		6'b000110: controls <= 16'b1XXX1X00X0101000; //BLEZ
		6'b000111: controls <= 16'b1XXX1X00X0101000; //BGTZ
		6'b001001: controls <= 16'b000110010XX00000; //ADDIU
		6'b001010: controls <= 16'b000110010XX01100; //SLTI
		6'b001011: controls <= 16'b000110010XX01100; //SLTIU
		6'b001100: controls <= 16'b000100010XX01100; //ANDI
		6'b001101: controls <= 16'b000100010XX01100; //ORI
		6'b001110: controls <= 16'b000100010XX01100; //XORI
		6'b001111: controls <= 16'b0001X0100XX01100; //LUI
		6'b100000: controls <= 16'b00011X01XXX10001; //LB
		6'b100001: controls <= 16'b00011X01XXX10010; //LH
		6'b100011: controls <= 16'b00011X01XXX100??; //LW
		6'b100100: controls <= 16'b00011X01XXX10001; //LBU
		6'b100101: controls <= 16'b00011X01XXX10010; //LHU
		6'b101000: controls <= 16'b00000X01XXX00001; //SB
		6'b101001: controls <= 16'b00000X01XXX00010; //SH
		6'b101011: controls <= 16'b00000X01XXX000??; //SW
		default:   case(Funct) 
			6'b000000: controls <= 16'b000111110XX01100; //SLL
			6'b000010: controls <= 16'b000111110XX01100; //SRL
			6'b000011: controls <= 16'b000111110XX01100; //SRA
			6'b001000: controls <= 16'b1XXXXXXXX00XXX00; //JR
			6'b001001: controls <= 16'b110XXXXX100XXX00; //JALR
			default:   controls <= 16'b000111000XX01100; //All Other R-type
		endcase
	endcase
endmodule
