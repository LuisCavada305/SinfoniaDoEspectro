module S1_unidade_controle (
    input      clock,    // clock do sistema
    input      reset,    // reset assíncrono
    input      jogar,    // sinal para iniciar o jogo
    input      fimL,     // sinal que indica que o contador de limite atingiu seu valor máximo (fim da contagem da rodada ou fim do jogo)
    input      botoesIgualMemoria,  // resultado da comparação entre a jogada e a sequência armazenada
    input      enderecoIgualLimite, // indica se o endereço (contagem) atingiu o limite esperado
    input      jogada,   // sinal que indica que a jogada foi efetivada (detectada a borda)
    input      timeout,  // sinal de tempo esgotado
    input      muda_leds,// sinal que indica que os LEDs já foram atualizados
    output reg zeraT,     // zera temporizador T
    output reg contaT,    // conta temporizador T
    output reg zeraE,     // zera o contador de endereços (usado na leitura da memória)
    output reg contaE,    // incrementa o contador de endereços
    output reg zeraL,     // zera o contador de limite (que marca o tamanho da sequência ou o número da rodada)
    output reg contaL,    // incrementa o contador de limite
    output reg zeraR,     // zera o registrador de jogada
    output reg registraR, // habilita o registrador de jogada
    output reg pronto,    // sinal que indica que o jogo terminou (por acerto ou timeout)
    output reg [4:0] db_estado,  // para depuração: exibe o estado atual da FSM
    output reg acertou,   // sinaliza que a rodada foi concluída sem erros
    output reg serrou,    // sinaliza que houve erro na jogada
    output reg db_timeout,// depuração: indica timeout
    output reg mostraJ,   // controla a exibição dos LEDs (modo “jogada”)
    output reg mostraB,   // controla a exibição dos botões (modo “botão”)
    output reg zeraT2,    // zera temporizador T2 (para atualização dos LEDs)
    output reg contaT2,   // incrementa temporizador T2
    output reg mostraPontos, // ativa a exibição dos pontos
    output reg contaErro, // incrementa o contador de erros
    output reg zeraErro,  // zera o contador de erros
    output reg regErro,   // registra (salva) o valor de erro na memória
    output reg zeraPontos,// clear no registrador de pontos (inicia com 100)
    output reg regPontos  // atualiza o registrador de pontos com o novo valor parcial
);

    //=============================================================
    // Definição dos estados
    //=============================================================
    parameter inicial        = 5'b00000; // 0
    parameter preparacao     = 5'b00001; // 1
    parameter espera_jogada  = 5'b00011; // 3
    parameter registra       = 5'b00100; // 4
    parameter comparacao     = 5'b00101; // 5
    parameter proximo        = 5'b00110; // 6
    parameter mostra_leds    = 5'b00111; // 7
    parameter comparaJ       = 5'b01000; // 8
    parameter incrementaE    = 5'b01001; // 9
    parameter preparaE       = 5'b01100; // C
    parameter fim_rodada     = 5'b01011; // B
    parameter prox_rodada    = 5'b00010; // 2
    parameter errou          = 5'b01110; // E
    parameter fim_acertou    = 5'b01010; // A
    parameter fim_timeout    = 5'b01101; // D
    parameter calc_pontos    = 5'b10000; // 16
    parameter salva_pontos   = 5'b10001; // 17
    parameter prox_pos       = 5'b10010; // 18
    parameter prep_fim       = 5'b10011; // 19

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
            inicial       : Eprox = jogar ? preparacao : inicial;
            preparacao    : Eprox = mostra_leds;
            mostra_leds   : Eprox = muda_leds ? comparaJ : mostra_leds;
            comparaJ      : Eprox = enderecoIgualLimite ? preparaE : (muda_leds ? incrementaE : comparaJ);
            preparaE      : Eprox = espera_jogada;
            incrementaE   : Eprox = mostra_leds;
            espera_jogada : Eprox = timeout ? fim_timeout : (jogada ? registra : espera_jogada);
            registra      : Eprox = comparacao;
            comparacao    : Eprox = (!botoesIgualMemoria) ? errou : (enderecoIgualLimite ? fim_rodada : proximo);
            proximo       : Eprox = espera_jogada;
            fim_rodada    : Eprox = muda_leds ? (fimL ? prep_fim : prox_rodada) : fim_rodada;
            prox_rodada   : Eprox = mostra_leds;
            errou         : Eprox = mostra_leds;
            fim_acertou   : Eprox = jogar ? preparacao : fim_acertou;
            fim_timeout   : Eprox = jogar ? preparacao : fim_timeout;
            // Fase de cálculo dos pontos
            prep_fim      : Eprox = calc_pontos;       // Prepara o datapath (zera ContLmt e RegPontos)
            calc_pontos   : Eprox = salva_pontos;      // Espera um ciclo para estabilizar os valores
            salva_pontos  : Eprox = fimL ? fim_acertou : prox_pos;  // Se ContLmt atingiu fim, vai para fim_acertou; caso contrário, avança para próxima posição
            prox_pos      : Eprox = calc_pontos;       // Incrementa ContLmt (e outras funções) para iterar MemErro e retorna a fase de cálculo
            default       : Eprox = inicial;
        endcase
    end

    //=============================================================
    // Lógica de saída (FSM – Moore)
    //=============================================================
    always @* begin
        // Zera o contador de endereços (usado na leitura da ROM)
        zeraE     = (Eatual == preparacao || Eatual == prox_rodada || Eatual == preparaE || Eatual == errou || Eatual == prep_fim) ? 1'b1 : 1'b0;
        // Zera o registrador de jogada
        zeraR     = (Eatual == preparacao) ? 1'b1 : 1'b0;
        // Zera o contador de limite – inclui o estado prep_fim para reinicializar a contagem para iteração na MemErro
        zeraL     = (Eatual == preparacao || Eatual == prep_fim) ? 1'b1 : 1'b0;
        // Habilita o registrador de jogada
        registraR = (Eatual == registra) ? 1'b1 : 1'b0;
        // Incrementa o contador de endereços
        contaE    = (Eatual == proximo || Eatual == incrementaE) ? 1'b1 : 1'b0;
        // Incrementa o contador de limite; agora também em prox_pos para passar para a próxima posição
        contaL    = (Eatual == prox_rodada || Eatual == prox_pos) ? 1'b1 : 1'b0;
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
        // Zera temporizador T2; inclui também o prep_fim para preparar a fase de pontos
        zeraT2    = (Eatual == preparacao || Eatual == prox_rodada || Eatual == comparacao || Eatual == errou || Eatual == prep_fim) ? 1'b1 : 1'b0;
        // Conta temporizador T2
        contaT2   = (Eatual == mostra_leds || Eatual == incrementaE || Eatual == comparaJ || Eatual == fim_rodada) ? 1'b1 : 1'b0;
        // Exibe os LEDs da sequência
        mostraJ   = (Eatual == mostra_leds) ? 1'b1 : 1'b0;
        // Exibe o conteúdo dos botões (quando apropriado)
        mostraB   = (Eatual == espera_jogada || Eatual == registra || Eatual == comparacao || Eatual == fim_rodada) ? 1'b1 : 1'b0;
        // Durante a fase de pontuação, ativa a exibição dos pontos
        mostraPontos = (Eatual == errou || Eatual == fim_acertou || Eatual == fim_timeout ||
                        Eatual == calc_pontos || Eatual == salva_pontos || Eatual == prox_pos || Eatual == prep_fim)
                        ? 1'b1 : 1'b0;
        // Zera o contador de erros (usado para registrar os erros da rodada)
        zeraErro  = (Eatual == prox_rodada) ? 1'b1 : 1'b0;
        // Incrementa o contador de erros
        contaErro = (Eatual == errou) ? 1'b1 : 1'b0;
        // Registra os erros na memória (MemErro)
        regErro   = (Eatual == fim_rodada) ? 1'b1 : 1'b0;
        // No estado prep_fim, realiza clear no registrador de pontos (inicializa com 100)
        zeraPontos = (Eatual == prep_fim) ? 1'b1 : 1'b0;
        // Atualiza o registrador de pontos (RegPontos) somente em salva_pontos
        regPontos  = (Eatual == salva_pontos) ? 1'b1 : 1'b0;

        //=============================================================
        // Saída de depuração: db_estado
        //=============================================================
        case (Eatual)
            inicial      : db_estado = 5'b00000; // 0
            preparacao   : db_estado = 5'b00001; // 1
            mostra_leds  : db_estado = 5'b00111; // 7
            comparaJ     : db_estado = 5'b01000; // 8
            incrementaE  : db_estado = 5'b01001; // 9
            espera_jogada: db_estado = 5'b00011; // 3
            registra     : db_estado = 5'b00100; // 4
            comparacao   : db_estado = 5'b00101; // 5
            proximo      : db_estado = 5'b00110; // 6
            fim_rodada   : db_estado = 5'b01011; // B
            preparaE     : db_estado = 5'b01100; // C
            prox_rodada  : db_estado = 5'b00010; // 2
            errou        : db_estado = 5'b01110; // E
            fim_acertou  : db_estado = 5'b01010; // A
            fim_timeout  : db_estado = 5'b01101; // D
            calc_pontos  : db_estado = 5'b10000; // 16
            salva_pontos : db_estado = 5'b10001; // 17
            prox_pos     : db_estado = 5'b10010; // 18
            prep_fim     : db_estado = 5'b10011; // 19
            default      : db_estado = 5'b01111; // F
        endcase
    end

endmodule
