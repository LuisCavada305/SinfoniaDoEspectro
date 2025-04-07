module fluxo_dados (
    
    // Sinais de Entrada
    input       clock,
    input [6:0] botoes,

    // Sinais de Controle
    input       activate_arduino,
    input       calcular_pontos,
    input [1:0] contagem_display,
    input       enable_contador_erro,
    input       enable_contador_jogada,
    input       enable_contador_msg,
    input       enable_contador_rodada,
    input       enable_registrador_botoes,
    input       enable_registrador_musica,
    input       enable_registrador_pontos,
    input       enable_timer_buzzer,
    input       enable_timer_msg,
    input       select_mux_arduino,
    input       select_mux_letra,
    input       zera_contador_erro,
    input       zera_contador_jogada,
    input       zera_contador_msg,
    input       zera_contador_rodada,
    input       zera_registrador_botoes,
    input       zera_registrador_pontos,
    input       zera_timer_buzzer,
    input       zera_timer_msg,

    // Sinais de Condição
    output          botoesIgualMemoria,
    output          enderecoIgualLimite,
    output          fimL,
    output          tem_botao_pressionado,
    output          tem_jogada,
    output          timeout_contador_buzzer,
    output          timeout_contador_msg,

    // Sinais de Saida
    output [2:0]    arduino_out,
    output [4:0]    letra,
    output [7:0]    pontos,

    // Sinais de Depuração
    output [2:0]    db_data_out_sync,
    output [3:0]    db_contagem,
    output [3:0]    db_limite,
    output [6:0]    db_jogada,
    output [6:0]    db_memoria
);

    // sinal interno para interligacao dos componentes
    wire [6:0]  s_arduino_out;
    wire [4:0]  s_contador_msg;
    wire [3:0]  s_contagem;
    wire [4:0]  s_endereco_msg;
    wire [3:0]  s_erros;
    wire [7:0]  s_erro_estendido = {4'h0,s_erros};
    wire [6:0]  s_jogada;
    wire [4:0]  s_letra_da_nota;
    wire [4:0]  s_letra_frase_inicial;
    wire [3:0]  s_limite;
    wire [6:0]  s_memoria;
    wire [2:0]  s_musica_pressionada;
    wire [6:0]  s_mux;
    wire [2:0]  s_nota_pressionada;
    wire [7:0]  s_pontos; 
    wire [7:0]  s_resultado;
    wire [2:0]  s_select_musica;
    wire        s_sinal;
    assign      s_sinal = botoes[0] | botoes[1] | botoes[2] | botoes[3] | botoes[4] | botoes[5] | botoes[6];
    assign      s_endereco_msg = s_contador_msg + 5'h03 - contagem_display;

    // ======================================================
    // Bloco de Contagem e Comparação da Sequência
    // ======================================================
    
    // Contador que marca o limite (número de jogadas na rodada)
    contador_163 ContLmt (
      .clock( clock                 ),
      .clr  ( ~zera_contador_rodada ),
      .ld   ( 1'b1                  ),
      .ent  ( 1'b1                  ),
      .enp  ( enable_contador_rodada),
      .D    ( 4'b0                  ),
      .Q    ( s_limite              ),
      .rco  ( fimL                  )
    );


    // Contador para endereçamento (endereço da memoria de jogadas)
    contador_163 ContEnd (
      .clock( clock                 ),
      .clr  ( ~zera_contador_jogada ),
      .ld   ( 1'b1                  ),
      .ent  ( 1'b1                  ),
      .enp  ( enable_contador_jogada),
      .D    ( 4'b0                  ),
      .Q    ( s_contagem            ),
      .rco  ( )
    );
    
    // Comparador para verificar se o endereço é igual ao limite
    comparador_85 CompLmt (
      .A   ( s_limite           ),
      .B   ( s_contagem         ),
      .ALBi( 1'b0               ),
      .AGBi( 1'b0               ),
      .AEBi( 1'b1               ),
      .ALBo(  ),
      .AGBo(  ),
      .AEBo( enderecoIgualLimite )
    );

    // Registrador para armazenar a jogada dos botões (7 bits)
    registrador_7 RegBotoes (
      .clock  (clock                    ),      
      .clear  (zera_registrador_botoes  ),      
      .enable (enable_registrador_botoes),     
      .D      (botoes                   ), 
      .Q      (s_jogada                 ) 
    );

   // ROMs síncronas – memórias com a sequência esperada
    memoria_notas memoria_de_musicas (
      .clock            (clock          ),
      .address          (s_contagem     ),
      .select_musica    (s_select_musica),
      .data_out         (s_memoria      )
    );
	 
    // Comparador para verificar se a jogada registrada é igual à esperada
    comparador_85_7bits CompJog (
      .A   ( s_memoria  ),
      .B   ( s_jogada   ),
      .ALBi( 1'b0       ),
      .AGBi( 1'b0       ),
      .AEBi( 1'b1       ),
      .ALBo(            ),     
      .AGBo(            ),
      .AEBo( botoesIgualMemoria )
    );

    edge_detector detector_borda (
        .clock( clock                   ),
        .reset( zera_registrador_botoes ),
        .sinal( s_sinal                 ),
        .pulso( tem_jogada              )
    );

	contador_m #(.M(500), .N(13)) contador_buzzer(
        .clock      ( clock                     ),
        .zera_as    ( 1'b0                      ),
        .zera_s     ( zera_timer_buzzer         ),
        .conta      ( enable_timer_buzzer       ),
        .Q          ( ),
        .fim        ( timeout_contador_buzzer   ),
        .meio       ( ) 
    );

    // Elementos para mostrar mensagem inicial
    contador_m #(.M(100), .N(7)) contador_timeout_mensagem(
        .clock  ( clock                 ),
        .zera_as( 1'b0                  ),
        .zera_s ( zera_timer_msg        ),
        .conta  ( enable_timer_msg      ),
        .Q      ( ),
        .fim    ( timeout_contador_msg  ),
        .meio   ( ) 
    );

    contador_m #(.M(21), .N(5)) contador_mensagem(
        .clock  ( clock                 ),
        .zera_as( 1'b0                  ),
        .zera_s ( zera_contador_msg     ),
        .conta  ( enable_contador_msg   ),
        .Q      ( s_contador_msg        ),
        .fim    ( ),
        .meio   ( ) 
    );

    memoria_frase memoria_da_frase_inicial(
        .address    ( s_endereco_msg        ),
        .data_out   ( s_letra_frase_inicial )
    );

    // Fim elementos mostrar mensagem inicial
	 
    // Contador de erros (acumula os erros durante a rodada)
    contador_163 ContErro (
        .clock( clock               ),
        .clr  ( ~zera_contador_erro ),
        .ld   ( 1'b1                ),
        .ent  ( 1'b1                ),
        .enp  ( enable_contador_erro),
        .D    ( 4'b0                ),
        .Q    ( s_erros             ),
        .rco  ( )
    );


    //Calculadora de Pontos
    calculadora_pontos calculadora_de_pontos(
        .calcular_pontos    ( calcular_pontos   ),
        .rodada             ( s_contagem        ),
        .erros              ( s_erro_estendido  ),
        .pontos_in          ( pontos            ),
        .pontos_out         ( s_resultado       )
    );

    registrador_8_init registrador_Pontos(
        .enable ( enable_registrador_pontos ),
        .clock  ( clock                     ),
        .clear  ( zera_registrador_pontos   ),
        .D      ( s_resultado               ),
        .Q      ( pontos                    )
    );

    // Conexão com o Arduino
    mux2x1_7 Arduino_sound (
        .D0 ( botoes                ),
        .D1 ( s_memoria             ),
        .SEL( select_mux_arduino    ),
        .OUT( s_arduino_out         )
    );

    arduino_connection Arduino_Play(
        .entrada    (s_arduino_out      ),
        .enable     (activate_arduino   ),
        .saida      (arduino_out        )
    );

    // Decodificador para selecao da musica
    decoder_8x3 Decodificador_musica(
        .data_in    ({1'b0,botoes}       ),
        .data_out   (s_musica_pressionada)
    );

    // Decodificador para mostrar nota no display
    decoder_8x3 Decodificador_notas(
        .data_in    ({1'b0,s_arduino_out}),
        .data_out   (s_nota_pressionada  )
    );
	 
	 registrador_3 Reg_Musica(
		  .clock    (clock                      ),
		  .clear    (1'b0                       ),
		  .enable   (enable_registrador_musica  ),
		  .D        (s_musica_pressionada       ),
		  .Q        (s_select_musica            )
	 );
     
    notas2letras decodificador_de_notas(
        .nota               (s_nota_pressionada ),
        .contagem_display   (contagem_display   ),
        .letras             (s_letra_da_nota    )
    );

    mux_2x1_5bits mux_letras(
        .D0 ( s_letra_frase_inicial ),
        .D1 ( s_letra_da_nota       ),
        .SEL( select_mux_letra      ),
        .OUT( letra                 )
    );

    // saidas de depuracao
    assign db_contagem = s_contagem;
    assign db_data_out_sync = s_select_musica;
    assign db_jogada = s_jogada;
    assign db_limite = s_limite;
    assign db_memoria = s_memoria;
    assign tem_botao_pressionado = s_sinal;
endmodule
 
module registrador_7 (
    input        clock,
    input        clear,
    input        enable,
    input  [6:0] D,
    output [6:0] Q
);

    reg [6:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule

module registrador_3 (
    input        clock,
    input        clear,
    input        enable,
    input  [2:0] D,
    output [2:0] Q
);

    reg [2:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule

// ======================================================
// MÓDULO: registrador_8_init
// ======================================================
module registrador_8_init (
    input        clock,
    input        clear,
    input        enable,
    input  [7:0] D,
    output reg [7:0] Q
);
    always @(posedge clock or posedge clear) begin
        if (clear)
            Q <= 8'd0;
        else if (enable)
            Q <= D;
    end
endmodule