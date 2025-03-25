module bin2sevenSeg (bcd, display);
    input       [4:0]   bcd,
    output reg  [7:0]   display

    always @(hexa)
        case(bcd)
            4'h0: display = 8'b11101011;
            4'h1: display = 8'b00101000;
            4'h2: display = 8'b10110011;
            4'h3: display = 8'b10111010;
            4'h4: display = 8'b01111000;
            4'h5: display = 8'b11011010;
            4'h6: display = 8'b11011011;
            4'h7: display = 8'b10101000;
            4'h8: display = 8'b11111011;
            4'h9: display = 8'b11111010;
        endcase
endmodule