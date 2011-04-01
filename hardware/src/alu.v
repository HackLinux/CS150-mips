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
//0111:		//pass B?
//1000:		//pass A?
//1001:		//pass?
//1010:and	(beq)
//1011:nor	(bne)
//1100:bgtz	
//1101:bgez	
//1110:bltz	(slt)
//1111:blez	(sltu)


always@(*)
	case(alucontrol)
		4'b0000: y <= $unsigned(a) + $unsigned(b);
		4'b0001: y <= $unsigned(a) - $unsigned(b);
		4'b0010: y <= a << b;
		4'b0011: y <= a >> b;
		4'b0100: y <= a >>> b;
		4'b0101: y <= a | b;
		4'b0110: y <= a ^ b;
//		4'b0111: y <= b;
		4'b1000: y <= a;
		4'b1001: ?
//		4'b1010: y <= a & b;
		4'b1011: y <= !(a | b);
		4'b1100: y <= ( $unsigned(a) > $unsigned(b) ? 32'b1 : 32'b0);
		4'b1101: y <= ( $unsigned(a) >= $unsigned(b) ? 32'b1 : 32'b0);
		4'b1110: y <= ( a < b ? 32'b1 : 32'b0 );
		4'b1111: y <= ( $unsigned(a) <= $unsigned(b) ? 32'b1 : 32'b0);

	endcase
endmodule


