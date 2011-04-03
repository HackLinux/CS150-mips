module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

  output        SOut
);
  // for log2 function
  `include "util.vh"

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);

  //--|Solution|----------------------------------------------------------------

  //--|Declarations|------------------------------------------------------------

  wire                            SymbolEdge;
  wire                            Sample;
  wire                            Start;
  wire                            TXRunning;

  reg     [9:0]                   TXShift;
  reg     [3:0]                   BitCounter;
  reg     [ClockCounterWidth-1:0] ClockCounter;
  reg                             HasByte;

  //--|Signal Assignments|------------------------------------------------------

  // Goes high at every symbol edge
  assign  SymbolEdge   = (ClockCounter == SymbolEdgeTime - 1);

  // Goes high when it is time to start receiving a new set of characters
  assign  Start         = DataInValid && !TXRunning;

  // Currently receiving a character
  assign  TXRunning     = BitCounter != 4'd0;

  // Outputs
  assign  SOut = TXShift[0];
  assign  DataInReady = !HasByte && !TXRunning;

  //--|Counters|----------------------------------------------------------------

  // Counts cycles until a single symbol is done
  always @ (posedge Clock) begin
    ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
  end

  // Counts down from 10 bits for every character
  always @ (posedge Clock) begin
    if (Reset) begin
      BitCounter <= 0;
      HasByte <= 1'b0;
    end 
    else if (Start) begin
      BitCounter <= 10;
      TXShift <= {1'b1, DataIn, 1'b0};
    end 
   //--|Shift Register|----------------------------------------------------------
    else if (SymbolEdge && TXRunning) begin
      BitCounter <= BitCounter - 1;
      TXShift <= {1'b1, TXShift[9:1]};
    end
   //--|Extra State For Ready/Valid|---------------------------------------------
    else if (BitCounter == 1 && SymbolEdge) HasByte <= 1'b1;
   // Check DataInValid
    else if (DataInValid) HasByte <= 1'b0;
  end

endmodule
