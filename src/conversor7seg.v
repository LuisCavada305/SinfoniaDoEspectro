module conversor7seg(clock, numero, display);  
    input               clock;
    input       [6:0]   numero;
    output reg  [11:0]  display;

    reg     [3:0] enable;
    wire    [3:0] hundreds;
    wire    [3:0] tens;
    wire    [3:0] ones;
    wire    [1:0] s_contagem;
    reg     [3:0] s_digito_bin;
    wire    [6:0] tempDisp;

    always @(s_contagem) begin
        case (s_contagem)
            2'b00:    enable = 4'b1110; 
            2'b01:    enable = 4'b1101;
            2'b10:    enable = 4'b1011;
            2'b11:    enable = 4'b0111;
            default:  enable = 4'b0000; 
        endcase

        case (s_contagem)
            2'b00   : s_digito_bin = ones;
            2'b01   : s_digito_bin = tens;
            2'b10   : s_digito_bin = hundreds;
            2'b11   : s_digito_bin = 4'b1111;
            default : s_digito_bin = 4'b1111;
        endcase
    end
    
    // Unificacao dos sinais de enable e dos 7 segmentos
    always @(*) begin
        display[7:0]    = s_digito_bcd;
        display[11:8]   = enable;
    end

    // Conta ate 3
    contador_m  #(.M(4), .N(2)) contador_ordem(
        .clock (clock),
        .zera_as(1'b0),
        .zera_s (1'b0),
        .conta (1'b1),
        .Q (s_contagem),
        .fim (),
        .meio () 
    );

    // Conversão de 8 bits para 3 dígitos BCD
    bin2bcd conversor(    
        .binary(numero),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );

    // Conversao BCD para display de 7 segmentos
    bin2sevenSeg bcd_disp(
        .hexa   (s_digito_bin),
        .display(s_digito_bcd)
    );
endmodule
