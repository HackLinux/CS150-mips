module maindec(	input [5:0] 	op
		output		JumpI, 
		output		JALValM, JALDstM, 
		output [1:0]	PCBranchAddrE,
		output		RegWriteM, 
		output		SignOrZeroE,
		output		RegDstE, RegValE,
		output [1:0]	ALUSrcE, 
		output 		ComparatorSrcE,
		output		MemWriteM,
		output		MemToRegM,
		output [1:0]	ALUOp,
		output [1:0]	ComparatorOp);

reg [8:0] controls;

//assume SignOrZeroE == 0 is zero-extend

//necessary to attach suffix to control signal designation?

assign { JumpI, JALValM, JALDstM, RegWriteM, SignOrZeroE, RegDstE, ALUSrcE, ComparatorSrcE, RegValE, PCBranchAddrE, MemWriteM, MemToRegM, ALUop, ComparatorOp} = controls;

always @ (*)
	case(op)
		6'b000000: controls <= 16'b11111100X101001010; //R-type

		6'b: controls <= 14'bXXXXXXXXXXXXXXXX; //
		default:   controls <= 16'bxxxxxxxxxxxxxxxxxx; //???
	endcase
endmodule


module maindec(	input [5:0] 	op
		output		memtoreg, memwrite,
		output		branch, alusrc,
		output		regdst, regwrite,
		output		jump,
		output [1:0]	aluop);

reg [8:0] controls;

assign { regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} = controls;

always @ (*)
	case(op)
		6'b000000: controls <= 9'b110000010; //R-type
		6'b100011: controls <= 9'b101001000; //LW
		6'b101011: controls <= 9'b001010000; //SW
		6'b000100: controls <= 9'b000100001; //BEQ
		6'b001000: controls <= 9'b101000000; //ADDI
		6'b001011: controls <= 9'b101000011; //SLTI
		6'b000010: controls <= 9'b000000100; //J
		default:   controls <= 9'bxxxxxxxxx; //???
	endcase
endmodule
