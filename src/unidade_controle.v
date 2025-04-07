module unidade_controle (
    // Sinais de Entrada
    input      clock,
    input      reset,
    input      jogar,

    // Sinais de Condicao
    input      botoesIgualMemoria,
    input      enderecoIgualLimite,
    input      fimL,
    input      muda_nota,
    input      tem_botao_pressionado,
    input      tem_jogada,
    input      timeout_contador_msg,
    input      treinamento,

    // Sinais de Controle
    output reg          acertou,
    output reg          activateArduino,
    output reg          calcular,
    output reg          conta_timeout_buzzer,
    output reg          contaErro,
    output reg [4:0]    db_estado,
    output reg          enable_contador_jogada,
    output reg          enable_contador_msg,
    output reg          enable_contador_rodada,
    output reg          enable_registrador_botoes,
    output reg          enable_registrador_musica,
    output reg          enable_timer_msg, 
    output reg          mostraB,
    output reg          mostraJ,
    output reg          mostraPontos,
    output reg          pronto,
    output reg          regPontos,
    output reg          select_mux_display,
    output reg          select_letra,
    output reg          serrou,
    output reg          sel_memoria_arduino,
    output reg          zera_contador_display,
    output reg          zera_contador_jogada,
    output reg          zera_contador_msg,
    output reg          zera_contador_rodada,
    output reg          zera_registrador_botoes,
    output reg          zera_timer_msg,
    output reg          zera_timeout_buzzer,
    output reg          zeraErro,
    output reg          zeraPontos
);

    //=============================================================
    // Definição dos estados
    //=============================================================
    parameter inicial        = 5'b00000; // 00
    parameter mostrar_msg    = 5'b10011; // 13
    parameter prox_letra     = 5'b10100; // 14
    parameter registra_musica= 5'b10101; // 15
    parameter preparacao     = 5'b00001; // 01
    parameter modo_treino    = 5'b10110; // 16
    parameter toca_nota      = 5'b00111; // 07
    parameter comparaJ       = 5'b01000; // 08
    parameter incrementaE    = 5'b01001; // 09
    parameter preparaE       = 5'b01100; // 0C
    parameter espera_jogada  = 5'b00011; // 03
    parameter registra       = 5'b00100; // 04
    parameter espera_soltar  = 5'b10010; // 12
    parameter comparacao     = 5'b00101; // 05
    parameter errou          = 5'b01110; // 0E
    parameter proximo        = 5'b00110; // 06
    parameter fim_rodada     = 5'b01011; // 0B
    parameter calc_pontos    = 5'b10000; // 10
    parameter salva_pontos   = 5'b10001; // 11
    parameter prox_rodada    = 5'b00010; // 02
    parameter fim_acertou    = 5'b01010; // 0A

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
            mostrar_msg     : Eprox = tem_jogada ? registra_musica : (timeout_contador_msg ? prox_letra : mostrar_msg);
            prox_letra      : Eprox = mostrar_msg;
            registra_musica : Eprox = preparacao;
            preparacao      : Eprox = treinamento ? modo_treino : toca_nota;
            toca_nota       : Eprox = muda_nota ? comparaJ : toca_nota;
            comparaJ        : Eprox = enderecoIgualLimite ? preparaE : (muda_nota ? incrementaE : comparaJ);
            preparaE        : Eprox = espera_jogada;
            incrementaE     : Eprox = toca_nota;
            espera_jogada   : Eprox = (tem_jogada ? registra : espera_jogada);
            registra        : Eprox = espera_soltar;
            espera_soltar   : Eprox = tem_botao_pressionado ? espera_soltar : comparacao;
            comparacao      : Eprox = (!botoesIgualMemoria) ? errou : (enderecoIgualLimite ? fim_rodada : proximo);
            proximo         : Eprox = espera_jogada;
            fim_rodada      : Eprox = muda_nota ? calc_pontos : fim_rodada;
            prox_rodada     : Eprox = toca_nota;
            errou           : Eprox = toca_nota;
            fim_acertou     : Eprox = jogar ? mostrar_msg : fim_acertou;
            // Fase de cálculo dos pontos
            calc_pontos     : Eprox = salva_pontos;
            salva_pontos    : Eprox = fimL ? fim_acertou : prox_rodada;
            modo_treino     : Eprox = treinamento ? modo_treino : inicial;
            default         : Eprox = inicial;
        endcase
    end

    //=============================================================
    // Lógica de saída (FSM – Moore)
    //=============================================================
    always @* begin
        acertou                     = (Eatual == fim_acertou) ? 1'b1 : 1'b0;
        activateArduino             = (Eatual == inicial || Eatual == preparacao) ? 1'b0 : 1'b1;
        calcular                    = (Eatual == calc_pontos) ? 1'b1 : 1'b0;
        conta_timeout_buzzer        = (Eatual == toca_nota || Eatual == incrementaE || Eatual == comparaJ || Eatual == fim_rodada) ? 1'b1 : 1'b0;
        contaErro                   = (Eatual == errou) ? 1'b1 : 1'b0;
        enable_contador_jogada      = (Eatual == proximo || Eatual == incrementaE) ? 1'b1 : 1'b0;
        enable_contador_msg         = (Eatual == prox_letra) ? 1'b1 : 1'b0;
        enable_contador_rodada      = (Eatual == prox_rodada) ? 1'b1 : 1'b0;
        enable_registrador_botoes   = (Eatual == registra) ? 1'b1 : 1'b0;
        enable_registrador_musica   = (Eatual == registra_musica) ? 1'b1 : 1'b0;
        enable_timer_msg            = (Eatual == mostrar_msg) ? 1'b1 : 1'b0;
        mostraB                     = (Eatual == espera_jogada || Eatual == registra || Eatual == comparacao || Eatual == fim_rodada || Eatual == modo_treino) ? 1'b1 : 1'b0;
        mostraJ                     = (Eatual == toca_nota) ? 1'b1 : 1'b0;
        mostraPontos                = (Eatual == inicial || Eatual == preparacao || Eatual == modo_treino) ? 1'b0 : 1'b1;
        pronto                      = (Eatual == fim_acertou ) ? 1'b1 : 1'b0;
        regPontos                   = (Eatual == salva_pontos) ? 1'b1 : 1'b0;
        sel_memoria_arduino         = (Eatual == toca_nota) ? 1'b1 : 1'b0;
        select_letra                = (Eatual == registra ||Eatual == espera_soltar || Eatual == toca_nota)? 1'b1 : 1'b0;
        select_mux_display          = (Eatual == mostrar_msg || Eatual == espera_soltar || Eatual == toca_nota) ? 1'b1 : 1'b0;
        serrou                      = (Eatual == errou) ? 1'b1 : 1'b0;
        zera_contador_display       = (Eatual == inicial)? 1'b1 : 1'b0;
        zera_contador_jogada        = (Eatual == preparacao || Eatual == prox_rodada || Eatual == preparaE || Eatual == errou) ? 1'b1 : 1'b0;
        zera_contador_msg           = (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0; 
        zera_contador_rodada        = (Eatual == preparacao) ? 1'b1 : 1'b0;
        zera_registrador_botoes     = (Eatual == preparacao) ? 1'b1 : 1'b0;
        zera_timer_msg              = (Eatual == prox_letra || Eatual == inicial) ? 1'b1 : 1'b0;
        zera_timeout_buzzer         = (Eatual == preparacao || Eatual == prox_rodada || Eatual == comparacao || Eatual == errou) ? 1'b1 : 1'b0;
        zeraErro                    = (Eatual == preparacao || Eatual == prox_rodada) ? 1'b1 : 1'b0;
        zeraPontos                  = (Eatual == inicial ||Eatual == preparacao || Eatual == mostrar_msg) ? 1'b1 : 1'b0;

        //=============================================================
        // Saída de depuração: db_estado
        //=============================================================
        case (Eatual)
            inicial         : db_estado = 5'b00000; // 00
            preparacao      : db_estado = 5'b00001; // 01
            toca_nota       : db_estado = 5'b00111; // 07
            comparaJ        : db_estado = 5'b01000; // 08
            incrementaE     : db_estado = 5'b01001; // 09
            espera_jogada   : db_estado = 5'b00011; // 03
            registra        : db_estado = 5'b00100; // 04
            espera_soltar   : db_estado = 5'b10010; // 12
            comparacao      : db_estado = 5'b00101; // 05
            proximo         : db_estado = 5'b00110; // 06
            fim_rodada      : db_estado = 5'b01011; // 0B
            preparaE        : db_estado = 5'b01100; // 0C
            prox_rodada     : db_estado = 5'b00010; // 02
            errou           : db_estado = 5'b01110; // 0E
            fim_acertou     : db_estado = 5'b01010; // 0A
            calc_pontos     : db_estado = 5'b10000; // 10
            salva_pontos    : db_estado = 5'b10001; // 11
            modo_treino     : db_estado = 5'b10110; // 16
            mostrar_msg     : db_estado = 5'b10011; // 13
            prox_letra      : db_estado = 5'b10100; // 14
            registra_musica : db_estado = 5'b10101; // 15
            default         : db_estado = 5'b01111; // 0F
        endcase
    end

endmodule
