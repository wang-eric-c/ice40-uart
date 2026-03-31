module UART_TX #(parameter MAX_BAUD = 2604) (
    input wire i_Clk,
    input wire i_Rst,
    input wire i_TX_Start,
    input wire [7:0] i_TX_Data,

    output wire o_TX,
    output wire o_TX_Busy
);

localparam LAST_BIT = 3'd7;

localparam IDLE = 2'd0;
localparam START = 2'd1;
localparam DATA = 2'd2;
localparam STOP = 2'd3;

reg r_Output = 1'b1;
reg r_Busy = 1'b0;

reg [2:0] r_Index = 0;
reg [7:0] r_Data = 8'b0;
reg [1:0] r_State = IDLE;

reg [$clog2(MAX_BAUD) - 1:0] r_Count = 0;

always @(posedge i_Clk)
begin
    if(i_Rst)
    begin
        r_State <= IDLE;
        r_Output <= 1'b1;
        r_Busy <= 1'b0;
        r_Index <= 0;
        r_Count <= 0;
    end
    else
    begin
        case (r_State)
        IDLE:
        begin
            r_Count <= 0;
            r_Output <= 1'b1;
            r_Busy <= 1'b0;
            r_Index <= 0;
            if(i_TX_Start)
            begin
                r_State <= START;
                r_Busy <= 1'b1;
                r_Data <= i_TX_Data;
            end
        end
        START:
        begin
            r_Count <= r_Count + 1;
            r_Output <= 1'b0;
            if(r_Count == MAX_BAUD - 1)
            begin
                r_Count <= 0;
                r_State <= DATA;
            end
        end
        DATA:
        begin
            r_Count <= r_Count + 1;
            r_Output <= r_Data[r_Index];
            if(r_Count == MAX_BAUD - 1)
            begin
                r_Count <= 0;
                if (r_Index == LAST_BIT)
                begin
                    r_Index <= 0;
                    r_State <= STOP;
                end
                else
                begin
                    r_Index <= r_Index + 1;
                end
            end
        end
        STOP:
        begin
            r_Count <= r_Count + 1;
            r_Output <= 1'b1;
            if(r_Count == MAX_BAUD - 1)
            begin
                r_Count <= 0;
                r_State <= IDLE;
            end
        end
        endcase

    end
end

assign o_TX = r_Output;
assign o_TX_Busy = r_Busy;

endmodule