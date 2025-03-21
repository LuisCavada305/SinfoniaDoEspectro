module conversor7seg(  
    input         clock,
    input  [6:0]  pontos,
    output [11:0] disp7
);
    wire [3:0] enable;
    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;
    wire [1:0] s_contagem;
    wire [7:0] s_posicao;

assign disp7[11:8] = enable;

always @(s_contagem) begin
    case (s_contagem)
        2'b00:    enable = 4'b0001, s_posicao = 8'b00000000;
        2'b01:    enable = 4'b0010, s_posicao = ones;
        2'b10:    enable = 4'b0100, s_posicao = tens;
        2'b11:    enable = 4'b1000, s_posicao = hundreds;
        default:  enable = 4'b0001, s_posicao = 8'b00000000;
    endcase
end

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
        .binary(pontos),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );

    hexa7seg disp_hund_inst(
        .hexa(s_posicao),
        .display(disp7[7:0])
    );

endmodule



