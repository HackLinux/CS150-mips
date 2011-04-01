module aludec(	input [5:0] 	Funct,
              	input [1:0] 	ALUOp,
		input 		SixteenthBit,
              	output reg [4:0] ALUControlE);

//00000:addu
//00001:subu
//00010:and
//00011:nor
//00100:or
//00101:xor
//00110:pass B 	//needed?
//00111:pass A 	//needed?
//01000:add	//needed?
//01001:sll  	
//01010:srl
//01011:sra
//01110:slt
//01111:sltu
//10000-10111:	//needed?
//11000:?
//11001:?
//11010:beq
//11011:bne
//11100:bgtz
//11101:bgez
//11110:bltz
//11111:blez

  always @(*)
	case(ALUOp)
		2'b00: ALUControlE <= 5'b00000;  // addu
	      	2'b01: ALUControlE <= 5'b00001;  // subu
		2'b10: case(Op)			// branching
			//How to distinguish between BGEZ/BLTZ?
			6'b000001: case(SixteenthBit)
				1'b0: ALUControlE <= 5'11110; //BLTZ
				1'b1: ALUControlE <= 5'11101; //BGEZ
			endcase
			6'b000100: ALUControlE <= 5'11010; //BEQ
			6'b000101: ALUControlE <= 5'11011; //BNE
			6'b000111: ALUControlE <= 5'11100; //BGTZ
			6'b000110: ALUControlE <= 5'11111; //BLEZ
			default: 					//ERROR!
		endcase
	      	2'b11: case(Funct)          // RTYPE
			6'b000000: ALUControlE <= 5'01001; //SLL
			6'b000010: ALUControlE <= 5'01010; //SRL
			6'b000011: ALUControlE <= 5'01011; //SRA
			6'b000100: ALUControlE <= 5'01001; //SLLV
			6'b000110: ALUControlE <= 5'01010; //SRLV
			6'b000111: ALUControlE <= 5'01011; //SRAV
			6'b100001: ALUControlE <= 5'00000; //ADDU
			6'b100011: ALUControlE <= 5'00001; //SUBU
			6'b100100: ALUControlE <= 5'00010; //AND
			6'b100101: ALUControlE <= 5'00100; //OR
			6'b100110: ALUControlE <= 5'00101; //XOR
			6'b100111: ALUControlE <= 5'00011; //NOR
			6'b101010: ALUControlE <= 5'01110; //SLT
			6'b101011: ALUControlE <= 5'01111; //SLTU
			default: 					//ERROR!
		default: 						//ERROR!
		endcase
	endcase
endmodule
