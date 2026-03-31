module Top (
    input wire i_Clk,
    input wire i_RX,
    //input wire i_TX_Start,
    //input wire [7:0] i_TX_Data,
    output wire o_TX
);

wire w_TX_Busy;
wire w_RX_Valid;
wire [7:0] w_RX_Data;

wire i_Rst = 1'b0;


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
    
endmodule