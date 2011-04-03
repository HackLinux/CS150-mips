//----------------------------------------------------------------------
// Title      : Media Independent Interface (MII) Physical I/F
// Project    : Virtex-5 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : mii_byte_phy_if.v
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
//----------------------------------------------------------------------
// Description:  This module creates a Media Independent 
//               Interface (MII) by instantiating Input/Output buffers  
//               and Input/Output flip-flops as required.
//
//               This interface is used to connect the Ethernet MAC to
//               an external 10/100Mb/s Ethernet PHY.
//----------------------------------------------------------------------


`timescale 1 ps / 1 ps

module mii_byte_phy_if
    (
        RESET,
        // MII Interface
        MII_TXD,
        MII_TX_EN,
        MII_TX_ER,
        MII_RXD,
        MII_RX_DV,
        MII_RX_ER,
        MII_COL,
        MII_CRS,
        // MAC Interface
        TXD_FROM_MAC,
        TX_EN_FROM_MAC,
        TX_ER_FROM_MAC,
        TX_CLK,
        RXD_TO_MAC,
        RX_DV_TO_MAC,
        RX_ER_TO_MAC,
        RX_CLK,
        MII_COL_TO_MAC,
        MII_CRS_TO_MAC);

  input  RESET;

  output [3:0] MII_TXD;
  output MII_TX_EN;
  output MII_TX_ER;
  
  input  [3:0] MII_RXD;
  input  MII_RX_DV;
  input  MII_RX_ER;

  input  MII_COL;
  input  MII_CRS;
  
  input  [7:0] TXD_FROM_MAC;
  input  TX_EN_FROM_MAC;
  input  TX_ER_FROM_MAC;
  input  TX_CLK;

  output [7:0] RXD_TO_MAC;
  output RX_DV_TO_MAC;
  output RX_ER_TO_MAC;
  input  RX_CLK;

  output MII_COL_TO_MAC;
  output MII_CRS_TO_MAC;

  wire [3:0] mii_txd_negedge;

  wire sfd_seen;
  reg  sfd_window;

  reg  mii_rx_dv_reg1;
  reg  mii_rx_dv_reg2;
  reg  mii_rx_dv_reg3;
  wire mii_rx_dv_iddr_q1;
  wire mii_rx_dv_iddr_q2;
  wire mii_rx_dv_to_mac_i;

  reg  mii_rx_er_reg1;
  reg  mii_rx_er_reg2;
  reg  mii_rx_er_reg3;
  wire mii_rx_er_iddr_q1;
  wire mii_rx_er_to_mac_i;

  wire [7:0] mii_rxd_iddr_q1;
  wire [7:0] mii_rxd_iddr_q2;
  reg  [3:0] mii_rxd_iddr_q2_rise;
  reg  [7:0] mii_rxd_iddr_q1_reg;
  reg  [7:0] mii_rxd_iddr_q2_reg;

  reg  d_on_falling;
  reg  [7:0] mii_rxd_d_on_rising;
  reg  [7:0] mii_rxd_d_on_falling;
  wire [7:0] mii_rxd_10m_100m_i;

  wire [7:0] mii_rxd_to_mac_i;
  
  reg  [7:0] RXD_TO_MAC;
  reg  RX_DV_TO_MAC;
  reg  RX_ER_TO_MAC;

  reg  MII_TX_EN;
  reg  MII_TX_ER;

  reg  supress_en;
  reg  supress_en_reg;

  //------------------------------------------------------------------------
  // MII Transmitter Logic : Drive TX signals through IOBs onto MII
  // interface
  //------------------------------------------------------------------------
  // Infer IOB Output flip-flops.
  always @(posedge TX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
          MII_TX_EN <= 1'b0;
          MII_TX_ER <= 1'b0;
      end
      else
      begin
          MII_TX_EN <= TX_EN_FROM_MAC;
          MII_TX_ER <= TX_ER_FROM_MAC;
      end
  end

  // For 100M/10M operation create negative edge input to ODDR
  assign mii_txd_negedge = TXD_FROM_MAC[7:4];

  // For 100M/10M operation, ODDR takes 8-bit data at 12.5/1.25MHZ to 4-bit data at 25/2.5MHZ
  ODDR #("SAME_EDGE") TXD_0_ODDR (.Q(MII_TXD[0]),
                                .C(TX_CLK),
                                .CE(1'b1),
                                .D1(TXD_FROM_MAC[0]),
                                .D2(mii_txd_negedge[0]),
                                .R(RESET),
                                .S(1'b0)
                               );
   
  ODDR #("SAME_EDGE") TXD_1_ODDR (.Q(MII_TXD[1]),
                                .C(TX_CLK),
                                .CE(1'b1),
                                .D1(TXD_FROM_MAC[1]),
                                .D2(mii_txd_negedge[1]),
                                .R(RESET),
                                .S(1'b0)
                   );
   
  ODDR #("SAME_EDGE") TXD_2_ODDR (.Q(MII_TXD[2]),
                                .C(TX_CLK),
                                .CE(1'b1),
                                .D1(TXD_FROM_MAC[2]),
                                .D2(mii_txd_negedge[2]),
                                .R(RESET),
                                .S(1'b0)
                   );
   
  ODDR #("SAME_EDGE") TXD_3_ODDR (.Q(MII_TXD[3]),
                                .C(TX_CLK),
                                .CE(1'b1),
                                .D1(TXD_FROM_MAC[3]),
                                .D2(mii_txd_negedge[3]),
                                .R(RESET),
                                .S(1'b0)
                   );

  //------------------------------------------------------------------------
  // MII Receiver Logic : Receive RX signals through IOBs from MII
  // interface
  //------------------------------------------------------------------------
  // Drive input MII Rx signals from PADS through Input Buffers and then 
  // use IDELAYs to provide Zero-Hold Time Delay 
  IDDR RX_DV_IDDR(.Q1(mii_rx_dv_iddr_q1),      
                  .Q2(mii_rx_dv_iddr_q2),
                  .C(RX_CLK),
                  .CE(1'b1),
                  .D(MII_RX_DV),
                  .R(1'b0),
                  .S(1'b0)
                 );

  always @(posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
         mii_rx_dv_reg2 <= 1'b0;
         mii_rx_dv_reg3 <= 1'b0;
      end
      else
      begin
         mii_rx_dv_reg2 <= mii_rx_dv_iddr_q1;
         mii_rx_dv_reg3 <= mii_rx_dv_reg2;
      end
  end

  always @(posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
         supress_en <= 1'b0;
         supress_en_reg <= 1'b0;
      end
      else
      begin
         supress_en <= mii_rx_dv_iddr_q1 & ~(mii_rx_dv_iddr_q2) & d_on_falling;
         supress_en_reg <= supress_en;
      end
  end
       
  IDDR RX_ER_IDDR(.Q1(mii_rx_er_iddr_q1),      
                  .Q2(),
                  .C(RX_CLK),
                  .CE(1'b1),
                  .D(MII_RX_ER),
                  .R(1'b0),
                  .S(1'b0)
                 );

  always @(posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
         mii_rx_er_reg2 <= 1'b0;
         mii_rx_er_reg3 <= 1'b0;
      end
      else
      begin
         mii_rx_er_reg2 <= mii_rx_er_iddr_q1;
         mii_rx_er_reg3 <= mii_rx_er_reg2;
      end
  end


  IDDR RXD_0_IDDR(.Q1(mii_rxd_iddr_q1[0]),      
                  .Q2(mii_rxd_iddr_q2[0]),
                  .C(RX_CLK),
                  .CE(1'b1),
                  .D(MII_RXD[0]),
                  .R(1'b0),
                  .S(1'b0)
                 ); 
  IDDR RXD_1_IDDR(.Q1(mii_rxd_iddr_q1[1]),      
                  .Q2(mii_rxd_iddr_q2[1]),
                  .C(RX_CLK),
                  .CE(1'b1),
                  .D(MII_RXD[1]),
                  .R(1'b0),
                  .S(1'b0)
                 ); 
  IDDR RXD_2_IDDR(.Q1(mii_rxd_iddr_q1[2]),      
                  .Q2(mii_rxd_iddr_q2[2]),
                  .C(RX_CLK),
                  .CE(1'b1),
                  .D(MII_RXD[2]),
                  .R(1'b0),
                  .S(1'b0)
                 ); 
  IDDR RXD_3_IDDR(.Q1(mii_rxd_iddr_q1[3]),      
                  .Q2(mii_rxd_iddr_q2[3]),
                  .C(RX_CLK),
                  .CE(1'b1),
                  .D(MII_RXD[3]),
                  .R(1'b0),
                  .S(1'b0)
                 );

  always @(posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
        mii_rxd_iddr_q1_reg <= 8'h00;
        mii_rxd_iddr_q2_reg <= 8'h00;
      end
      else
      begin
        mii_rxd_iddr_q1_reg <= mii_rxd_iddr_q1;
        mii_rxd_iddr_q2_reg <= mii_rxd_iddr_q2;
      end
  end

  always @(posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
          mii_rxd_d_on_falling <= 8'h00;
      end
      else
      begin
         mii_rxd_d_on_falling[3:0] <= mii_rxd_iddr_q1_reg[3:0];
         mii_rxd_d_on_falling[7:4] <= mii_rxd_iddr_q2_reg[3:0];
      end
  end
 
  always @(posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
         mii_rxd_iddr_q2_rise  <= 4'h0;
         mii_rxd_d_on_rising   <= 8'h00;
      end
      else
      begin
         mii_rxd_iddr_q2_rise <= mii_rxd_iddr_q2_reg[3:0];

         mii_rxd_d_on_rising[3:0] <= mii_rxd_iddr_q2_rise[3:0];
         mii_rxd_d_on_rising[7:4] <= mii_rxd_iddr_q1_reg[3:0];
      end
  end

  always @(posedge RX_CLK)
  begin
     // Set on rising edge
     if (mii_rx_dv_iddr_q1 == 1'b1 && mii_rx_dv_reg2 == 1'b0)
     begin  
        sfd_window <= 1'b1;
     end 
     // Reset on sfd_seen
     else if (sfd_seen == 1'b1)
     begin  
        sfd_window <= 1'b0;
     end
     else
     begin
        sfd_window <= sfd_window;
     end
  end

  // Signal when SFD 0xD5 is seen
  assign sfd_seen = ((sfd_window == 1'b1) && 
                     ((mii_rxd_iddr_q2_reg[3:0]      == 4'hD && mii_rxd_iddr_q1_reg[3:0] == 4'h5) ||
                      (mii_rxd_iddr_q2_rise[3:0] == 4'h5 && mii_rxd_iddr_q1_reg[3:0] == 4'hD))) ? 1'b1: 1'b0;
  // Generate a select signal to indicate which signal is correctly aligned to SFD
  always @(posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
         d_on_falling     <= 1'b0;
      end
      else
      begin 
        if (sfd_seen == 1'b1 && mii_rxd_iddr_q2_reg[3:0] == 4'hD && mii_rxd_iddr_q1_reg[3:0] == 4'h5)
	begin  
           d_on_falling <= 1'b1;
	end    
        if (sfd_seen == 1'b1 && mii_rxd_iddr_q2_rise[3:0] == 4'h5 && mii_rxd_iddr_q1_reg[3:0] == 4'hD)
	begin		 
           d_on_falling <= 1'b0;
	end
      end
  end

  assign mii_rxd_10m_100m_i = d_on_falling == 1'b1 ? mii_rxd_d_on_falling : mii_rxd_d_on_rising;

  // Select 1G or 100/10M RX Signals
  assign mii_rxd_to_mac_i[7:0]   = mii_rxd_10m_100m_i;
  assign mii_rx_dv_to_mac_i      = mii_rx_dv_reg3;
  assign mii_rx_er_to_mac_i      = mii_rx_er_reg3;


  // Infer IOB Input flip-flops
  always @(posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
          RX_DV_TO_MAC <= 1'b0;
          RX_ER_TO_MAC <= 1'b0;
          RXD_TO_MAC   <= 8'h00;
      end
      else
      begin
          RX_DV_TO_MAC <= mii_rx_dv_to_mac_i & ~(supress_en_reg);
          RX_ER_TO_MAC <= mii_rx_er_to_mac_i & ~(supress_en_reg);
          RXD_TO_MAC   <= mii_rxd_to_mac_i;
      end
  end

  assign MII_COL_TO_MAC = MII_COL;
  assign MII_CRS_TO_MAC = MII_CRS; 

endmodule

