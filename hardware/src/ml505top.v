module ml505top
(
    input        FPGA_SERIAL_RX,
    output       FPGA_SERIAL_TX,
    input        GPIO_SW_C,
    input        USER_CLK,

    input        PHY_COL,
    input        PHY_CRS,
    output       PHY_RESET,
    input        PHY_RXCLK,
    input        PHY_RXCTL_RXDV,
    input  [3:0] PHY_RXD,
    input        PHY_RXER,
    input        PHY_TXCLK,
    output       PHY_TXCTL_TXEN,
    output [3:0] PHY_TXD,
    output       PHY_TXER
);
    wire rst;

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
	wire ReadDataM;
	wire InstrI;
	
	blk_mem_gen_v4_3 imem(
		.clka(cpu_clk_g),
		.ena(1'b1),
		.wea(4'b0), //no writing to instruction memory
		.addra(PCI[11:0]),
		.dina(32'b0),
		.douta(InstrI));

	blk_mem_gen_v4_3 dmem(
		.clka(cpu_clk_g),
		.ena(1'b1),
		.wea(MaskM),
		.addra(ALUOutM[11:0]),
		.dina(WriteDataM),
		.douta(ReadDataM));

	mips proc(
		.clk(cpu_clk_g),
		.reset(GPIO_SW_C),
		.InstrI(InstrI),
		.ReadDataM(ReadDataM),
		.PCI(PCI),
		.MaskM(MaskM),
		.ALUoutM(ALUoutM),
		.WriteDataM(WriteDataM));




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
