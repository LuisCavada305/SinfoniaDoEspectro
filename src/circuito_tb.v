`timescale 1ns/1ns

module circuito_S1_tb;

    // Entradas
    reg         clock;
    reg         reset;
    reg         jogar;
    reg         memoria; // Seleciona qual ROM usar
    reg         treinamento;
    reg         nivel;   // Nível (1 gera 16 rodadas, conforme s_nivel = 4'b1111)
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
    wire [11:0] display;

    // Instância do DUT (Circuito S1)
    circuito_S1 dut (
        .clock                (clock),
        .reset                (reset),
        .jogar                (jogar),
        .memoria              (memoria),
        .treinamento          (treinamento),
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
        .display              (display)
    );

    // Parâmetro de clock (por exemplo, 1us)
    parameter clockPeriod = 1000; // 1000 ns (1us)

    integer i, j;
    // Definindo a sequência correta – esta deve corresponder à ROM 0 do fluxo de dados.
    reg [6:0] jogadas [0:15];

    // Variável para identificar o caso de teste
    reg [31:0] caso;

    // Geração do clock
    initial begin
        clock = 0;
    end
    always #(clockPeriod/2) clock = ~clock;

    // Inicialização da sequência (valores idênticos aos definidos na ROM 0)
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
        memoria = 0;   // Usa a ROM 0 (memória de jogadas certas)
        nivel   = 1;   // Nível 1 -> 16 rodadas
        treinamento = 0;
        #clockPeriod;

        // Teste 1: Resetar o circuito (nota: o reset deve agora limpar os pontos para 0)
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

        // Simula 16 rodadas em que o jogador acerta todas as jogadas.
        // Para a rodada i, serão aplicadas (i+1) jogadas, seguindo a sequência correta.
        for (i = 0; i < 16; i = i + 1) begin
            caso = i + 1;
            $display("Rodada %0d iniciada", caso);
            for (j = 0; j <= i; j = j + 1) begin
                // Aguarda o estado de espera (estado "espera_jogada", definido como 5'b00011)
                while (dut.UC.Eatual !== 5'b00011) #(clockPeriod);
                // Aplica a jogada correta, conforme o vetor "jogadas" (memória de jogadas certas)
                botoes = jogadas[j];
                #(100*clockPeriod);
                botoes = 7'b0000000;
                #(10*clockPeriod);
            end
            $display("Rodada %0d finalizada", caso);
            // Aguarda a transição entre rodadas (tempo para a lógica de pontos ser atualizada)
            #(50*clockPeriod);
        end

        // Aguarda o fim do jogo (quando o sinal "pronto" estiver ativo)
        while (!pronto) #(clockPeriod);
        
        // Exibe o valor final de pontos – neste teste, como nenhuma rodada teve erros,
        // a lógica deve acumular os ganhos por rodada e aplicar o bônus final (limitando a 100 pontos, se essa for a regra).
        $display("Jogo finalizado.");
        $display("Valor final de pontos = %d", dut.FD.s_pontos);
        $finish;
    end

endmodule
