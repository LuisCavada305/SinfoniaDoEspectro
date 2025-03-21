module bin2bcd(
    input  [7:0] binary,
    output [3:0] hundreds,
    output [3:0] tens,
    output [3:0] ones
);
    // Divisão para extrair centenas, dezenas e unidades
    assign hundreds = binary / 100;
    assign tens     = (binary % 100) / 10;
    assign ones     = binary % 10;
endmodule