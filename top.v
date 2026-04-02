module Top (
    input wire i_Clk,
    input wire i_RX,
    output wire o_TX,
    output wire o_Segment1_A,
    output wire o_Segment1_B,
    output wire o_Segment1_C,
    output wire o_Segment1_D,
    output wire o_Segment1_E,
    output wire o_Segment1_F,
    output wire o_Segment1_G
);

wire [6:0] w_Data;
wire w_TX_Busy;
wire w_RX_Valid;
wire [7:0] w_RX_Data;

reg [3:0] r_Reset_Count = 4'h0;
wire i_Rst = ~r_Reset_Count[3];

always @(posedge i_Clk)
begin
    if(!r_Reset_Count[3])
    begin
        r_Reset_Count <= r_Reset_Count + 1;
    end
end

UART_TX #(.MAX_BAUD(2604)) TX_inst (
    .i_Clk(i_Clk),
    .i_Rst(i_Rst),
    .i_TX_Start(w_RX_Valid),
    .i_TX_Data(w_RX_Data),

    .o_TX(o_TX),
    .o_TX_Busy(w_TX_Busy)
);

UART_RX #(.MAX_BAUD(2604), .HALF_BAUD(1302)) RX_inst(
    .i_Clk(i_Clk),
    .i_Rst(i_Rst),
    .i_RX(i_RX),
    .o_RX_Data(w_RX_Data),
    .o_Valid(w_RX_Valid)
);

wire w_Is_Digit = (w_RX_Data >= 8'h30) && (w_RX_Data <= 8'h39);

Seg7 Seg7_Inst(
    .i_Clk(i_Clk),
    .i_Rst(i_Rst),
    .i_Valid(w_RX_Valid & w_Is_Digit),
    .i_Digit(w_RX_Data[3:0]),
    .o_Display(w_Data) 
);

assign {o_Segment1_A, o_Segment1_B, o_Segment1_C, o_Segment1_D, o_Segment1_E, o_Segment1_F, o_Segment1_G}
    = {w_Data[0], w_Data[1], w_Data[2], w_Data[3], w_Data[4], w_Data[5], w_Data[6]};

endmodule
