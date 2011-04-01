module aludec(input      [5:0] Funct,
              input      [1:0] ALUOp,
              output reg [5:0] ALUControlE);

//0000:addu
//0001:subu
//0010:sll
//0011:srl
//0100:sra
//0101:or
//0110:xor
//0111:		//pass B?
//1000:		//pass A?
//1001:		//pass?
//1010:and	(beq)
//1011:nor	(bne)
//1100:bgtz	
//1101:bgez	
//1110:bltz	(slt)
//1111:blez	(sltu)

  always @(*)
	case(ALUOp)
		2'b00: ALUControlE <= 5'b00010;  // addu
	      	2'b01: ALUControlE <= 5'b110;  // subu
	      	default: case(Funct)          // RTYPE
			6'b000000: ALUControlE <= 5'; //SLL
			6'b000010: ALUControlE <= 5'; //SRL
			6'b000011: ALUControlE <= 5'; //SRA
			6'b000100: ALUControlE <= 5'; //SLLV
			6'b000110: ALUControlE <= 5'; //SRLV
			6'b000111: ALUControlE <= 5'; //SRAV
			6'b100001: ALUControlE <= 5'; //ADDU
			6'b100011: ALUControlE <= 5'; //SUBU
			6'b100100: ALUControlE <= 5'; //AND
			6'b100101: ALUControlE <= 5'; //OR
			6'b100110: ALUControlE <= 5'; //XOR
			6'b100111: ALUControlE <= 5'; //NOR
			6'b101010: ALUControlE <= 5'; //SLT
			6'b101011: ALUControlE <= 5'; //SLTU
		endcase
	endcase
endmodule
