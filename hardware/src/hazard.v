module hazard(	input 		RsE,
		input		RtE,
		input		WriteRegM,
		input		RegWriteM,
		output		ForwardAE,
		output		ForwardBE);

	assign ForwardAE = (RsE != 0) & (RsE == WriteRegM) & RegWriteM;
	assign ForwardBE = (RtE != 0) & (RtE == WriteRegM) & RegWriteM;

endmodule
