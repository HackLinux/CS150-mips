module sl16(input [31:0] a,
		output [31:0] y);

	assign y = {a[15:0], 16'b0000000000000000};
endmodule
