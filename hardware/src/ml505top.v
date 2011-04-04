module ml505top
(

//NEED TO CHANGE CLOCK FREQUENCY

    input        FPGA_SERIAL_RX,
    output       FPGA_SERIAL_TX,
//    input        GPIO_SW_C,
	 input			reset,
    input        USER_CLK

//	output ReadDataM



//    input        PHY_COL,
//    input        PHY_CRS,
//    output       PHY_RESET,
//    input        PHY_RXCLK,
//    input        PHY_RXCTL_RXDV,
//    input  [3:0] PHY_RXD,
//    input        PHY_RXER,
//    input        PHY_TXCLK,
//    output       PHY_TXCTL_TXEN,
//    output [3:0] PHY_TXD,
//    output       PHY_TXER
);
    wire rst;	
	 wire GPIO_SW_C;  //FOR NOW, rst replaced with reset in our added code

    reg [3:0]  reset_r;
    reg [25:0] count_r;

    wire [3:0]  next_reset_r;
    wire [25:0] next_count_r;

    wire user_clk_g;

    wire cpu_clk;
    wire cpu_clk_g;

    wire pll_lock;
    wire ctrl_lock;

    PLL_BASE
    #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT(30),
        .CLKFBOUT_PHASE(0.0),
        .CLKIN_PERIOD(10.0),

        .CLKOUT0_DIVIDE(6),
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT0_PHASE(0.0),

        .CLKOUT1_DIVIDE(6),
        .CLKOUT1_DUTY_CYCLE(0.5),
        .CLKOUT1_PHASE(0.0),

        .CLKOUT2_DIVIDE(6),
        .CLKOUT2_DUTY_CYCLE(0.5),
        .CLKOUT2_PHASE(0.0),

        .CLKOUT3_DIVIDE(6),
        .CLKOUT3_DUTY_CYCLE(0.5),
        .CLKOUT3_PHASE(0.0),

        .CLKOUT4_DIVIDE(6),
        .CLKOUT4_DUTY_CYCLE(0.5),
        .CLKOUT4_PHASE(0.0),

        .CLKOUT5_DIVIDE(6),
        .CLKOUT5_DUTY_CYCLE(0.5),
        .CLKOUT5_PHASE(0.0),

        .COMPENSATION("SYSTEM_SYNCHRONOUS"),
        .DIVCLK_DIVIDE(5),
        .REF_JITTER(0.100)
    )
    user_clk_pll
    (
        .CLKFBOUT(pll_fb),
        .CLKOUT0(cpu_clk),
        .CLKOUT1(),
        .CLKOUT2(),
        .CLKOUT3(),
        .CLKOUT4(),
        .CLKOUT5(),
        .LOCKED(pll_lock),
        .CLKFBIN(pll_fb),
        .CLKIN(user_clk_g),
        .RST(1'b0)
    );

    IBUFG user_clk_buf
    (
        .I(USER_CLK),
        .O(user_clk_g)
    );

    BUFG cpu_clk_buf
    (
        .I(cpu_clk),
        .O(cpu_clk_g)
    );
  
    IDELAYCTRL delay_ctrl
    (
        .RDY(ctrl_lock),
        .REFCLK(cpu_clk_g), 
        .RST(~pll_lock)
    );


//CODE STARTS HERE!!!!!!!!!!!!!!!!!!

	wire [31:0] PCI;
	wire [3:0] MaskM;
	wire [31:0] ALUOutM;
	wire [31:0] WriteDataM;
	wire [31:0] InstrI;
	reg [31:0] ReadDataM;
	wire [31:0] ReadData;

	instr_blk_ram imem(
		.clka(cpu_clk_g),
		.ena(!reset), //crude way to "reset" ram
		.wea(4'b0), //no writing to instruction memory
		.addra(PCI[11:0]),
		.dina(32'b0),
		.douta(InstrI));

	blk_mem_gen_v4_3 dmem(
		.clka(cpu_clk_g),
		.ena(!reset), //crude way to "reset" ram
		.wea(MaskM),
		.addra(ALUOutM[11:0]), //TODO
		.dina(WriteDataM),
		.douta(ReadData));

	mips proc(
		.clk(cpu_clk_g),
		.reset(reset),
		.InstrI(InstrI),
		.ReadDataM(ReadDataM),
		.PCI(PCI),
		.MaskM(MaskM),
		.ALUOutM(ALUOutM),
		.WriteDataM(WriteDataM));
		

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq     =             50000000;  // 100 MHz
  parameter   UARTBaudRate  =             115200;     // 115.2 KBaud

  //----------------------------------------------------------------------------


	wire UARTDataOutValid, UARTDataInReady;
	wire [7:0] UARTDataOut;
	reg [7:0] UARTDataIn;
	reg UARTDataInValid, UARTDataOutReady;
		
	UART #(	.ClockFreq(	ClockFreq),
				.BaudRate(	UARTBaudRate))
		uart(		.Clock(	cpu_clk_g),
				.Reset(		rst),
				.DataIn(	UARTDataIn),
				.DataInValid(	UARTDataInValid),
				.DataInReady(	UARTDataInReady),
				.DataOut(	UARTDataOut),
				.DataOutValid(	UARTDataOutValid),
				.DataOutReady(	UARTDataOutReady),
				.SIn(		FPGA_SERIAL_RX),
				.SOut(		FPGA_SERIAL_TX));
		
always@(*) begin

//What to do if UARTDataOutValid == 0 (UARTDataInReady == 0)

if(ALUOutM[31:16] == 16'hFFFF) begin
	case(ALUOutM[3:0])
		4'h0: ReadDataM = {31'bx, UARTDataOutValid};
		4'h4: begin
					UARTDataOutReady = 1'b1;
					if (UARTDataOutValid) ReadDataM[31:0] = {24'b0, UARTDataOut};
					else ReadDataM[7:0] = 8'b0; //UNSPECIFIED BEHAVIOR
		end
		4'h8: ReadDataM = {31'bx, UARTDataInReady};
		4'hC: begin
					if ((MaskM != 0) & UARTDataInReady) UARTDataIn = WriteDataM[7:0];
					else UARTDataIn = 8'b0; //UNSPECIFIED BEHAVIOR
					UARTDataInValid = 1'b1;
		end
		default: begin
				$display("not using UART @ %t: ALU out sends %h", $time, ALUOutM);
				ReadDataM = ReadData;  //default: assume we're not using the uart..
				UARTDataOutReady = 1'b0;
				UARTDataInValid = 1'b0;
				UARTDataIn = 0;
		end
	endcase
end
else begin
	ReadDataM = ReadData; 
	UARTDataOutReady = 1'b0;
	UARTDataInValid = 1'b0;
	UARTDataIn = 0;
end

end


//CODE ENDS HERE!!!!!!!!!!!!!!!

    always @(posedge cpu_clk_g)
    begin
        reset_r <= next_reset_r;
        count_r <= next_count_r;
    end

    assign next_reset_r = {reset_r[2:0], GPIO_SW_C};

    assign rst = (count_r == 26'b1) | ~pll_lock | ~ctrl_lock;

    assign next_count_r
        = (count_r == 26'b0) ? (reset_r[3] ? 26'b1 : 26'b0)
        :                      count_r + 1;

endmodule
