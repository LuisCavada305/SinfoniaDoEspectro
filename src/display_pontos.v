module display_pontos(
    input  [6:0] pontos,
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

