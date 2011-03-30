module maskapply(input [31:0] rd,
						input [2:0] MaskControlM,
						output [31:0] rdToMux);


always@(*)
	case
		3'b101: rdToMux = {{24{rd[7]}}, {rd[7:0]}};
		3'b110: rdToMux = {{16{rd[15]}}, {rd[15:0]}};
		default: rdToMux = rd;
	endcase

endmodule
