module display_pontos(
    input  [7:0] pontos,
    input        enable,
    output [6:0] disp_hundreds,
    output [6:0] disp_tens,
    output [6:0] disp_ones
);
    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;
    
    // Conversão de 8 bits para 3 dígitos BCD
    bin2bcd conv (
        .binary(pontos),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );
    
    // Se enable estiver ativo, passa os dígitos; caso contrário, envia um código (por exemplo, 10) para indicar blank.
    wire [3:0] hundreds_in = (enable) ? hundreds : 4'd10;
    wire [3:0] tens_in     = (enable) ? tens     : 4'd10;
    wire [3:0] ones_in     = (enable) ? ones     : 4'd10;
    
    // Instanciação de 3 módulos hexa7seg para cada dígito
    hexa7seg disp_hund_inst(
        .hexa(hundreds_in),
        .display(disp_hundreds)
    );
    
    hexa7seg disp_tens_inst(
        .hexa(tens_in),
        .display(disp_tens)
    );
    
    hexa7seg disp_ones_inst(
        .hexa(ones_in),
        .display(disp_ones)
    );
endmodule


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
