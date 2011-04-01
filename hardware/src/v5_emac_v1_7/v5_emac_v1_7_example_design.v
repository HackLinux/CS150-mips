//-----------------------------------------------------------------------------
// Title      : Virtex-5 Ethernet MAC Example Design Wrapper
// Project    : Virtex-5 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : v5_emac_v1_7_example_design.v
// Version    : 1.7
//-----------------------------------------------------------------------------
//
// (c) Copyright 2004-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Description:  This is the Verilog example design for the Virtex-5 
//               Embedded Ethernet MAC.  It is intended that
//               this example design can be quickly adapted and downloaded onto
//               an FPGA to provide a real hardware test environment.
//
//               This level:
//
//               * instantiates the TEMAC local link file that instantiates 
//                 the TEMAC top level together with a RX and TX FIFO with a 
//                 local link interface;
//
//               * instantiates a simple client I/F side example design,
//                 providing an address swap and a simple
//                 loopback function;
//
//               * Instantiates IBUFs on the GTX_CLK, REFCLK and HOSTCLK inputs 
//                 if required;
//
//               Please refer to the Datasheet, Getting Started Guide, and
//               the Virtex-5 Embedded Tri-Mode Ethernet MAC User Gude for
//               further information.
//
//
//
//    ---------------------------------------------------------------------
//    | EXAMPLE DESIGN WRAPPER                                            |
//    |           --------------------------------------------------------|
//    |           |LOCAL LINK WRAPPER                                     |
//    |           |              -----------------------------------------|
//    |           |              |BLOCK LEVEL WRAPPER                     |
//    |           |              |    ---------------------               |
//    | --------  |  ----------  |    | ETHERNET MAC      |               |
//    | |      |  |  |        |  |    | WRAPPER           |  ---------    |
//    | |      |->|->|        |--|--->| Tx            Tx  |--|       |--->|
//    | |      |  |  |        |  |    | client        PHY |  |       |    |
//    | | ADDR |  |  | LOCAL  |  |    | I/F           I/F |  |       |    |  
//    | | SWAP |  |  |  LINK  |  |    |                   |  | PHY   |    |
//    | |      |  |  |  FIFO  |  |    |                   |  | I/F   |    |
//    | |      |  |  |        |  |    |                   |  |       |    |
//    | |      |  |  |        |  |    | Rx            Rx  |  |       |    |
//    | |      |  |  |        |  |    | client        PHY |  |       |    |
//    | |      |<-|<-|        |<-|----| I/F           I/F |<-|       |<---|
//    | |      |  |  |        |  |    |                   |  ---------    |
//    | --------  |  ----------  |    ---------------------               |
//    |           |              -----------------------------------------|
//    |           --------------------------------------------------------|
//    ---------------------------------------------------------------------
//
//-----------------------------------------------------------------------------


