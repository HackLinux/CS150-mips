module maindec(	input [5:0] Op,
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
		output [3:0]	MaskOp);

reg [17:0] controls;

assign {JumpM, JALValM, JALDstM, RegWriteM, 
	SignOrZeroE, RegDstE, ALUSrcE, 
	RegValE, PCBranchAddrE, MemToRegM, 
	ALUOp, MaskOp} = controls;

//assume SignOrZeroE == 0 is zero-extend


always @ (*)
	case(Op)
		6'b000001: controls <= 18'b1XXX1X00X010100000; //BLTZ,BGEZ
		6'b000010: controls <= 18'b1XXXXXXXX11XXX0000; //J
		6'b000011: controls <= 18'b111XXXXXX11XXX0000; //JAL
		6'b000100: controls <= 18'b1XXX1X00X010100000; //BEQ
		6'b000101: controls <= 18'b1XXX1X00X010100000; //BNE
		6'b000110: controls <= 18'b1XXX1X00X010100000; //BLEZ
		6'b000111: controls <= 18'b1XXX1X00X010100000; //BGTZ
		6'b001001: controls <= 18'b000110010XX0000000; //ADDIU
		6'b001010: controls <= 18'b000110010XX0110000; //SLTI
		6'b001011: controls <= 18'b000110010XX0110000; //SLTIU
		6'b001100: controls <= 18'b000100010XX0110000; //ANDI
		6'b001101: controls <= 18'b000100010XX0110000; //ORI
		6'b001110: controls <= 18'b000100010XX0110000; //XORI
		6'b001111: controls <= 18'b0001X0100XX0110000; //LUI
		6'b100000: controls <= 18'b00011X01XXX1000001; //LB
		6'b100001: controls <= 18'b00011X01XXX1000010; //LH
		6'b100011: controls <= 18'b00011X01XXX1000011; //LW
		6'b100100: controls <= 18'b00011X01XXX1000100; //LBU
		6'b100101: controls <= 18'b00011X01XXX1000101; //LHU
		6'b101000: controls <= 18'b00000X01XXX0000110; //SB
		6'b101001: controls <= 18'b00000X01XXX0000111; //SH
		6'b101011: controls <= 18'b00000X01XXX0001000; //SW
		default:   case(Funct) 
			6'b000000: controls <= 18'b000111110XX0110000; //SLL
			6'b000010: controls <= 18'b000111110XX0110000; //SRL
			6'b000011: controls <= 18'b000111110XX0110000; //SRA
			6'b001000: controls <= 18'b1XXXXXXXX00XXX0000; //JR
			6'b001001: controls <= 18'b110XXXXX100XXX0000; //JALR
			default:   controls <= 18'b000111000XX0110000; //All Other R-type
		endcase
	endcase
endmodule
