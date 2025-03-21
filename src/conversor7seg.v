module conversor7seg(  
    input         clock,
    input  [6:0]  pontos,
    output reg [11:0] disp7  // Disp7 já é reg, não precisa de assign
);

    reg [3:0] enable;  // Alterado para reg
    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;
    wire [1:0] s_contagem;
    reg [3:0] s_posicao;  // Alterado para reg
    wire [6:0] tempDisp;

    always @(s_contagem) begin
        case (s_contagem)
            2'b00:    enable = 4'b1110; 
            2'b01:    enable = 4'b1101;
            2'b10:    enable = 4'b1011;
            2'b11:    enable = 4'b0111;
            default:  enable = 4'b0000; 
        endcase

        case (s_contagem)
            2'b00 : s_posicao = 4'b0001;
            2'b01 : s_posicao = 4'b1111;
            2'b10 : s_posicao = 4'b1010;
            2'b11 : s_posicao = 4'b1000;
            default:  s_posicao = 4'b1000;
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
        .display(tempDisp)
    );

    // Atribuição dos 8 bits de tempDisp para disp7[7:0]
    always @(*) begin
        disp7[6:0] = 7'b1110111;
		  disp7[7]  = 1'b0;
        disp7[11:8] = enable; // Assign enable para os 4 bits mais significativos
    end

endmodule
