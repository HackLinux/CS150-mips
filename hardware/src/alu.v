module alu(	input [31:0] 	a, b,
		input [4:0] 	ALUControlE,
		output 		ZeroE,
		output [31:0] 	y);

//Correct use of less than or equal to (i.e. not interpreted as non-blocking)

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
//10000-11001:	//needed?
//11010:beq
//11011:bne
//11100:bgtz
//11101:bgez
//11110:bltz
//11111:blez
 
always@(*)
	case(alucontrol)
		5'b00000: y <= a + b;
		5'b00001: y <= a - b;
		5'b00010: y <= a & b;
		5'b00011: y <= !(a | b);
		5'b00100: y <= a | b;
		5'b00101: y <= a ^ b;
		5'b00110: y <= b;
		5'b00111: y <= a;
//		5'b01000: y <= signed(a) + signed(b)
		5'b01001: y <= a << b;
		5'b01010: y <= a >> b;
		5'b01011: y <= a >>> b;
		5'b01110: y <= ( signed(a) < signed(b) ? 32'b1 : 32'b0);
		5'b01111: y <= ( a < b ? 32'b1 : 32'b0);
//		5'b10000-5'b11001:
		5'b11010: y <= ( (a == b) ? ZeroE = 1'b1 : ZeroE = 1'b0);
		5'b11011: y <= ( (a != b) ? ZeroE = 1'b1 : ZeroE = 1'b0);
		5'b11100: y <= ( a > 0 ? ZeroE = 1'b1 : ZeroE = 1'b0);
		5'b11101: y <= ( a >= 0 ? ZeroE = 1'b1 : ZeroE = 1'b0);
		5'b11110: y <= ( a < 0 ? ZeroE = 1'b1 : ZeroE = 1'b0);
		5'b11111: y <= ( a <= 0 ? ZeroE = 1'b1 : ZeroE = 1'b0);
		default: 							//ERROR!
	endcase
endmodule



