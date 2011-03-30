module masker(input [1:0] ALUOutBits,
		input [31:0] WriteData,
		input [5:0] op,
		output [3:0] mask,
		output [31:0] WriteData);


always@(*)
	case(op)
		6'b101011: mask <= 4'b1111; //sw mask is all on
		6'b101001: 
				begin
					mask <= (alubits[1] ? 4'b1100 : 4'b0011); //sh
					WriteData = {{WriteData[15:0]}, {WriteData[15:0]}};
				end
		6'b101000: 
				begin
					case(alubits) //sb
						2'b00: mask <= 4'b0001;
						2'b01: mask <= 4'b0010;
						2'b10: mask <= 4'b0100;
						2'b11: mask <= 4'b1000;
					endcase
				WriteData = {{WriteData[7:0]}, {WriteData[7:0]}, {WriteData[7:0]}, {WriteData[7:0]}};
		default: mask <= 4'b0000; //default no writes..
	endcase
endmodule
