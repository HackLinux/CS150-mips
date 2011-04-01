//----------------------------------------------------------------------
// Title      : Media Independent Interface (MII) Physical Interface
// Project    : Virtex-5 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : mii_if.v
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
// Description:  This module creates a Media Independent Interface (MII)
//               by instantiating Input/Output buffers and Input/Output 
//               flip-flops as required.
//
//               This interface is used to connect the Ethernet MAC to
//               an external 10Mb/s and 100Mb/s Ethernet PHY.
//----------------------------------------------------------------------
//

`timescale 1 ps / 1 ps

module mii_if (
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

  input RESET;
  output [3:0] MII_TXD;
  output MII_TX_EN;
  output MII_TX_ER;
  input  [3:0] MII_RXD;
  input  MII_RX_DV;
  input  MII_RX_ER;
  input  MII_COL;
  input  MII_CRS;
  input  [3:0] TXD_FROM_MAC;
  input  TX_EN_FROM_MAC;
  input  TX_ER_FROM_MAC;
  input  TX_CLK;
  output [3:0] RXD_TO_MAC;
  output RX_DV_TO_MAC;
  output RX_ER_TO_MAC;
  input  RX_CLK;
  output MII_COL_TO_MAC;
  output MII_CRS_TO_MAC;

  reg  [3:0] RXD_TO_MAC;
  reg  RX_DV_TO_MAC;
  reg  RX_ER_TO_MAC;

  reg  [3:0] MII_TXD;
  reg  MII_TX_EN;
  reg  MII_TX_ER;

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
          MII_TXD   <= 8'h00;
      end
      else
      begin
          MII_TX_EN <= TX_EN_FROM_MAC;
          MII_TX_ER <= TX_ER_FROM_MAC;
          MII_TXD   <= TXD_FROM_MAC;
      end
  end

  //------------------------------------------------------------------------
  // MII Receiver Logic : Receive RX signals through IOBs from MII
  // interface
  //------------------------------------------------------------------------
  // Infer IOB Input flip-flops
  always @ (posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
          RX_DV_TO_MAC <= 1'b0;
          RX_ER_TO_MAC <= 1'b0;
          RXD_TO_MAC   <= 4'h0;
      end
      else
      begin
          RX_DV_TO_MAC <= MII_RX_DV;
          RX_ER_TO_MAC <= MII_RX_ER;
          RXD_TO_MAC   <= MII_RXD;
      end
  end

  // Half Duplex signals
  assign MII_COL_TO_MAC = MII_COL;
  assign MII_CRS_TO_MAC = MII_CRS;
 
endmodule
