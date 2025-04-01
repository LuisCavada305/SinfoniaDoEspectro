module unidade_controle (
    input      clock,    // clock do sistema
    input      reset,    // reset assíncrono
    input      jogar,    // sinal para iniciar o jogo
    input      fimL,     // sinal que indica que o contador de limite atingiu seu valor máximo (fim da contagem da rodada ou fim do jogo)
    input      botoesIgualMemoria,  // resultado da comparação entre a jogada e a sequência armazenada
    input      enderecoIgualLimite, // indica se o endereço (contagem) atingiu o limite esperado
    input      tem_jogada,   // sinal que indica que a jogada foi efetivada (detectada a borda)
    input      timeout,  // sinal de tempo esgotado
    input      muda_nota,// sinal que indica que os LEDs já foram atualizados
    input      treinamento,
    input      tem_botao_pressionado,
    input      timeout_contador_msg,
    output reg zeraT,     // zera temporizador T
    output reg contaT,    // conta temporizador T
    output reg zera_contador_jogada,     // zera o contador de endereços (usado na leitura da memória)
    output reg enable_contador_jogada,    // incrementa o contador de endereços
    output reg zera_contador_rodada,     // zera o contador de limite (que marca o tamanho da sequência ou o número da rodada)
    output reg enable_contador_rodada,    // incrementa o contador de limite
    output reg zera_registrador_botoes,     // zera o registrador de jogada
    output reg enable_registrador_botoes, // habilita o registrador de jogada
    output reg enable_registrador_musica,
    output reg select_mux_display,
    output reg select_letra,
    output reg zera_contador_msg,
    output reg enable_contador_msg,
    output reg zera_timer_msg,
    output reg enable_timer_msg, 
    output reg pronto,    // sinal que indica que o jogo terminou (por acerto ou timeout)
    output reg [4:0] db_estado,  // para depuração: exibe o estado atual da FSM
    output reg acertou,   // sinaliza que a rodada foi concluída sem erros
    output reg serrou,    // sinaliza que houve erro na jogada
    output reg db_timeout,// depuração: indica timeout
    output reg mostraJ,   // controla a exibição dos LEDs (modo “jogada”)
    output reg mostraB,   // controla a exibição dos botões (modo “botão”)
    output reg zera_timeout_buzzer,    // zera temporizador T2 (para atualização dos LEDs)
    output reg conta_timeout_buzzer,   // incrementa temporizador T2
    output reg mostraPontos, // ativa a exibição dos pontos
    output reg contaErro, // incrementa o contador de erros
    output reg zeraErro,  // zera o contador de erros
    output reg zeraPontos,// clear no registrador de pontos (inicia com 100)
    output reg regPontos,  // atualiza o registrador de pontos com o novo valor parcial
    output reg sel_memoria_arduino,
    output reg activateArduino,
    output reg calcular
);

    //=============================================================
    // Definição dos estados
    //=============================================================
    parameter inicial        = 5'b00000; // 0
    parameter preparacao     = 5'b00001; // 1
    parameter espera_jogada  = 5'b00011; // 3
    parameter registra       = 5'b00100; // 4
    parameter espera_soltar  = 5'b10010; // 12
    parameter comparacao     = 5'b00101; // 5
    parameter proximo        = 5'b00110; // 6
    parameter toca_nota      = 5'b00111; // 7
    parameter comparaJ       = 5'b01000; // 8
    parameter incrementaE    = 5'b01001; // 9
    parameter preparaE       = 5'b01100; // C
    parameter fim_rodada     = 5'b01011; // B
    parameter prox_rodada    = 5'b00010; // 2
    parameter errou          = 5'b01110; // E
    parameter fim_acertou    = 5'b01010; // A
    parameter fim_timeout    = 5'b01101; // D
    parameter calc_pontos    = 5'b10000; // 10
    parameter salva_pontos   = 5'b10001; // 11
    parameter modo_treino    = 5'b10110; // 16
    parameter mostrar_msg    = 5'b10011; // 13
    parameter prox_letra     = 5'b10100; // 14
    parameter registra_musica= 5'b10101; // 15

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
            inicial       : Eprox = jogar ? mostrar_msg : inicial;
            mostrar_msg   : Eprox = tem_jogada ? registra_musica : (timeout_contador_msg ? prox_letra : mostrar_msg);
            prox_letra    : Eprox = mostrar_msg;
            registra_musica: Eprox = preparacao;
            preparacao    : Eprox = treinamento ? modo_treino : toca_nota;
            toca_nota     : Eprox = muda_nota ? comparaJ : toca_nota;
            comparaJ      : Eprox = enderecoIgualLimite ? preparaE : (muda_nota ? incrementaE : comparaJ);
            preparaE      : Eprox = espera_jogada;
            incrementaE   : Eprox = toca_nota;
            espera_jogada : Eprox = (tem_jogada ? registra : espera_jogada);
            registra      : Eprox = espera_soltar;
            espera_soltar : Eprox = tem_botao_pressionado ? espera_soltar : comparacao;
            comparacao    : Eprox = (!botoesIgualMemoria) ? errou : (enderecoIgualLimite ? fim_rodada : proximo);
            proximo       : Eprox = espera_jogada;
            fim_rodada    : Eprox = muda_nota ? calc_pontos : fim_rodada;
            prox_rodada   : Eprox = toca_nota;
            errou         : Eprox = toca_nota;
            fim_acertou   : Eprox = jogar ? preparacao : fim_acertou;
            fim_timeout   : Eprox = jogar ? preparacao : fim_timeout;
            // Fase de cálculo dos pontos
            calc_pontos   : Eprox = salva_pontos;      // Espera um ciclo para estabilizar os valores
            salva_pontos  : Eprox = fimL ? fim_acertou : prox_rodada;  // Se ContLmt atingiu fim, vai para fim_acertou; caso contrário, avança para próxima posição
            modo_treino   : Eprox = treinamento ? modo_treino : inicial;
            default       : Eprox = inicial;
        endcase
    end

    //=============================================================
    // Lógica de saída (FSM – Moore)
    //=============================================================
    always @* begin
        // Zera o contador de endereços (usado na leitura da ROM)
        zera_contador_jogada     = (Eatual == preparacao || Eatual == prox_rodada || Eatual == preparaE || Eatual == errou) ? 1'b1 : 1'b0;
        // Zera o registrador de jogada
        zera_registrador_botoes     = (Eatual == preparacao) ? 1'b1 : 1'b0;
        // Zera o contador de limite
        zera_contador_rodada     = (Eatual == preparacao) ? 1'b1 : 1'b0;
        // Habilita o registrador de jogada
        enable_registrador_botoes = (Eatual == registra) ? 1'b1 : 1'b0;
        // Incrementa o contador de endereços
        enable_contador_jogada    = (Eatual == proximo || Eatual == incrementaE) ? 1'b1 : 1'b0;
        // Incrementa o contador de limite
        enable_contador_rodada    = (Eatual == prox_rodada) ? 1'b1 : 1'b0;
        // O jogo está pronto (terminado) quando chega em fim_acertou ou fim_timeout
        pronto    = (Eatual == fim_acertou || Eatual == fim_timeout) ? 1'b1 : 1'b0;
        // Acertou se terminou sem erros
        acertou   = (Eatual == fim_acertou) ? 1'b1 : 1'b0;
        // Sinaliza erro na jogada
        serrou    = (Eatual == errou) ? 1'b1 : 1'b0;
        // Zera temporizador T
        zeraT     = (Eatual == preparacao || Eatual == proximo || Eatual == prox_rodada) ? 1'b1 : 1'b0;
        // Temporizador T atua na espera de jogada
        contaT    = (Eatual == espera_jogada) ? 1'b1 : 1'b0;
        // Depuração: timeout ativo em fim_timeout
        db_timeout = (Eatual == fim_timeout) ? 1'b1 : 1'b0;
        // Zera temporizador T2
        zera_timeout_buzzer    = (Eatual == preparacao || Eatual == prox_rodada || Eatual == comparacao || Eatual == errou) ? 1'b1 : 1'b0;
        // Conta temporizador T2
        conta_timeout_buzzer   = (Eatual == toca_nota || Eatual == incrementaE || Eatual == comparaJ || Eatual == fim_rodada) ? 1'b1 : 1'b0;
        // Exibe os LEDs da sequência
        mostraJ   = (Eatual == toca_nota) ? 1'b1 : 1'b0;
        // Exibe o conteúdo dos botões (quando apropriado)
        mostraB   = (Eatual == espera_jogada || Eatual == registra || Eatual == comparacao || Eatual == fim_rodada || Eatual == modo_treino) ? 1'b1 : 1'b0;
        // Ativa a exibição dos pontos
        mostraPontos = (Eatual == inicial || Eatual == preparacao || Eatual == modo_treino) ? 1'b0 : 1'b1;
        // Zera o contador de erros (usado para registrar os erros da rodada)
        zeraErro  = (Eatual == preparacao || Eatual == prox_rodada) ? 1'b1 : 1'b0;
        // Incrementa o contador de erros
        contaErro = (Eatual == errou) ? 1'b1 : 1'b0;
        zeraPontos = (Eatual == inicial ||Eatual == preparacao) ? 1'b1 : 1'b0;
        // Atualiza o registrador de pontos (RegPontos) somente em salva_pontos
        regPontos  = (Eatual == salva_pontos) ? 1'b1 : 1'b0;
        // Seleciona a saída que vai para o arduino
        sel_memoria_arduino = (Eatual == toca_nota) ? 1'b1 : 1'b0;
        // Ativa a saída para o Arduino
        activateArduino = (Eatual == inicial || Eatual == preparacao) ? 1'b0 : 1'b1;
        calcular = (Eatual == calc_pontos) ? 1'b1 : 1'b0;
        zera_contador_msg = (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0; 
        enable_contador_msg = (Eatual == prox_letra) ? 1'b1 : 1'b0;
        enable_registrador_musica = (Eatual == registra_musica) ? 1'b1 : 1'b0;
        select_mux_display = (Eatual == mostrar_msg || Eatual == espera_soltar || Eatual == toca_nota) ? 1'b1 : 1'b0;
        zera_timer_msg = (Eatual == prox_letra) ? 1'b1 : 1'b0;
        enable_timer_msg = (Eatual == mostrar_msg) ? 1'b1 : 1'b0;
        select_letra = (Eatual == registra ||Eatual == espera_soltar || Eatual == toca_nota)? 1'b1 : 1'b0;

        //=============================================================
        // Saída de depuração: db_estado
        //=============================================================
        case (Eatual)
            inicial      : db_estado = 5'b00000; // 0
            preparacao   : db_estado = 5'b00001; // 1
            toca_nota    : db_estado = 5'b00111; // 7
            comparaJ     : db_estado = 5'b01000; // 8
            incrementaE  : db_estado = 5'b01001; // 9
            espera_jogada: db_estado = 5'b00011; // 3
            registra     : db_estado = 5'b00100; // 4
            espera_soltar: db_estado = 5'b10010; // 12
            comparacao   : db_estado = 5'b00101; // 5
            proximo      : db_estado = 5'b00110; // 6
            fim_rodada   : db_estado = 5'b01011; // B
            preparaE     : db_estado = 5'b01100; // C
            prox_rodada  : db_estado = 5'b00010; // 2
            errou        : db_estado = 5'b01110; // E
            fim_acertou  : db_estado = 5'b01010; // A
            fim_timeout  : db_estado = 5'b01101; // D
            calc_pontos  : db_estado = 5'b10000; // 10
            salva_pontos : db_estado = 5'b10001; // 11
            modo_treino    : db_estado = 5'b10110; // 16
            mostrar_msg    : db_estado = 5'b10011; // 13
            prox_letra     : db_estado = 5'b10100; // 14
            registra_musica: db_estado = 5'b10101; // 15
            default      : db_estado = 5'b01111; // F

        endcase
    end

endmodule
