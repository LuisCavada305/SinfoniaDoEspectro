`timescale 1ns/1ns

module tb_sinfonia_do_espectro;

    // Entradas
    reg         clock;
    reg         reset;
    reg         jogar;
    reg         treinamento;
    reg  [6:0]  botoes;

    // Saídas
    wire        acertou;
    wire        errou;
    wire        pronto;
    wire [2:0]  arduino_out;    
    wire [11:0] display;


    // Sinais de depuração
    wire        db_clock;
    wire        db_reset;
    wire        db_jogar;
    wire        db_botoesIgualMemoria;
    wire        db_tem_botao_pressionado;
    wire [2:0]  db_data_out_sync;
    wire [6:0]  db_jogada;
    wire [6:0]  db_memoria;
    wire [6:0]  db_contagem;
    wire [6:0]  db_limite;
    wire [6:0]  db_estado0;
    wire [6:0]  db_estado1;
    wire [6:0]  db_ones;
    wire [6:0]  db_tens;
    wire [6:0]  db_hundreds;

    // Instância do DUT (Circuito S1)
    sinfonia_do_espectro dut (
        .clock                      (clock),
        .reset                      (reset),
        .jogar                      (jogar),
        .treinamento                (treinamento),
        .botoes                     (botoes),
        .pronto                     (pronto),
        .acertou                    (acertou),
        .errou                      (errou),
        .arduino_out                (arduino_out),
        .display                    (display),
        .db_clock                   (db_clock),
        .db_reset                   (db_reset),
        .db_jogar                   (db_jogar),
        .db_tem_botao_pressionado   (db_tem_botao_pressionado),
        .db_botoesIgualMemoria      (db_botoesIgualMemoria),
        .db_data_out_sync           (db_data_out_sync),
        .db_jogada                  (db_jogada),
        .db_memoria                 (db_memoria),
        .db_contagem                (db_contagem),
        .db_limite                  (db_limite),
        .db_estado0                 (db_estado0),
        .db_estado1                 (db_estado1),
        .db_ones                    (db_ones),
        .db_tens                    (db_tens),
        .db_hundreds                (db_hundreds)
    );

    // Parâmetro de clock (por exemplo, 1us)
    parameter clockPeriod = 1000; // 1000 ns (1us)

    integer i, j;
    // Definindo a sequência correta – esta deve corresponder à ROM 0 do fluxo de dados.
    reg [6:0] jogadas [0:15];

    // Geração do clock
    initial begin
        clock = 0;
    end
    always #(clockPeriod/2) clock = ~clock;

    // Inicialização da sequência (valores idênticos aos definidos na ROM 0)
    initial begin
        jogadas[0] = 7'b0100000;
        jogadas[1] = 7'b0000010;
        jogadas[2] = 7'b0001000;
        jogadas[3] = 7'b0100000;
        jogadas[4] = 7'b0000010;
        jogadas[5] = 7'b0001000;
        jogadas[6] = 7'b0100000;
        jogadas[7] = 7'b0000100;
        jogadas[8] = 7'b0000001;
        jogadas[9] = 7'b0010000;
        jogadas[10] = 7'b0000010;
        jogadas[11] = 7'b0001000;
        jogadas[12] = 7'b0100000;
        jogadas[13] = 7'b0000010;
        jogadas[14] = 7'b0001000;
        jogadas[15] = 7'b0100000;
    end

    // Procedimento de teste
    initial begin
        $display("Inicio da simulacao");
        // Inicialização
        reset   = 0;
        jogar   = 0;
        botoes  = 7'b0000000;
        treinamento = 0;
        #clockPeriod;

        // Teste 1: Resetar o circuito (nota: o reset deve agora limpar os pontos para 0)
        @(negedge clock);
        reset = 1;
        #(clockPeriod);
        reset = 0;
        #(10*clockPeriod);

        // Teste 2: Iniciar o jogo
        jogar = 1;
        #(2*clockPeriod);
        jogar = 0;
        for (i = 0; i < 21; i = i+1) begin
            #(101*clockPeriod);
        end

        botoes = 7'h1;
        #(10*clockPeriod);
        botoes = 7'h0;

        // Simula 16 rodadas em que o jogador acerta todas as jogadas.
        // Para a rodada i, serão aplicadas (i+1) jogadas, seguindo a sequência correta.
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j <= i; j = j + 1) begin
                // Aguarda o estado de espera (estado "espera_jogada", definido como 5'b00011)
                while (dut.UC.Eatual !== 5'b01010) #(clockPeriod);
                // Aplica a jogada correta, conforme o vetor "jogadas" (memória de jogadas certas)
                botoes = jogadas[j];
                #(50*clockPeriod);
                botoes = 7'b0000000;
                #(10*clockPeriod);
                end
            // Aguarda a transição entre rodadas (tempo para a lógica de pontos ser atualizada)
            #(510*clockPeriod);
            $display("Valor dos pontos apos rodada %d : %d pontos", i, dut.s_pontos);
        end

        // Aguarda o fim do jogo (quando o sinal "pronto" estiver ativo)
        //while (!pronto) #(clockPeriod);
        #(550*clockPeriod);
        $display("Valor final de pontos = %d", dut.s_pontos);
        jogar = 1;
        #(10*clockPeriod);
        jogar = 0;
        $display("Valor final de pontos pos-recomeco= %d", dut.s_pontos);
        #(200*clockPeriod);
        

        botoes = 7'h1;
        #(10*clockPeriod);
        botoes = 7'h0;

        while (dut.UC.Eatual !== 5'b01010) #(clockPeriod);
        botoes = 7'h02;
        #(10*clockPeriod);
        botoes = 7'b0000000;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j <= i; j = j + 1) begin
                // Aguarda o estado de espera (estado "espera_jogada", definido como 5'b00011)
                while (dut.UC.Eatual !== 5'b01010) #(clockPeriod);
                // Aplica a jogada correta, conforme o vetor "jogadas" (memória de jogadas certas)
                botoes = jogadas[j];
                #(50*clockPeriod);
                botoes = 7'b0000000;
                #(10*clockPeriod);
                end
            #(510*clockPeriod);
            $display("Valor dos pontos apos rodada %d : %d pontos", i, dut.s_pontos);
            // Aguarda a transição entre rodadas (tempo para a lógica de pontos ser atualizada)
        end

        #(550*clockPeriod);
            $display("Valor final de pontos = %d", dut.s_pontos);
        
        $display("Jogo finalizado.");
        $finish;
    end

endmodule
