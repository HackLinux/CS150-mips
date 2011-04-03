module EMAC150(
    Clock,
    Reset,

    DataIn,
    DataInValid,
    DataInReady,
    DataInStartFrame,
    DataInEndFrame,

    DataOut,
    DataOutValid,
    DataOutReady,
    DataOutStartFrame,
    DataOutEndFrame,

    MII_COL_0,
    MII_CRS_0,
    MII_TXD_0,
    MII_TX_EN_0,
    MII_TX_ER_0,
    MII_TX_CLK_0,
    MII_RXD_0,
    MII_RX_DV_0,
    MII_RX_ER_0,
    MII_RX_CLK_0
);

input                           Clock;
input                           Reset;

input       [7:0]               DataIn;
input                           DataInValid;
output                          DataInReady;
input                           DataInStartFrame;
input                           DataInEndFrame;

output       [7:0]              DataOut;
output                          DataOutValid;
input                           DataOutReady;
output                          DataOutStartFrame;
output                          DataOutEndFrame;

input                           MII_COL_0;
input                           MII_CRS_0;
output      [3:0]               MII_TXD_0;
output                          MII_TX_EN_0;
output                          MII_TX_ER_0;
input                           MII_TX_CLK_0;
input       [3:0]               MII_RXD_0;
input                           MII_RX_DV_0;
input                           MII_RX_ER_0;
input                           MII_RX_CLK_0;

wire        [7:0]               tx_ll_data_0;
wire                            tx_ll_src_rdy_n_0;
wire                            tx_ll_dst_rdy_n_0;
wire                            tx_ll_sof_n_0;
wire                            tx_ll_eof_n_0;

wire        [7:0]               rx_ll_data_0;
wire                            rx_ll_src_rdy_n_0;
wire                            rx_ll_dst_rdy_n_0;
wire                            rx_ll_sof_n_0;
wire                            rx_ll_eof_n_0;

wire                            EMAC0CLIENTRXDVLD;
wire                            EMAC0CLIENTRXFRAMEDROP;

reg                             mii_tx_clk_0;
reg                             mii_rx_clk_0;

wire                            tx_clk_0;
wire                            rx_clk_0;

assign tx_ll_data_0 = DataIn;
assign tx_ll_src_rdy_n_0 = ~DataInValid;
assign DataInReady = ~tx_ll_dst_rdy_n_0;
assign tx_ll_sof_n_0 = ~DataInStartFrame;
assign tx_ll_eof_n_0 = ~DataInEndFrame;

assign DataOut = rx_ll_data_0;
assign DataOutValid = ~rx_ll_src_rdy_n_0;
assign rx_ll_dst_rdy_n_0 = ~DataOutReady;
assign DataOutStartFrame = ~rx_ll_sof_n_0;
assign DataOutEndFrame = ~rx_ll_eof_n_0;

always@(posedge MII_TX_CLK_0, posedge Reset) begin
    if(Reset) begin
        mii_tx_clk_0 <= 1'b0;
    end else begin
        mii_tx_clk_0 <= ~mii_tx_clk_0;
    end
end
// synthesis attribute ASYNC_REG of mii_rx_clk_0 is "TRUE"

BUFG bufg_tx_0(
    .I(                         mii_tx_clk_0),
    .O(                         tx_clk_0)
);

always@(posedge MII_RX_CLK_0, posedge Reset) begin
    if(Reset) begin
        mii_rx_clk_0 <= 1'b0;
    end else begin
        mii_rx_clk_0 <= ~mii_rx_clk_0;
    end
end
// synthesis attribute ASYNC_REG of mii_rx_clk_0 is "TRUE"

BUFG bufg_rx_0(
    .I(                         mii_rx_clk_0),
    .O(                         rx_clk_0)
);

v5_emac_v1_7_locallink v5_emac_ll(
    // EMAC0 Clocking
    // EMAC0 TX Clock input from BUFG
    .TX_CLK_0(                  tx_clk_0),

    // Local link Receiver Interface - EMAC0
    .RX_LL_CLOCK_0(             Clock),
    .RX_LL_RESET_0(             Reset),
    .RX_LL_DATA_0(              rx_ll_data_0),
    .RX_LL_SOF_N_0(             rx_ll_sof_n_0),
    .RX_LL_EOF_N_0(             rx_ll_eof_n_0),
    .RX_LL_SRC_RDY_N_0(         rx_ll_src_rdy_n_0),
    .RX_LL_DST_RDY_N_0(         rx_ll_dst_rdy_n_0),
    .RX_LL_FIFO_STATUS_0(       ),

    // Unused Receiver signals - EMAC0
    .EMAC0CLIENTRXDVLD(         EMAC0CLIENTRXDVLD),
    .EMAC0CLIENTRXFRAMEDROP(    EMAC0CLIENTRXFRAMEDROP),
    .EMAC0CLIENTRXSTATS(        ),
    .EMAC0CLIENTRXSTATSVLD(     ),
    .EMAC0CLIENTRXSTATSBYTEVLD( ),

    // Local link Transmitter Interface - EMAC0
    .TX_LL_CLOCK_0(             Clock),
    .TX_LL_RESET_0(             Reset),
    .TX_LL_DATA_0(              tx_ll_data_0),
    .TX_LL_SOF_N_0(             tx_ll_sof_n_0),
    .TX_LL_EOF_N_0(             tx_ll_eof_n_0),
    .TX_LL_SRC_RDY_N_0(         tx_ll_src_rdy_n_0),
    .TX_LL_DST_RDY_N_0(         tx_ll_dst_rdy_n_0),

    // Unused Transmitter signals - EMAC0
    .CLIENTEMAC0TXIFGDELAY(     8'h00),
    .EMAC0CLIENTTXSTATS(        ),
    .EMAC0CLIENTTXSTATSVLD(     ),
    .EMAC0CLIENTTXSTATSBYTEVLD( ),

    // MAC Control Interface - EMAC0
    .CLIENTEMAC0PAUSEREQ(       1'b0),
    .CLIENTEMAC0PAUSEVAL(       16'h0000),

    // MII Interface - EMAC0
    .MII_COL_0(                 MII_COL_0),
    .MII_CRS_0(                 MII_CRS_0),
    .MII_TXD_0(                 MII_TXD_0),
    .MII_TX_EN_0(               MII_TX_EN_0),
    .MII_TX_ER_0(               MII_TX_ER_0),
    .MII_TX_CLK_0(              MII_TX_CLK_0),
    .MII_RXD_0(                 MII_RXD_0),
    .MII_RX_DV_0(               MII_RX_DV_0),
    .MII_RX_ER_0(               MII_RX_ER_0),
    .MII_RX_CLK_0(              rx_clk_0),

    // Asynchronous Reset Input
    .RESET(                     Reset)
);

endmodule
