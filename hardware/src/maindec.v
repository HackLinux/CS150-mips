module maindec(	input [5:0] 	Op,
		input [5:0] 	Funct,
		output		JALValE, JALDstE, 
		output [1:0]	PCBranchAddrE,
		output		RegWriteE, 
		output		SignOrZeroE,
		output		RegDstE,
		output [1:0]	ALUSrcE, 
		output		MemToRegE,
		output [1:0]	ALUOp,
		output [3:0]	MaskOp);

reg [15:0] controls;

assign {JALValE, JALDstE, RegWriteE, SignOrZeroE, RegDstE, ALUSrcE, PCBranchAddrE, MemToRegE, ALUOp, MaskOp} = controls;

//assume SignOrZeroE == 0 is zero-extend

always @ (*)
	case(Op) //						   -----  
		6'b000001: controls <= 16'bXXX1X00010100000; //BLTZ,BGEZ
		6'b000010: controls <= 16'bXXXXXXX11X100000; //J
		6'b000011: controls <= 16'b11XXXXX11X100000; //JAL
		6'b000100: controls <= 16'bXXX1X00010100000; //BEQ
		6'b000101: controls <= 16'bXXX1X00010100000; //BNE
		6'b000110: controls <= 16'bXXX1X00010100000; //BLEZ
		6'b000111: controls <= 16'bXXX1X00010100000; //BGTZ
		6'b001001: controls <= 16'b0011001XX0000000; //ADDIU
		6'b001010: controls <= 16'b0011001XX0110000; //SLTI
		6'b001011: controls <= 16'b0011001XX0110000; //SLTIU
		6'b001100: controls <= 16'b0010001XX0110000; //ANDI
		6'b001101: controls <= 16'b0010001XX0110000; //ORI
		6'b001110: controls <= 16'b0010001XX0110000; //XORI
		6'b001111: controls <= 16'b001X010XX0110000; //LUI
		6'b100000: controls <= 16'b0011X01XX1000001; //LB
		6'b100001: controls <= 16'b0011X01XX1000010; //LH
		6'b100011: controls <= 16'b0011X01XX1000011; //LW
		6'b100100: controls <= 16'b0011X01XX1000100; //LBU
		6'b100101: controls <= 16'b0011X01XX1000101; //LHU
		6'b101000: controls <= 16'b0000X01XX0000110; //SB
		6'b101001: controls <= 16'b0000X01XX0000111; //SH
		6'b101011: controls <= 16'b0000X01XX0001000; //SW
		default:   case(Funct) //		-----
			6'b000000: controls <= 16'b0011111XX0110000; //SLL
			6'b000010: controls <= 16'b0011111XX0110000; //SRL
			6'b000011: controls <= 16'b0011111XX0110000; //SRA
			6'b001000: controls <= 16'bXXXXXXX00X110000; //JR
			6'b001001: controls <= 16'b10XXXXX00X110000; //JALR
			default:   controls <= 16'b0011100XX0110000; //All Other R-type
		endcase
	endcase
endmodule
