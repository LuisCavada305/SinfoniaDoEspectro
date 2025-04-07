module unidade_controle (
    // Sinais de Entrada
    input      clock,
    input      reset,
    input      jogar,

    // Sinais de Condicao
    input      botoesIgualMemoria,
    input      enderecoIgualLimite,
    input      fimL,
    input      tem_botao_pressionado,
    input      tem_jogada,
    input      timeout_contador_buzzer,
    input      timeout_contador_msg,
    input      treinamento,

    // Sinais de Controle
    output reg          acertou,
    output reg          activate_arduino,
    output reg          calcular_pontos,
    output reg [4:0]    db_estado,
    output reg          enable_contador_erro,
    output reg          enable_contador_jogada,
    output reg          enable_contador_msg,
    output reg          enable_contador_rodada,
    output reg          enable_registrador_botoes,
    output reg          enable_registrador_musica,
    output reg          enable_registrador_pontos,
    output reg          enable_timer_buzzer,
    output reg          enable_timer_msg, 
    output reg          errou,
    output reg          mostraPontos,
    output reg          pronto,
    output reg          select_mux_display,
    output reg          select_mux_letra,
    output reg          select_mux_arduino,
    output reg          zera_contador_display,
    output reg          zera_contador_erro,
    output reg          zera_contador_jogada,
    output reg          zera_contador_msg,
    output reg          zera_contador_rodada,
    output reg          zera_registrador_botoes,
    output reg          zera_registrador_pontos,
    output reg          zera_timer_msg,
    output reg          zera_timer_buzzer
);

    //=============================================================
    // Definição dos estados
    //=============================================================
    parameter inicial        = 5'b00000; // 00
    parameter mostrar_msg    = 5'b00001; // 01
    parameter proxima_letra  = 5'b00010; // 02
    parameter registra_musica= 5'b00011; // 03
    parameter preparacao     = 5'b00100; // 04
    parameter modo_treino    = 5'b00101; // 05
    parameter toca_nota      = 5'b00110; // 06
    parameter comparaJ       = 5'b00111; // 07
    parameter incrementaE    = 5'b01000; // 08
    parameter preparaE       = 5'b01001; // 09
    parameter espera_jogada  = 5'b01010; // 0A
    parameter registra_jogada= 5'b01011; // 0B
    parameter espera_soltar  = 5'b01100; // 0C
    parameter comparacao     = 5'b01101; // 0D
    parameter erro           = 5'b01110; // 0E
    parameter proximo        = 5'b01111; // 0F
    parameter fim_rodada     = 5'b10000; // 10
    parameter calc_pontos    = 5'b10001; // 11
    parameter salva_pontos   = 5'b10010; // 12
    parameter proxima_rodada = 5'b10011; // 13
    parameter fim_acertou    = 5'b10100; // 14

    //=============================================================
    // Variáveis de estado
    //=============================================================
    reg [4:0] Eatual, Eprox;

    //=============================================================
    // Memória de estado
    //=============================================================
    always @(posedge clock or posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox;
    end

    //=============================================================
    // Lógica de transição de estados
    //=============================================================
    always @* begin
        case (Eatual)
            inicial         : Eprox = jogar ? mostrar_msg : inicial;
            mostrar_msg     : Eprox = tem_jogada ? registra_musica : (timeout_contador_msg ? proxima_letra : mostrar_msg);
            proxima_letra   : Eprox = mostrar_msg;
            registra_musica : Eprox = preparacao;
            preparacao      : Eprox = treinamento ? modo_treino : toca_nota;
            toca_nota       : Eprox = timeout_contador_buzzer ? comparaJ : toca_nota;
            comparaJ        : Eprox = enderecoIgualLimite ? preparaE : (timeout_contador_buzzer ? incrementaE : comparaJ);
            preparaE        : Eprox = espera_jogada;
            incrementaE     : Eprox = toca_nota;
            espera_jogada   : Eprox = (tem_jogada ? registra_jogada : espera_jogada);
            registra_jogada : Eprox = espera_soltar;
            espera_soltar   : Eprox = tem_botao_pressionado ? espera_soltar : comparacao;
            comparacao      : Eprox = (!botoesIgualMemoria) ? erro : (enderecoIgualLimite ? fim_rodada : proximo);
            proximo         : Eprox = espera_jogada;
            fim_rodada      : Eprox = timeout_contador_buzzer ? calc_pontos : fim_rodada;
            proxima_rodada  : Eprox = toca_nota;
            erro            : Eprox = toca_nota;
            fim_acertou     : Eprox = jogar ? mostrar_msg : fim_acertou;
            // Fase de cálculo dos pontos
            calc_pontos     : Eprox = salva_pontos;
            salva_pontos    : Eprox = fimL ? fim_acertou : proxima_rodada;
            modo_treino     : Eprox = treinamento ? modo_treino : inicial;
            default         : Eprox = inicial;
        endcase
    end

    //=============================================================
    // Lógica de saída (FSM – Moore)
    //=============================================================
    always @* begin
        acertou                     = (Eatual == fim_acertou) ? 1'b1 : 1'b0;
        activate_arduino            = (Eatual == inicial || Eatual == preparacao) ? 1'b0 : 1'b1;
        calcular_pontos             = (Eatual == calc_pontos) ? 1'b1 : 1'b0;
        enable_timer_buzzer         = (Eatual == toca_nota || Eatual == incrementaE || Eatual == comparaJ || Eatual == fim_rodada) ? 1'b1 : 1'b0;
        enable_contador_erro        = (Eatual == erro) ? 1'b1 : 1'b0;
        enable_contador_jogada      = (Eatual == proximo || Eatual == incrementaE) ? 1'b1 : 1'b0;
        enable_contador_msg         = (Eatual == proxima_letra) ? 1'b1 : 1'b0;
        enable_contador_rodada      = (Eatual == proxima_rodada) ? 1'b1 : 1'b0;
        enable_registrador_botoes   = (Eatual == registra_jogada) ? 1'b1 : 1'b0;
        enable_registrador_musica   = (Eatual == registra_musica) ? 1'b1 : 1'b0;
        enable_timer_msg            = (Eatual == mostrar_msg) ? 1'b1 : 1'b0;
        mostraPontos                = (Eatual == inicial || Eatual == preparacao || Eatual == modo_treino) ? 1'b0 : 1'b1;
        pronto                      = (Eatual == fim_acertou ) ? 1'b1 : 1'b0;
        enable_registrador_pontos   = (Eatual == salva_pontos) ? 1'b1 : 1'b0;
        select_mux_arduino          = (Eatual == toca_nota) ? 1'b1 : 1'b0;
        select_mux_letra            = (Eatual == registra_jogada ||Eatual == espera_soltar || Eatual == toca_nota)? 1'b1 : 1'b0;
        select_mux_display          = (Eatual == mostrar_msg || Eatual == espera_soltar || Eatual == toca_nota) ? 1'b1 : 1'b0;
        errou                       = (Eatual == erro) ? 1'b1 : 1'b0;
        zera_contador_display       = (Eatual == inicial)? 1'b1 : 1'b0;
        zera_contador_jogada        = (Eatual == preparacao || Eatual == proxima_rodada || Eatual == preparaE || Eatual == erro) ? 1'b1 : 1'b0;
        zera_contador_msg           = (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0; 
        zera_contador_rodada        = (Eatual == preparacao) ? 1'b1 : 1'b0;
        zera_registrador_botoes     = (Eatual == preparacao) ? 1'b1 : 1'b0;
        zera_timer_msg              = (Eatual == proxima_letra || Eatual == inicial) ? 1'b1 : 1'b0;
        zera_timer_buzzer           = (Eatual == preparacao || Eatual == proxima_rodada || Eatual == comparacao || Eatual == erro) ? 1'b1 : 1'b0;
        zera_contador_erro          = (Eatual == preparacao || Eatual == proxima_rodada) ? 1'b1 : 1'b0;
        zera_registrador_pontos     = (Eatual == inicial ||Eatual == preparacao || Eatual == mostrar_msg) ? 1'b1 : 1'b0;

        //=============================================================
        // Saída de depuração: db_estado
        //=============================================================
        case (Eatual)
            inicial         : db_estado = 5'b00000; // 00
            mostrar_msg     : db_estado = 5'b00001; // 01
            proxima_letra   : db_estado = 5'b00010; // 02
            registra_musica : db_estado = 5'b00011; // 03
            preparacao      : db_estado = 5'b00100; // 04
            modo_treino     : db_estado = 5'b00101; // 05
            toca_nota       : db_estado = 5'b00110; // 06
            comparaJ        : db_estado = 5'b00111; // 07
            incrementaE     : db_estado = 5'b01000; // 08
            preparaE        : db_estado = 5'b01001; // 09
            espera_jogada   : db_estado = 5'b01010; // 0A
            registra_jogada : db_estado = 5'b01011; // 0B
            espera_soltar   : db_estado = 5'b01100; // 0C
            comparacao      : db_estado = 5'b01101; // 0D
            erro            : db_estado = 5'b01110; // 0E
            proximo         : db_estado = 5'b01111; // 0F
            fim_rodada      : db_estado = 5'b10000; // 10
            calc_pontos     : db_estado = 5'b10001; // 11
            salva_pontos    : db_estado = 5'b10010; // 12
            proxima_rodada  : db_estado = 5'b10011; // 13
            fim_acertou     : db_estado = 5'b10100; // 14
            default         : db_estado = 5'b10101; // 15
        endcase
    end

endmodule
