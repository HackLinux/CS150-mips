module alu(	input [31:0] 	a, b,
		input [4:0] 	ALUControlE,
		output reg ZeroE,
		output reg [31:0] 	y);

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
//10000: j/jr/jal/jalr
//10001-11001:	//needed?
//11010:beq
//11011:bne
//11100:bgtz
//11101:bgez
//11110:bltz
//11111:blez
 
always@(*)
	case(ALUControlE)
		5'b00000: y <= a + b;
		5'b00001: y <= a - b;
		5'b00010: y <= a & b;
		5'b00011: y <= !(a | b);
		5'b00100: y <= a | b;
		5'b00101: y <= a ^ b;
//		5'b00110-5'b01000: y <= 0; //UNDEFINED BEHAVIOR
		5'b01001: y <= a << b;
		5'b01010: y <= a >> b;
		5'b01011: y <= a >>> b;
		5'b01110: y <= ( $signed(a) < $signed(b) ? 32'b1 : 32'b0);
		5'b01111: y <= ( a < b ? 32'b1 : 32'b0);
//		5'b10000: ZeroE <= 1;
		5'b10001-5'b11001: $display("Error at time %t: ALUControlE: %b", $time, ALUControlE); //UNDEFINED BEHAVIOR 
		5'b11010: ZeroE <= ( (a == b) ? 1'b1 : 1'b0);
		5'b11011: ZeroE <= ( (a != b) ? 1'b1 : 1'b0);
		5'b11100: ZeroE <= ( a > 0 ? 1'b1 : 1'b0);
		5'b11101: ZeroE <= ( a >= 0 ? 1'b1 : 1'b0);
		5'b11110: ZeroE <= ( a < 0 ? 1'b1 : 1'b0);
		5'b11111: ZeroE <= ( ((a < 0) | (a == 0)) ? 1'b1 : 1'b0);
//		default: $display("Error at time %t: ALUControlE: %b", $time, ALUControlE);	//ERROR!
	endcase

endmodule



