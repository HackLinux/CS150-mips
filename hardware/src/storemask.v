module storemask(input [1:0] alubits, //bottom two bits
		input [5:0] op, //opcode
		output [3:0] mask);

always@(*)
	case(op)
		6'b101011: mask <= 4'b1111; //sw mask is all on
		6'b101001: mask <= (alubits[1] ? 4'b1100 : 4'b0011); //sh
		6'b101000: case(alubits) //sb
			2'b00: mask <= 4'b0001;
			2'b01: mask <= 4'b0010;
			2'b10: mask <= 4'b0100;
			2'b11: mask <= 4'b1000;
		endcase
		default: mask <= 4'b0000; //default no writes..
	endcase
endmodule
