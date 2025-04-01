module letra2sevenSeg (letra, display);
    input       [4:0]   letra;
    output reg  [7:0]   display;

    always @(*)
        case(letra)
            5'h00     : display = 8'b00000000;
            5'h01     : display = 8'b11111001;
            5'h02     : display = 8'b01011011;
            5'h03     : display = 8'b11000011;
            5'h04     : display = 8'b00111011;
            5'h05     : display = 8'b11010011;
            5'h06     : display = 8'b11010001;
            5'h07     : display = 8'b11111010;
            5'h08     : display = 8'b01111001;
            5'h09     : display = 8'b00101000;
            5'h0a     : display = 8'b00101011;
            5'h0b     : display = 8'b01010001;
            5'h0c     : display = 8'b01000011;
            5'h0d     : display = 8'b10001001;
            5'h0e     : display = 8'b11101001;
            5'h0f     : display = 8'b11101011;
            5'h10     : display = 8'b11110001;
            5'h11     : display = 8'b11111000;
            5'h12     : display = 8'b11000001;
            5'h13     : display = 8'b11011010;
            5'h14     : display = 8'b01010011;
            5'h15     : display = 8'b01101011;
            5'h16     : display = 8'b00001011;
            5'h17     : display = 8'b01100010;
            5'h18     : display = 8'b00111000;
            5'h19     : display = 8'b01111010;
            5'h1a     : display = 8'b10110011;
				default   : display = 8'b00000000;
        endcase
endmodule