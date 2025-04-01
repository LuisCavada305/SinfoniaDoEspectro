module conversor7seg(select, clock, numero, letra, contagem_display, display);  
    input               clock;
    input               select;
    input       [7:0]   numero;
    input       [4:0]   letra;
    output      [1:0]   contagem_display;
    output	   [11:0]  display;

    //reg     [3:0] enable;
    wire    [3:0] hundreds;
    wire    [3:0] tens;
    wire    [3:0] ones;
    wire    [1:0] s_contagem;
    wire    [3:0] s_digito_bcd;
    wire    [7:0] s_display;
    wire    [7:0] s_display_numero;
    wire    [7:0] s_display_letra;

    assign contagem_display = s_contagem;
    
    //always @(s_contagem) begin
    //    case (s_contagem)
    //       2'b00:    display[11:8] = 4'b1110; 
    //        2'b01:    display[11:8] = 4'b1101;
    //       2'b10:    display[11:8] = 4'b1011;
    //        2'b11:    display[11:8] = 4'b0111;
    //        default:  display[11:8] = 4'b0000; 
    //   endcase

    //    case (s_contagem)
    //        2'b00   : s_digito_bcd <= ones;
    //        2'b01   : s_digito_bcd <= tens;
    //        2'b10   : s_digito_bcd <= hundreds;
    //        2'b11   : s_digito_bcd = 4'b1111;
    //        default : s_digito_bcd = 4'b1111;
    //    endcase
    //end
    
    // Unificacao dos sinais de enable e dos 7 segmentos
    //always @(*) begin
    //    display[7:0]    = s_display;
    //       = enable;
    //end
    //assign display[7:0] = s_display;
	
    // Conta ate 3
    contador_m  #(.M(3), .N(2)) contador_ordem(
        .clock (clock),
        .zera_as(1'b0),
        .zera_s (1'b0),
        .conta (1'b1),
        .Q (s_contagem),
        .fim (),
        .meio () 
    );

    mux_4x1_4bits mux_dados(
	.D0(ones),
	.D1(tens),
	.D2(hundreds),
	.D3(4'hf),
	.OUT(s_digito_bcd),
	.SEL(s_contagem)
    );

    mux_4x1_4bits mux_enable(
	.D0(4'b1110),
	.D1(4'b1101),
	.D2(4'b1011),
	.D3(4'b0111),
	.OUT(display[11:8]),
	.SEL(s_contagem)
    );

    // Conversão de 8 bits para 5 dígitos BCD
    bin2bcd conversor(    
        .binary(numero),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );

    // Conversao BCD para display de 7 segmentos
    bin2sevenSeg bcd_disp(
        .bcd   (s_digito_bcd),
		  .display(s_display_numero)
    );

    // Conversao letra para display de 7 segementos

    letra2sevenSeg conv_letra(
        .letra(letra),
        .display(s_display_letra)
    );

    mux_2x1_8bits display_selector(
        .D0(s_display_numero),
        .D1(s_display_letra),
        .SEL(select),
        .OUT(display[7:0])
    );
endmodule
