module alu(	input [31:0] a, b,
		input [3:0] alucontrol,
		output [31:0] y);

//Correct use of less than or equal to (i.e. not interpreted as non-blocking)

//0000:addu
//0001:subu
//0010:sll
//0011:srl
//0100:sra
//0101:or
//0110:xor
//0111:		//pass B? (sltu)
//1000:		//pass A? (bne)
//1001:		//pass? (beq)
//1010:and	
//1011:nor	
//1100:bgtz	
//1101:bgez	
//1110:bltz	(slt)
//1111:blez	


always@(*)
	case(alucontrol)
		4'b0000: y <= a + b;
		4'b0001: y <= a - b;
		4'b0010: y <= a << b;
		4'b0011: y <= a >> b;
		4'b0100: y <= a >>> b;
		4'b0101: y <= a | b;
		4'b0110: y <= a ^ b;
//		4'b0111: y <= b;
//		4'b1000: y <= a;
		4'b1001: ?
//		4'b1010: y <= a & b;
		4'b1011: y <= !(a | b);
		4'b1100: y <= ( a > b ? 32'b1 : 32'b0);
		4'b1101: y <= ( a >= b ? 32'b1 : 32'b0);
		4'b1110: y <= ( a < b ? 32'b1 : 32'b0 );
		4'b1111: y <= ( a <= b ? 32'b1 : 32'b0);

	endcase
endmodule


