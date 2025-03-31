module bin2sevenSeg (bcd, display);
    input       [4:0]   bcd;
    output reg  [7:0]   display;

    always @(bcd)
        case(bcd)
            5'h0    : display = 8'b11101011;
            5'h1    : display = 8'b00101000;
            5'h2    : display = 8'b10110011;
            5'h3    : display = 8'b10111010;
            5'h4    : display = 8'b01111000;
            5'h5    : display = 8'b11011010;
            5'h6    : display = 8'b11011011;
            5'h7    : display = 8'b10101000;
            5'h8    : display = 8'b11111011;
            5'h9	: display = 8'b11111010;
			default : display = 8'b11111111;
        endcase
endmodule