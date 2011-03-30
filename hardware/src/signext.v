module signext(input [15:0] a,
		input SignOrZeroE,
		output [31:0] y);

	assign y = (SignOrZeroE ? {{16{a[15]}}, a} : {16'b0, a} );
endmodule
