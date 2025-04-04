module calculadora_pontos (
    input       calcular,
    input       [3:0] rodada,
    input       [7:0] erros,
    input       [7:0] pontos_in,
    output reg  [7:0] pontos_out
);
    
    wire [7:0]	pontos_rodada_base;
    wire [7:0]	pontos_rodada;
	 
	 assign pontos_rodada = pontos_rodada_base - erros;

    memoria_pontos mem_potuacao(
//        .clock      (calcular),
        .address    (rodada),
        .data_out   (pontos_rodada_base)
    );

    always @(calcular) begin
        if (pontos_rodada <= 0)
            pontos_out <= pontos_in;
        else
            pontos_out <= pontos_in + pontos_rodada;
    end


endmodule

module memoria_pontos (address, data_out);
    //input            clock;
    input      [3:0] address;
    output reg [7:0] data_out;

    always @(*)
    begin
        case (address)
            4'h0: data_out = 8'h01;
            4'h1: data_out = 8'h01;
            4'h2: data_out = 8'h02;
            4'h3: data_out = 8'h03;
            4'h4: data_out = 8'h04;
            4'h5: data_out = 8'h05;
            4'h6: data_out = 8'h06;
            4'h7: data_out = 8'h07;
            4'h8: data_out = 8'h08;
            4'h9: data_out = 8'h09;
            4'ha: data_out = 8'h09;
            4'hb: data_out = 8'h09;
            4'hc: data_out = 8'h09;
            4'hd: data_out = 8'h09;
            4'he: data_out = 8'h09;
            4'hf: data_out = 8'h09;
        endcase
    end
endmodule