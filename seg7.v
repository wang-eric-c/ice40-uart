module Seg7 (
    input i_Clk,
    input i_Valid,
    input i_Rst,
    input wire [3:0] i_Digit,
    output wire [6:0] o_Display // {A, B, C, D, E, F, G}
);
    reg [6:0] r_Display = 7'b1111111;

    always @(posedge i_Clk)
    begin
        if(i_Rst)
        begin
            r_Display <= 7'b1111111;
        end
        else if(i_Valid)
        begin
            case(i_Digit)
            4'b0000: r_Display <= 7'b0000001;
            4'b0001: r_Display <= 7'b1001111;
            4'b0010: r_Display <= 7'b0010010;
            4'b0011: r_Display <= 7'b0000110;
            4'b0100: r_Display <= 7'b1001100;
            4'b0101: r_Display <= 7'b0100100;
            4'b0110: r_Display <= 7'b0100000;
            4'b0111: r_Display <= 7'b0001111;
            4'b1000: r_Display <= 7'b0000000;
            4'b1001: r_Display <= 7'b0000100;
            default:
            begin
                r_Display <= 7'b1111111; 
            end
            endcase 
        end
    end

    assign o_Display = r_Display;

endmodule