`timescale 1 ps / 1 ps


//-----------------------------------------------------------------------------
// The module declaration for the example design.
//-----------------------------------------------------------------------------
module v5_emac_v1_7_example_design
(
    // Client Receiver Interface - EMAC0
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,

    // Client Transmitter Interface - EMAC0
    CLIENTEMAC0TXIFGDELAY,
    EMAC0CLIENTTXSTATS,
    EMAC0CLIENTTXSTATSVLD,
    EMAC0CLIENTTXSTATSBYTEVLD,

    // MAC Control Interface - EMAC0
    CLIENTEMAC0PAUSEREQ,
    CLIENTEMAC0PAUSEVAL,


    // MII Interface - EMAC0
    MII_COL_0,
    MII_CRS_0,
    MII_TXD_0,
    MII_TX_EN_0,
    MII_TX_ER_0,
    MII_TX_CLK_0,
    MII_RXD_0,
    MII_RX_DV_0,
    MII_RX_ER_0,
    MII_RX_CLK_0,

    // Asynchronous Reset
    RESET
);


//-----------------------------------------------------------------------------
// Port Declarations 
//-----------------------------------------------------------------------------
    // Client Receiver Interface - EMAC0
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;

    // Client Transmitter Interface - EMAC0
    input    [7:0]  CLIENTEMAC0TXIFGDELAY;
    output          EMAC0CLIENTTXSTATS;
    output          EMAC0CLIENTTXSTATSVLD;
    output          EMAC0CLIENTTXSTATSBYTEVLD;

    // MAC Control Interface - EMAC0
    input           CLIENTEMAC0PAUSEREQ;
    input   [15:0]  CLIENTEMAC0PAUSEVAL;


    // MII Interface - EMAC0
    input           MII_COL_0;
    input           MII_CRS_0;
    output   [3:0]  MII_TXD_0;
    output          MII_TX_EN_0;
    output          MII_TX_ER_0;
    input           MII_TX_CLK_0;
    input    [3:0]  MII_RXD_0;
    input           MII_RX_DV_0;
    input           MII_RX_ER_0;
    input           MII_RX_CLK_0;

   
    // Asynchronous Reset
    input           RESET;

//-----------------------------------------------------------------------------
// Wire and Reg Declarations 
//-----------------------------------------------------------------------------

    // Global asynchronous reset
    wire            reset_i;
    // Local Link Interface Clocking Signal - EMAC0
    wire            ll_clk_0_i;

    // address swap transmitter connections - EMAC0
    wire      [7:0] tx_ll_data_0_i;
    wire            tx_ll_sof_n_0_i;
    wire            tx_ll_eof_n_0_i;
    wire            tx_ll_src_rdy_n_0_i;
    wire            tx_ll_dst_rdy_n_0_i;

    // address swap receiver connections - EMAC0
    wire      [7:0] rx_ll_data_0_i;
    wire            rx_ll_sof_n_0_i;
    wire            rx_ll_eof_n_0_i;
    wire            rx_ll_src_rdy_n_0_i;
    wire            rx_ll_dst_rdy_n_0_i;

    // create a synchronous reset in the local link clock domain
    reg       [5:0] ll_pre_reset_0_i;
    reg             ll_reset_0_i;

    // synthesis attribute ASYNC_REG of tx_pre_reset_0_i is "TRUE";

    // EMAC0 Clocking signals

    // MII input clocks from PHY
    wire            mii_tx_clk_0_i;
    // synthesis attribute buffer_type of mii_tx_clk_0_i is none;
    reg             mii_tx_clk_0_r;
    wire            tx_clk_0;
    wire            mii_rx_clk_0_i;
    // synthesis attribute buffer_type of mii_rx_clk_0_i is none;
    reg             mii_rx_clk_0_r;
    wire            rx_clk_0_i;



//-----------------------------------------------------------------------------
// Main Body of Code 
//-----------------------------------------------------------------------------

    // Reset input buffer
    IBUF reset_ibuf (.I(RESET), .O(reset_i));

    // EMAC0 Clocking

    //------------------------------------------------------------------------
    // MII PHY side transmit clock for EMAC0
    //------------------------------------------------------------------------
    IBUF mii_tx_clk_0_ibuf (.I(MII_TX_CLK_0), .O(mii_tx_clk_0_i));

    always @(posedge mii_tx_clk_0_i, posedge reset_i)
    begin
        if (reset_i == 1'b1)
        begin
            mii_tx_clk_0_r <= 1'b0;
        end
        else
        begin
            mii_tx_clk_0_r <= ~(mii_tx_clk_0_r);
        end
    end
    //synthesis attribute ASYNC_REG of mii_tx_clk_0_r is "TRUE"

    // Put the divided down PHY TX clock through a BUFG.
    // Used to clock the TX section of the EMAC wrappers.    
    BUFG bufg_tx_0 (.I(mii_tx_clk_0_r), .O(tx_clk_0));

    //------------------------------------------------------------------------
    // MII Receiver Clock Management
    //------------------------------------------------------------------------
    IBUF mii_rx_clk_0_ibuf (.I(MII_RX_CLK_0), .O(mii_rx_clk_0_i));

    always @(posedge mii_rx_clk_0_i, posedge reset_i)
    begin
        if (reset_i == 1'b1)
        begin
            mii_rx_clk_0_r <= 1'b0;
        end
        else
        begin
            mii_rx_clk_0_r <= ~(mii_rx_clk_0_r);
        end
    end
    //synthesis attribute ASYNC_REG of mii_rx_clk_0_r is "TRUE"

    // Put the divided down PHY RX clock through a BUFG.
    // Used to clock the RX section of the EMAC wrappers.
    BUFG bufg_rx_0 (.I(mii_rx_clk_0_r), .O(rx_clk_0_i));

    assign ll_clk_0_i = tx_clk_0;


    //------------------------------------------------------------------------
    // Instantiate the EMAC Wrapper with LL FIFO 
    // (v5_emac_v1_7_locallink.v) 
    //------------------------------------------------------------------------
    v5_emac_v1_7_locallink v5_emac_ll
    (
    // EMAC0 Clocking
    // EMAC0 TX Clock input from BUFG
    .TX_CLK_0                            (tx_clk_0),

    // Local link Receiver Interface - EMAC0
    .RX_LL_CLOCK_0                       (ll_clk_0_i),
    .RX_LL_RESET_0                       (ll_reset_0_i),
    .RX_LL_DATA_0                        (rx_ll_data_0_i),
    .RX_LL_SOF_N_0                       (rx_ll_sof_n_0_i),
    .RX_LL_EOF_N_0                       (rx_ll_eof_n_0_i),
    .RX_LL_SRC_RDY_N_0                   (rx_ll_src_rdy_n_0_i),
    .RX_LL_DST_RDY_N_0                   (rx_ll_dst_rdy_n_0_i),
    .RX_LL_FIFO_STATUS_0                 (),

    // Unused Receiver signals - EMAC0
    .EMAC0CLIENTRXDVLD                   (EMAC0CLIENTRXDVLD),
    .EMAC0CLIENTRXFRAMEDROP              (EMAC0CLIENTRXFRAMEDROP),
    .EMAC0CLIENTRXSTATS                  (EMAC0CLIENTRXSTATS),
    .EMAC0CLIENTRXSTATSVLD               (EMAC0CLIENTRXSTATSVLD),
    .EMAC0CLIENTRXSTATSBYTEVLD           (EMAC0CLIENTRXSTATSBYTEVLD),

    // Local link Transmitter Interface - EMAC0
    .TX_LL_CLOCK_0                       (ll_clk_0_i),
    .TX_LL_RESET_0                       (ll_reset_0_i),
    .TX_LL_DATA_0                        (tx_ll_data_0_i),
    .TX_LL_SOF_N_0                       (tx_ll_sof_n_0_i),
    .TX_LL_EOF_N_0                       (tx_ll_eof_n_0_i),
    .TX_LL_SRC_RDY_N_0                   (tx_ll_src_rdy_n_0_i),
    .TX_LL_DST_RDY_N_0                   (tx_ll_dst_rdy_n_0_i),

    // Unused Transmitter signals - EMAC0
    .CLIENTEMAC0TXIFGDELAY               (CLIENTEMAC0TXIFGDELAY),
    .EMAC0CLIENTTXSTATS                  (EMAC0CLIENTTXSTATS),
    .EMAC0CLIENTTXSTATSVLD               (EMAC0CLIENTTXSTATSVLD),
    .EMAC0CLIENTTXSTATSBYTEVLD           (EMAC0CLIENTTXSTATSBYTEVLD),

    // MAC Control Interface - EMAC0
    .CLIENTEMAC0PAUSEREQ                 (CLIENTEMAC0PAUSEREQ),
    .CLIENTEMAC0PAUSEVAL                 (CLIENTEMAC0PAUSEVAL),




    // MII Interface - EMAC0
    .MII_COL_0                           (MII_COL_0),
    .MII_CRS_0                           (MII_CRS_0),
    .MII_TXD_0                           (MII_TXD_0),
    .MII_TX_EN_0                         (MII_TX_EN_0),
    .MII_TX_ER_0                         (MII_TX_ER_0),
    .MII_TX_CLK_0                        (mii_tx_clk_0_i),
    .MII_RXD_0                           (MII_RXD_0),
    .MII_RX_DV_0                         (MII_RX_DV_0),
    .MII_RX_ER_0                         (MII_RX_ER_0),
    .MII_RX_CLK_0                        (rx_clk_0_i),

    // Asynchronous Reset Input
    .RESET                               (reset_i));


    //-------------------------------------------------------------------
    //  Instatiate the address swapping module
    //-------------------------------------------------------------------
    address_swap_module_8 client_side_asm_emac0 
      (.rx_ll_clock(ll_clk_0_i),
       .rx_ll_reset(ll_reset_0_i),
       .rx_ll_data_in(rx_ll_data_0_i),
       .rx_ll_sof_in_n(rx_ll_sof_n_0_i),
       .rx_ll_eof_in_n(rx_ll_eof_n_0_i),
       .rx_ll_src_rdy_in_n(rx_ll_src_rdy_n_0_i),
       .rx_ll_data_out(tx_ll_data_0_i),
       .rx_ll_sof_out_n(tx_ll_sof_n_0_i),
       .rx_ll_eof_out_n(tx_ll_eof_n_0_i),
       .rx_ll_src_rdy_out_n(tx_ll_src_rdy_n_0_i),
       .rx_ll_dst_rdy_in_n(tx_ll_dst_rdy_n_0_i)
    );

    assign rx_ll_dst_rdy_n_0_i   = tx_ll_dst_rdy_n_0_i;

    // Create synchronous reset in the transmitter clock domain.
    always @(posedge ll_clk_0_i, posedge reset_i)
    begin
      if (reset_i === 1'b1)
      begin
        ll_pre_reset_0_i <= 6'h3F;
        ll_reset_0_i     <= 1'b1;
      end
      else
      begin
        ll_pre_reset_0_i[0]   <= 1'b0;
        ll_pre_reset_0_i[5:1] <= ll_pre_reset_0_i[4:0];
        ll_reset_0_i          <= ll_pre_reset_0_i[5];
      end
    end
     




endmodule
