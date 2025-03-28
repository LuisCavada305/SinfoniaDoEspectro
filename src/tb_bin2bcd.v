`timescale 1ns/1ns

module tb_bin2bcd();

    reg [7:0] numero;
    wire [3:0] ones;
    wire [3:0] tens;
    wire [3:0] hundreds;

    bin2bcd DUT(
        .binary(numero),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );

    initial begin
        #(5);
        numero = 8'b11000011;
        #(5);
        numero = 8'b11000100;
        #(5);
    end
endmodule
