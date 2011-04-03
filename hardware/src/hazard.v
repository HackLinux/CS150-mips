module hazard(	input	RsE,
		input 	RtE,
		input 	RegWriteM,
		input	WriteRegM,
		output  ForwardAE,
		output  ForwardBE,);

	if((RsE != 0) & (RsE == WriteRegM) & RegWriteM)
		ForwardAE = 1;
	else
		ForwardAE = 0;
	if ((RtE != 0) & (RtE == WriteRegM) & RegWriteM)
		ForwardBE = 1;
	else
		ForwardBE = 0;

endmodule
