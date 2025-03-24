module circuito_S1 (
    input         clock,
    input         reset,
    input         jogar,
    input         memoria,
    input         nivel,
    input  [6:0]  botoes,
    input         treinamento,
    output        pronto,
    output        acertou,
    output        errou,
    output [2:0] arduino_out,
    // Depuração
    output        db_jogar,
    output        db_botoesIgualMemoria,
    output        db_tem_jogada,
    output [6:0]  db_contagem,
    output [6:0]  db_memoria,
    output [6:0]  db_limite,
    output [6:0]  db_jogadafeita,
    output [6:0]  db_estado,
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
    wire s_zeraR, s_registraR, s_contaE, s_zeraE, s_contaL, s_zeraL, s_fimL;
    wire [3:0] s_contagem;  // Contador de endereços (4 bits)
    wire [6:0] s_jogada;
    wire [3:0] s_limite;    // Contador de limite (4 bits)
    wire [6:0] s_memoria;
    wire [4:0] s_estado;
    // Agora s_pontos é de 8 bits para representar a pontuação de 0 a 255 (inicialmente 100)
    wire [6:0] s_pontos;
    wire s_enderecoIgualLimite;
    wire s_botoesIgualMemoria;
    wire s_jogadafeita;
    wire s_jogar;
    wire s_zeraT;
    wire s_contaT;
    wire s_timeout;
    wire s_zeraT2;
    wire s_contaT2;
    wire s_muda_nota;
    wire s_mostraJ, s_mostraB, s_mostraPontos, s_zeraPontos;
    wire s_contaErro, s_zeraErro, s_regPontos;
    wire s_sel_memoria_arduino, s_activateArdunino;

    // Instância do módulo de fluxo de dados
    S1_fluxo_dados FD(
        .clock (clock),
        .botoes (botoes),
        .zeraR (s_zeraR),
        .registraR (s_registraR),
        .contaE (s_contaE),
        .zeraE (s_zeraE),
        .contaL (s_contaL),
        .zeraL (s_zeraL),
        .enderecoIgualLimite (s_enderecoIgualMemoria),
        .botoesIgualMemoria (s_botoesIgualMemoria),
        .fimL (s_fimL),
        .fimE ( ),
        .memoria (memoria),
        .nivel (nivel),
        .zeraT(s_zeraT),
        .contaT(s_contaT),
        .timeout(s_timeout),
        .jogadafeita (s_jogadafeita),
        .db_limite (s_limite),
        .db_temjogada (db_tem_jogada),
        .db_contagem (s_contagem),
        .db_jogada (s_jogada),
        .db_memoria (s_memoria),
        .leds(leds),
        .zeraT2(s_zeraT2),
        .contaT2(s_contaT2),
        .mostraJ(s_mostraJ),
        .mostraB(s_mostraB),
        .muda_nota(s_muda_nota),
        .zeraPontos(s_zeraPontos),
        .pontos(s_pontos),
        .contaErro(s_contaErro),
        .zeraErro(s_zeraErro),
        .regPontos(s_regPontos),
        .sel_memoria_arduino (s_sel_memoria_arduino),
        .activateArduino (s_activateArdunino),
		.arduino_out(arduino_out)
    );

    // Instância do módulo de unidade de controle
    S1_unidade_controle UC(
        .clock (clock),
        .reset (reset),
        .jogar (s_jogar),
        .fimL (s_fimL),
        .enderecoIgualLimite (s_enderecoIgualMemoria),
        .botoesIgualMemoria (s_botoesIgualMemoria),
        .jogada (s_jogadafeita),
        .zeraE (s_zeraE),
        .contaE (s_contaE),
        .zeraL (s_zeraL),
        .contaL (s_contaL),
        .zeraR (s_zeraR),
        .registraR (s_registraR),
        .zeraT(s_zeraT),
        .contaT(s_contaT),
        .timeout(s_timeout),
        .pronto (pronto),
        .db_estado (s_estado),
        .db_timeout(db_timeout),
        .acertou (acertou),
        .serrou (errou),
        .zeraT2(s_zeraT2),
        .contaT2(s_contaT2),
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

    estado7seg HEX5(
        .estado (s_estado),
        .display (db_estado)
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
    assign db_clock = clock;

    // Instancia o novo módulo display_pontos para exibir os pontos em 3 displays de 7 segmentos.
    // display_pontos DP (
    //     .pontos(s_pontos),
    //     .enable(s_mostraPontos),
    //     .disp_hundreds(disp_hund),
    //     .disp_tens(disp_tens),
    //     .disp_ones(disp_ones)
    // );
    
    conversor7seg convPontos (
        .clock(clock),
        .pontos(s_pontos),
        .disp7 (display)
    );

endmodule
