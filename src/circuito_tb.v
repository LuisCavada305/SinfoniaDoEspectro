`timescale 1ns/1ns

module circuito_S1_tb;

    // Entradas
    reg         clock;
    reg         reset;
    reg         jogar;
    reg         memoria; // Seleciona qual ROM usar
    reg         nivel;   // Nível (1 gera s_nivel = 4'b1111)
    reg  [6:0]  botoes;

    // Saídas
    wire        pronto;
    wire        acertou;
    wire        errou;
    // Sinais de depuração
    wire        db_jogar;
    wire        db_botoesIgualMemoria;
    wire        db_tem_jogada;
    wire [6:0]  db_contagem;
    wire [6:0]  db_memoria;
    wire [6:0]  db_limite;
    wire [6:0]  db_jogadafeita;
    wire [6:0]  db_estado;
    wire        db_timeout;
    wire        db_clock;
    wire [6:0]  leds;
    // Displays para os pontos (três dígitos de 7 segmentos)
    wire [6:0]  disp_hund; // centenas
    wire [6:0]  disp_tens; // dezenas
    wire [6:0]  disp_ones; // unidades

    // Instância do DUT (Circuito S1)
    circuito_S1 dut (
        .clock                (clock),
        .reset                (reset),
        .jogar                (jogar),
        .memoria              (memoria),
        .nivel                (nivel),
        .botoes               (botoes),
        .pronto               (pronto),
        .acertou              (acertou),
        .errou                (errou),
        .db_jogar             (db_jogar),
        .db_botoesIgualMemoria (db_botoesIgualMemoria),
        .db_tem_jogada        (db_tem_jogada),
        .db_contagem          (db_contagem),
        .db_memoria           (db_memoria),
        .db_limite            (db_limite),
        .db_jogadafeita       (db_jogadafeita),
        .db_estado            (db_estado),
        .db_timeout           (db_timeout),
        .db_clock             (db_clock),
        .leds                 (leds),
        .disp_hund            (disp_hund),
        .disp_tens            (disp_tens),
        .disp_ones            (disp_ones)
    );

    // Parâmetro de clock (por exemplo, 1us)
    parameter clockPeriod = 1000000; // 1000 ns

    integer i, j;
    // Definindo a sequência correta (os mesmos valores que constam nas ROMs, 7 bits)
    reg [6:0] jogadas [0:15];

    // Variável para identificar o caso de teste
    reg [31:0] caso;

    // Geração do clock
    initial begin
        clock = 0;
    end
    always #(clockPeriod/2) clock = ~clock;

    // Inicialização da sequência (conforme as ROMs dos módulos sync_rom_16x4_x)
    initial begin
        jogadas[0]  = 7'b0000001;
        jogadas[1]  = 7'b0000010;
        jogadas[2]  = 7'b0000100;
        jogadas[3]  = 7'b0001000;
        jogadas[4]  = 7'b0010000;
        jogadas[5]  = 7'b0100000;
        jogadas[6]  = 7'b1000000;
        jogadas[7]  = 7'b0100000;
        jogadas[8]  = 7'b0010000;
        jogadas[9]  = 7'b0001000;
        jogadas[10] = 7'b0000100;
        jogadas[11] = 7'b0000010;
        jogadas[12] = 7'b0000001;
        jogadas[13] = 7'b0000010;
        jogadas[14] = 7'b0000100;
        jogadas[15] = 7'b0001000;
    end

    // Procedimento de teste
    initial begin
        $display("Inicio da simulacao");
        caso = 0;
        // Inicialização
        reset   = 0;
        jogar   = 0;
        botoes  = 7'b0000000;
        memoria = 0;   // Define qual ROM usar (0 ou 1)
        nivel   = 1;   // Nível 1 (gera s_nivel = 4'b1111)
        #clockPeriod;

        // Teste 1: Resetar o circuito
        $display("Teste %0d: Reset do circuito", caso);
        @(negedge clock);
        reset = 1;
        #(clockPeriod);
        reset = 0;
        #(10*clockPeriod);

        // Teste 2: Iniciar o jogo
        $display("Teste %0d: Iniciando o jogo", caso);
        jogar = 1;
        #(100*clockPeriod);
        jogar = 0;
        #(10*clockPeriod);

        // Simula várias rodadas em que o jogador acerta todas as jogadas.
        // Neste exemplo, simulamos 4 rodadas (rodada 1 com 1 jogada, rodada 2 com 2 jogadas, etc.)
        for (i = 0; i < 16; i = i + 1) begin
            caso = i + 1;
            $display("Rodada %0d iniciada", caso);
            for (j = 0; j <= i; j = j + 1) begin
                // Aguarda o estado de espera (espera_jogada = 5'b00011)
                while (dut.UC.Eatual !== 5'b00011) #(clockPeriod);
                // Aplica a jogada correta (conforme o vetor jogadas)
                botoes = jogadas[j];
                #(100*clockPeriod);
                botoes = 7'b0000000;
                #(10*clockPeriod);
            end
            $display("Rodada %0d finalizada", caso);
            // Aguarda a transição entre rodadas
            #(50*clockPeriod);
        end

        // Aguarda o fim do jogo (quando pronto estiver ativo)
        while (!pronto) #(clockPeriod);
        
        // Exibe o valor final de pontos (deve ser 100, pois nenhum erro foi cometido)
        $display("Jogo finalizado.");
        $display("Valor final de pontos = %d", dut.FD.s_pontos);
        $display("Displays: Hundreds = %d, Tens = %d, Ones = %d", disp_hund, disp_tens, disp_ones);

        $finish;
    end

endmodule
