module sinfonia_do_espectro (
    input         clock,
    input         reset,
    input         jogar,
    input         nivel,
    input  [6:0]  botoes,
    input         treinamento,
    output        pronto,
    output        acertou,
    output        errou,
    output [2:0] arduino_out,
    // Depuração
    output        db_jogar,
	 output        db_tem_botao_pressionado,
    output        db_botoesIgualMemoria,
    output [6:0]  db_contagem,
    output [6:0]  db_memoria,
    output [6:0]  db_limite,
    output [6:0]  db_jogada,
    output [6:0]  db_estado0,
    output [6:0]  db_estado1,
    output        db_timeout,
    output        db_clock,
    output [6:0]  leds,
    // Saída dos pontos – agora os pontos são exibidos em 3 displays de 7 segmentos
    // output [6:0]  disp_hund, // display das centenas
    // output [6:0]  disp_tens, // display das dezenas
    // output [6:0]  disp_ones  // display das unidades
    output [11:0] display
);

    // Sinais internos
    wire s_zera_registrador_botoes, s_enable_registrador_botoes, s_enable_contador_jogada, s_zera_contador_jogada, s_enable_contador_rodada, s_zera_contador_rodada, s_fimL;
    wire [3:0] s_contagem;  // Contador de endereços (4 bits)
    wire [6:0] s_jogada;
    wire [3:0] s_limite;    // Contador de limite (4 bits)
    wire [6:0] s_memoria;
    wire [4:0] s_estado;
	 wire [4:0] s_letra;
    // Agora s_pontos é de 8 bits para representar a pontuação de 0 a 255 (inicialmente 100)
    wire [7:0] s_pontos;
    wire s_enderecoIgualLimite;
    wire s_botoesIgualMemoria;
    wire s_tem_jogada;
    wire s_tem_botao_pressionado;
    wire s_jogar;
    wire s_zeraT;
    wire s_contaT;
    wire s_timeout;
    wire s_zera_timeout_buzzer;
    wire s_conta_timeout_buzzer;
    wire s_muda_nota;
    wire s_mostraJ, s_mostraB, s_mostraPontos, s_zeraPontos;
    wire s_contaErro, s_zeraErro, s_regPontos;
    wire s_sel_memoria_arduino, s_activateArdunino;
	wire s_enderecoIgualMemoria;
    wire s_calcular;
    wire s_enable_registrador_musica;
    wire s_select_mux_display;
    wire s_zera_contador_msg;
    wire s_enable_contador_msg;
    wire s_zera_timer_msg;
    wire s_enable_timer_msg;
    wire s_timeout_contador_msg;
    wire [1:0] s_contagem_display;
    wire s_select_letra;
    

    // Instância do módulo de fluxo de dados
    fluxo_dados FD(
        .clock (clock),
        .botoes (botoes),
        .zera_registrador_botoes (s_zera_registrador_botoes),
        .enable_registrador_botoes (s_enable_registrador_botoes),
        .enable_contador_jogada (s_enable_contador_jogada),
        .zera_contador_jogada (s_zera_contador_jogada),
        .enable_contador_rodada (s_enable_contador_rodada),
        .zera_contador_rodada (s_zera_contador_rodada),
        .zera_contador_msg(s_zera_contador_msg),
        .enable_contador_msg(s_enable_contador_msg),
        .zera_timer_msg(s_zera_timer_msg),
        .enable_timer_msg(s_enable_timer_msg),
        .timeout_contador_msg(s_timeout_contador_msg),
        .contagem_display(s_contagem_display),
        .enable_registrador_musica(s_enable_registrador_musica),
        .select_letra(s_select_letra),
        .enderecoIgualLimite (s_enderecoIgualMemoria),
        .botoesIgualMemoria (s_botoesIgualMemoria),
        .fimL (s_fimL),
        .fimE ( ),
        .calcular(s_calcular),
        .nivel (nivel),
        .zeraT(s_zeraT),
        .contaT(s_contaT),
        .timeout(s_timeout),
        .tem_jogada (s_tem_jogada),
        .db_limite (s_limite),
        .tem_botao_pressionado (s_tem_botao_pressionado),
        .db_contagem (s_contagem),
        .db_jogada (s_jogada),
        .db_memoria (s_memoria),
        .leds(leds),
        .zera_timeout_buzzer(s_zera_timeout_buzzer),
        .conta_timeout_buzzer(s_conta_timeout_buzzer),
        .mostraJ(s_mostraJ),
        .mostraB(s_mostraB),
        .muda_nota(s_muda_nota),
        .zeraPontos(s_zeraPontos),
        .pontos(s_pontos),
        .contaErro(s_contaErro),
        .zeraErro(s_zeraErro),
        .regPontos(s_regPontos),
		  .letra(s_letra),
        .sel_memoria_arduino (s_sel_memoria_arduino),
        .activateArduino (s_activateArdunino),
		  .arduino_out(arduino_out)
    );

    // Instância do módulo de unidade de controle
    unidade_controle UC(
        .clock (clock),
        .reset (reset),
        .jogar (s_jogar),
        .fimL (s_fimL),
        .enderecoIgualLimite (s_enderecoIgualMemoria),
        .botoesIgualMemoria (s_botoesIgualMemoria),
        .calcular(s_calcular),
        .tem_jogada (s_tem_jogada),
        .tem_botao_pressionado(s_tem_botao_pressionado),
        .zera_contador_jogada (s_zera_contador_jogada),
        .enable_contador_jogada (s_enable_contador_jogada),
        .zera_contador_rodada (s_zera_contador_rodada),
        .enable_contador_rodada (s_enable_contador_rodada),
        .zera_registrador_botoes (s_zera_registrador_botoes),
        .enable_registrador_botoes (s_enable_registrador_botoes),
        .zeraT(s_zeraT),
        .contaT(s_contaT),
        .timeout(s_timeout),
        .enable_registrador_musica(s_enable_registrador_musica),
        .zera_contador_msg(s_zera_contador_msg),
        .enable_contador_msg(s_enable_contador_msg),
        .zera_timer_msg(s_zera_timer_msg),
        .enable_timer_msg(s_enable_timer_msg),
        .timeout_contador_msg(s_timeout_contador_msg),
        .select_mux_display(s_select_mux_display),
        .select_letra(s_select_letra),
        .pronto (pronto),
        .db_estado (s_estado),
        .db_timeout(db_timeout),
        .acertou (acertou),
        .serrou (errou),
        .zera_timeout_buzzer(s_zera_timeout_buzzer),
        .conta_timeout_buzzer(s_conta_timeout_buzzer),
        .mostraJ(s_mostraJ),
        .mostraB(s_mostraB),
        .muda_nota(s_muda_nota),
        .mostraPontos(s_mostraPontos),
        .zeraPontos(s_zeraPontos),
        .contaErro(s_contaErro),
        .zeraErro(s_zeraErro),
        .regPontos(s_regPontos),
        .treinamento(treinamento),
        .sel_memoria_arduino(s_sel_memoria_arduino),
        .activateArduino (s_activateArdunino)
    );

    // Instâncias de módulos de depuração e exibição
    hexa7seg HEX0(
        .hexa (s_contagem),
        .display (db_contagem)
    );

    hexa7seg HEX4(
        .hexa (s_estado[3:0]),
        .display (db_estado0)
    );

    hexa7seg HEX5(
        .hexa ({3'b000, s_estado[4]}),
        .display (db_estado1)
    );

    hexa7seg HEX3(
        .hexa(s_limite),
        .display (db_limite)
    );

    // O módulo edge_detector gera o sinal s_jogar a partir do sinal jogar
    edge_detector detector_borda(
        .clock(clock),
        .reset(reset),
        .sinal(jogar),
        .pulso(s_jogar)
    );
    
    // Sinais de depuração adicionais
    assign db_jogar = jogar;
    assign db_botoesIgualMemoria = s_botoesIgualMemoria;
	 assign db_tem_botao_pressionado = s_tem_botao_pressionado;
    assign db_clock = clock;
	assign db_memoria = s_memoria;
	assign db_jogada = s_jogada;

    // Instancia o novo módulo display_pontos para exibir os pontos em 3 displays de 7 segmentos.
    // display_pontos DP (
    //     .pontos(s_pontos),
    //     .enable(s_mostraPontos),
    //     .disp_hundreds(disp_hund),
    //     .disp_tens(disp_tens),
    //     .disp_ones(disp_ones)
    // );
    
    conversor7seg convPontos (
        .clock		(clock),
        .numero	(s_pontos),
        .select (s_select_mux_display),
		  .letra		(s_letra),
        .contagem_display(s_contagem_display),
        .display 	(display)
    );

endmodule
