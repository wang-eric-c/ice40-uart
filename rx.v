module UART_RX #(parameter MAX_BAUD = 2604, parameter HALF_BAUD = 1302) (
    input wire i_Clk,
    input wire i_Rst,
    input wire i_RX,
    output wire [7:0] o_RX_Data,
    output wire o_Valid
);

localparam [1:0] IDLE = 2'd0;
localparam [1:0] START = 2'd1;
localparam [1:0] DATA = 2'd2;
localparam [1:0] STOP = 2'd3;

reg [1:0] r_State = IDLE;
reg [2:0] r_Index = 0;
reg [$clog2(MAX_BAUD)-1:0] r_Count = 0;

reg r_Valid = 1'b0;
reg [7:0] r_Data = 8'b0;
reg [7:0] r_RX_Data = 8'b0;

always @ (posedge i_Clk)
begin
    if(i_Rst)
    begin
        r_State <= IDLE;
        r_Index <= 0;
        r_Count <= 0;

        r_Valid <= 1'b0;
        r_Data <= 8'b0;
    end
    else
    begin
        r_Valid <= 1'b0;
        case(r_State)
        IDLE:
        begin
            if(!i_RX)
            begin
                r_Count <= 0;
                r_State <= START;
            end
        end
        START:
        begin
            r_Count <= r_Count + 1;
            if(r_Count == HALF_BAUD - 1)
            begin
                if(!i_RX)
                begin
                    r_Count <= 0;
                    r_State <= DATA;
                end
                else
                begin
                    r_State <= IDLE;
                end
            end
        end
        DATA:
        begin
            if(r_Count < MAX_BAUD - 1)
            begin
                r_Count <= r_Count + 1;
            end
            else
            begin
                r_Count <= 0;
                r_Data[r_Index] <= i_RX;
                if(r_Index == 3'd7)
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
            if(r_Count < MAX_BAUD - 1)
            begin
                r_Count <= r_Count + 1;
            end
            else
            begin
                r_Count <= 0;
                if(i_RX == 1'b1)
                begin
                    r_RX_Data <= r_Data;
                    r_Valid <= 1'b1;
                    r_State <= IDLE;
                end
                else
                begin
                    r_State <= IDLE;
                end
            end
        end
        endcase
    end
end

assign o_RX_Data = r_RX_Data;
assign o_Valid = r_Valid;
    
endmodule