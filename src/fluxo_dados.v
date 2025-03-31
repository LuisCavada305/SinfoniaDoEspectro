module fluxo_dados (
    
    // Inputs
    input clock,
    input [6:0] botoes,
    
    // Sinais de Controle
    input zera_registrador_botoes,
    input enable_registrador_botoes,
    input enable_contador_rodada,
    input zera_contador_rodada,
    input enable_contador_jogada,
    input zera_contador_jogada,
    input memoria,
	 input nivel,
    input zeraT,
    input contaT,
    input zera_timeout_buzzer,
    input conta_timeout_buzzer,
    input mostraJ,
    input mostraB,
    input contaErro,
    input zeraErro,
    input zeraPontos,
    input regPontos,
    input sel_memoria_arduino,
    input activateArduino,
    input calcular,
    
    // Sinais de Condição
    output enderecoIgualLimite, //
    output botoesIgualMemoria,//
    output fimL,//
    output fimE, //
    output tem_jogada,//
    output timeout,
	output muda_nota,
    
    // Sinal de Saída
    output [2:0] arduino_out,
    output [7:0] pontos,
    
    // Sinais de Depuração
    output tem_botao_pressionado,
    output [3:0] db_limite,
    output [3:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_jogada,
    output [6:0] leds
);

    // sinal interno para interligacao dos componentes
    wire [6:0] s_jogada;
    wire [3:0] s_contagem;
    wire [6:0] s_memoria;
    wire s_sinal;
    wire [3:0] s_limite;
    wire [6:0] s_memoria1;
    wire [6:0] s_memoria2;
    wire [6:0] s_mux;
    wire s_fim;
    wire [3:0] s_nivel = {nivel, 3'b111};
    wire [3:0] s_erros;
	wire [7:0] s_erro_estendido = {4'h0,s_erros};
    assign s_sinal = botoes[0] | botoes[1] | botoes[2] | botoes[3] | botoes[4] | botoes[5] | botoes[6];
    wire [7:0] s_pontos; 
	wire [7:0] s_resultado;
    wire [6:0] s_arduino_out;
    wire [4:0] s_endereco_msg;

    // ======================================================
    // Bloco de Contagem e Comparação da Sequência
    // ======================================================
    
    // Contador que marca o limite (número de jogadas na rodada)
    contador_163 ContLmt (
      .clock( clock ),
      .clr  ( ~zera_contador_rodada ),
      .ld   ( 1'b1 ),
      .ent  ( 1'b1),
      .enp  ( enable_contador_rodada ),
      .D    ( 4'b0 ),
      .Q    ( s_limite ),
      .rco  (s_fim)
    );

    // Comparador para verificar se o limite (s_limite) atingiu o nível esperado
	  comparador_85 CompFim (
      .A   ( s_limite ),
      .B   ( s_nivel ),
      .ALBi( 1'b0 ),
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo(  ),
      .AGBo(  ),
      .AEBo( fimL )
    );

    // Contador para endereçamento (endereço na ROM)
    contador_163 ContEnd (
      .clock( clock ),
      .clr  ( ~zera_contador_jogada ),
      .ld   ( 1'b1 ),
      .ent  ( 1'b1),
      .enp  ( enable_contador_jogada ),
      .D    ( 4'b0 ),
      .Q    ( s_contagem ),
      .rco  ( fimE )
    );
    
    // Comparador para verificar se o endereço é igual ao limite
    comparador_85 CompLmt (
      .A   ( s_limite ),
      .B   ( s_contagem ),
      .ALBi( 1'b0 ),
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo(  ),
      .AGBo(  ),
      .AEBo( enderecoIgualLimite )
    );

    // Registrador para armazenar a jogada dos botões (7 bits)
    registrador_7 RegBotoes (
      .clock  (clock),      
      .clear  (zera_registrador_botoes),      
      .enable (enable_registrador_botoes),     
      .D      (botoes), 
      .Q      (s_jogada) 
    );

   // ROMs síncronas – memórias com a sequência esperada
    sync_rom_16x4_1 memoria1 (
      .clock (clock),
      .address (s_contagem),
      .data_out (s_memoria1)
    );
	 
	 sync_rom_16x4_2 memoria2 (
      .clock (clock),
      .address (s_contagem),
      .data_out (s_memoria2)
    );
    
    // MUX para selecionar entre as duas ROMs
    mux2x1_7 MUX_MEM (
		 .D0(s_memoria1),
		 .D1(s_memoria2),
		 .SEL(memoria),
		 .OUT(s_memoria)
	 );
	 
    // Comparador para verificar se a jogada registrada é igual à esperada
    comparador_85_7bits CompJog (
      .A   ( s_memoria ),
      .B   ( s_jogada ),
      .ALBi( 1'b0 ),
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo(  ),
      .AGBo(  ),
      .AEBo( botoesIgualMemoria )
    );

    edge_detector detector_borda (
        .clock(clock),
        .reset(zera_registrador_botoes),
        .sinal(s_sinal),
        .pulso(tem_jogada)
    );

    // Contadores para timeout e atualização dos LEDs
    contador_m #(.M(60000), .N(13)) contador_5000(
        .clock (clock),
        .zera_as(1'b0),
        .zera_s (zeraT),
        .conta (contaT),
        .Q (),
        .fim (timeout),
        .meio () 
    );

	contador_m #(.M(500), .N(13)) contador_500(
        .clock (clock),
        .zera_as(1'b0),
        .zera_s (zera_timeout_buzzer),
        .conta (conta_timeout_buzzer),
        .Q (),
        .fim (muda_nota),
        .meio () 
    );

    contador_m #(.M(21), .N(5)) contador_mensagem(
        .clock (clock),
        .zera_as(1'b0),
        .zera_s (zera_contador_msg),
        .conta (enable_contador_msg),
        .Q (s_endereco_msg),
        .fim (),
        .meio () 
    );

    memoria_frase memoria_da_frase_inicial(
        .address(s_endereco_msg),
        .data_out()
    )

	// MUX para seleção de exibição: mostra a memória ou zero conforme mostraJ
	mux2x1_7 MUX (
        .D0(7'b0000000),
        .D1(s_memoria),
        .SEL(mostraJ),
        .OUT(s_mux)
	 );
	 
    // Segundo MUX: seleciona entre o resultado do MUX anterior e os botões para dirigir os LEDs
    mux2x1_7 MUX2 (
        .D0(s_mux),
        .D1(botoes),
        .SEL(mostraB),
        .OUT(leds)
	);
	 
    // Contador de erros (acumula os erros durante a rodada)
    contador_163 ContErro (
        .clock( clock ),
        .clr  ( ~zeraErro ),
        .ld   ( 1'b1 ),
        .ent  ( 1'b1),
        .enp  ( contaErro ),
        .D    ( 4'b0 ),
        .Q    ( s_erros ),
        .rco  (  )
    );


    //Calculadora de Pontos
    calculadora_pontos calculadora_de_pontos(
        .calcular(calcular),
        .rodada(s_contagem),
        .erros(s_erro_estendido),
        .pontos_in(pontos),
        .pontos_out(s_resultado)
    );

    registrador_8_init registrador_Pontos(
        .enable(regPontos),
        .clock(clock),
        .clear(zeraPontos),
        .D(s_resultado),
        .Q(pontos)
    );

    // Conexão com o Arduino
    mux2x1_7 Arduino_sound (
        .D0 (botoes),
        .D1 (s_memoria),
        .SEL(sel_memoria_arduino),
		.OUT (s_arduino_out)
    );
    arduino_connection Arduino_Play(
        .entrada (s_arduino_out),
        .enable (activateArduino),
		.saida  (arduino_out)
    );
    // saidas de depuracao
    assign db_limite = s_limite;
    assign tem_botao_pressionado = s_sinal;
    assign db_contagem = s_contagem;
    assign db_memoria = s_memoria;
    assign db_jogada = s_jogada;
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

// ======================================================
// MÓDULO: registrador_7_init
// ======================================================
// Ao receber clear, carrega 100; em enable, atualiza com D.
module registrador_8_init (
    input        clock,
    input        clear,
    input        enable,
    input  [7:0] D,
    output reg [7:0] Q
);
    always @(posedge clock or posedge clear) begin
        if (clear)
            Q <= 8'd0;  // inicializa com 100 pontos
        else if (enable)
            Q <= D;
    end
endmodule



module sync_rom_16x4_1 (clock, address, data_out);
    input            clock;
    input      [3:0] address;
    output reg [6:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            4'b0000: data_out = 7'b0000001;
            4'b0001: data_out = 7'b0000010;
            4'b0010: data_out = 7'b0000100;
            4'b0011: data_out = 7'b0001000;
            4'b0100: data_out = 7'b0010000;
            4'b0101: data_out = 7'b0100000;
            4'b0110: data_out = 7'b1000000;
            4'b0111: data_out = 7'b0100000;
            4'b1000: data_out = 7'b0010000;
            4'b1001: data_out = 7'b0001000;
            4'b1010: data_out = 7'b0000100;
            4'b1011: data_out = 7'b0000010;
            4'b1100: data_out = 7'b0000001;
            4'b1101: data_out = 7'b0000010;
            4'b1110: data_out = 7'b0000100;
            4'b1111: data_out = 7'b0001000;
        endcase
    end
endmodule

module sync_rom_16x4_2 (clock, address, data_out);
    input            clock;
    input      [3:0] address;
    output reg [6:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            4'b0000: data_out = 7'b0000001;
            4'b0001: data_out = 7'b0000010;
            4'b0010: data_out = 7'b0000100;
            4'b0011: data_out = 7'b0001000;
            4'b0100: data_out = 7'b0010000;
            4'b0101: data_out = 7'b0100000;
            4'b0110: data_out = 7'b1000000;
            4'b0111: data_out = 7'b0100000;
            4'b1000: data_out = 7'b0010000;
            4'b1001: data_out = 7'b0001000;
            4'b1010: data_out = 7'b0000100;
            4'b1011: data_out = 7'b0000010;
            4'b1100: data_out = 7'b0000001;
            4'b1101: data_out = 7'b0000010;
            4'b1110: data_out = 7'b0000100;
            4'b1111: data_out = 7'b0001000;
        endcase
    end
endmodule

module sync_ram_16x4 (
    input            clock,
    input            reset,        // Novo sinal de reset síncrono
    input            write_enable,
    input      [3:0] address,
    input      [3:0] data_in,
    output reg [3:0] data_out
);
    reg [3:0] ram_block [0:15]; 

    integer i; // variável para o for

    always @(posedge clock) begin
        if (reset) begin
            // Zera toda a memória
            for (i = 0; i < 16; i = i + 1)
                ram_block[i] <= 4'b0000;
            // Zera a saída também
            data_out <= 4'b0000;
        end else begin
            // Operação normal de escrita
            // (só ocorre se address não estiver em 'x')
            if (write_enable && (address !== 4'bx))
                ram_block[address] <= data_in;

            // Proteção contra endereço indefinido
            if (address === 4'bx)
                data_out <= 4'b0000;
            else
                data_out <= ram_block[address];
        end
    end
endmodule
