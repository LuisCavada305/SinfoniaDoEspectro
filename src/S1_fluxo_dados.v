module S1_fluxo_dados (
    // Inputs
    input clock, //
    input [6:0] botoes,//
    // Sinais de Controle
    input zeraR,//
    input registraR,//
    input contaL,//
    input zeraL,//
    input contaE,//
    input zeraE,//
    input memoria,
	 input nivel,
    input zeraT,
    input contaT,
    input zeraT2,
    input contaT2,
    input mostraJ,
    input mostraB,
    input zeraMemErro,
    input contaErro,
    input zeraErro,
    input regErro,
    input zeraPontos,
    input regPontos,
    // Sinais de Condição
    output enderecoIgualLimite, //
    output botoesIgualMemoria,//
    output fimL,//
    output fimE, //
    output jogadafeita,//
    output timeout,
	 output muda_leds,
    // Depuração
    output db_temjogada,//
    output [3:0] db_limite, //
    output [3:0] db_contagem,//
    output [6:0] db_memoria,//
    output [6:0] db_jogada,//
	 output [6:0] leds,
	 output [7:0] pontos
);
    wire [6:0] s_jogada;  // sinal interno para interligacao dos componentes
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
    wire [3:0] m_erros;
    assign s_sinal = botoes[0] | botoes[1] | botoes[2] | botoes[3] | botoes[4] | botoes[5] | botoes[6];
    wire [7:0] s_pontos, s_resultado;
    

     // ======================================================
    // Bloco de Contagem e Comparação da Sequência
    // ======================================================
    
    // Contador que marca o limite (número de jogadas na rodada)
    contador_163 ContLmt (
      .clock( clock ),
      .clr  ( ~zeraL ),
      .ld   ( 1'b1 ),
      .ent  ( 1'b1),
      .enp  ( contaL ),
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
      .clr  ( ~zeraE ),
      .ld   ( 1'b1 ),
      .ent  ( 1'b1),
      .enp  ( contaE ),
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
      .clear  (zeraR),      
      .enable (registraR),     
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
    comparador_85_7 CompJog (
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
        .reset(zeraR),
        .sinal(s_sinal),
        .pulso(jogadafeita)
    );

    // Contadores para timeout e atualização dos LEDs
    contador_m #(.M(5000), .N(13)) contador_5000(
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
        .zera_s (zeraT2),
        .conta (contaT2),
        .Q (),
        .fim (muda_leds),
        .meio () 

    );
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

    // RAM síncrona para armazenamento dos erros (MemErro)
    sync_ram_16x4 MemErro (
        .clock(clock),
        .reset(zeraMemErro),
        .write_enable(regErro),
        .address (s_limite),
        .data_in(s_erros),
        .data_out(m_erros)
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
	 
	// ======================================================
    // Lógica de Cálculo de Pontos
    // ======================================================
    // Registrador de pontos – ao ser "limpo" (clear) carrega o valor inicial de 100.
    registrador_8_init RegPontos (
      .clock  ( clock ),      
      .clear  ( zeraPontos ),      
      .enable ( regPontos ),     
      .D      ( s_resultado ), 
      .Q      ( s_pontos )
    );
    
    // Unidade aritmética para atualizar a parcial de pontos.
    // Observação: Durante a fase de pontuação, o mesmo contador (ContLmt) é reiniciado para iterar
    // sobre as posições de MemErro. Para cada iteração, considera-se que:
    //   round = s_limite + 1;         // round (1-based)
    //   round_factor = 16 - round;     // quanto menor o número da rodada, maior a dedução
    //   penalty = m_erros >> 1;        // m_erros * 0.5 (deslocamento à direita de 1 bit)
    // A nova parcial é: current_score - (round_factor * penalty)
    wire [4:0] round_num = {1'b0, s_limite} + 5'd1;  // converte s_limite (4 bits) para um número de rodada (1 a 16)
    wire [4:0] round_factor = 5'd16 - round_num;
    wire [3:0] penalty = m_erros >> 1;  // divisão por 2
    wire [8:0] deduction_temp = round_factor * penalty;  // produto (até 9 bits)
    wire [7:0] deduction = deduction_temp[7:0];  // dedução (8 bits)
    
    // Cálculo da nova parcial: s_pontos é o acumulador atual de pontos
    wire [7:0] calc_new_score = s_pontos - deduction;
    
    // A saída s_resultado da unidade aritmética é usada para atualizar o registrador de pontos
    assign s_resultado = calc_new_score;
	 

    // saidas de depuracao
    assign db_limite = s_limite;
    assign db_temjogada = s_sinal;
    assign db_contagem = s_contagem;
    assign db_memoria = s_memoria;
    assign db_jogada = s_jogada;
	assign pontos = s_pontos;
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
// MÓDULO: registrador_8_init
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
            Q <= 8'd100;  // inicializa com 100 pontos
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




module comparador_85 (ALBi, AGBi, AEBi, A, B, ALBo, AGBo, AEBo);

    input[3:0] A, B;
    input      ALBi, AGBi, AEBi;
    output     ALBo, AGBo, AEBo;
    wire[4:0]  CSL, CSG;

    assign CSL  = ~A + B + ALBi;
    assign ALBo = ~CSL[4];
    assign CSG  = A + ~B + AGBi;
    assign AGBo = ~CSG[4];
    assign AEBo = ((A == B) && AEBi);

endmodule /* comparador_85 */

module comparador_85_7 (ALBi, AGBi, AEBi, A, B, ALBo, AGBo, AEBo);

    input[6:0] A, B;
    input      ALBi, AGBi, AEBi;
    output     ALBo, AGBo, AEBo;
    wire[7:0]  CSL, CSG;

    assign CSL  = ~A + B + ALBi;
    assign ALBo = ~CSL[7];
    assign CSG  = A + ~B + AGBi;
    assign AGBo = ~CSG[7];
    assign AEBo = ((A == B) && AEBi);

endmodule /* comparador_85 */

module contador_163 ( clock, clr, ld, ent, enp, D, Q, rco );
    input clock, clr, ld, ent, enp;
    input [3:0] D;
    output reg [3:0] Q;
    output reg rco;

    always @ (posedge clock)
        if (~clr)               Q <= 4'd0;
        else if (~ld)           Q <= D;
        else if (ent && enp)    Q <= Q + 1'b1;
        else                    Q <= Q;
 
    always @ (Q or ent)
        if (ent && (Q == 4'd15))   rco = 1;
        else                       rco = 0;
endmodule

module edge_detector (
    input  clock,
    input  reset,
    input  sinal,
    output pulso
);

    reg reg0;
    reg reg1;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            reg0 <= 1'b0;
            reg1 <= 1'b0;
        end else if (clock) begin
            reg0 <= sinal;
            reg1 <= reg0;
        end
    end

    assign pulso = ~reg1 & reg0;

endmodule