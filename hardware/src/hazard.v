module hazard(	input 		[4:0] RsE,
		input		[4:0] RtE,
		input		[4:0] WriteRegM,
		input		RegWriteM,
		output		ForwardAE,
		output		ForwardBE);

	assign ForwardAE = (RsE != 5'b0) & (RsE == WriteRegM) & RegWriteM;
	assign ForwardBE = (RtE != 5'b0) & (RtE == WriteRegM) & RegWriteM;

endmodule
