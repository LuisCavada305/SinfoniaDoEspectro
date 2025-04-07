`timescale 1ns/1ns

module tb_calculadora_pontos();

    reg [7:0] s_pontos;
    reg [3:0] s_rodada;
    wire [7:0]s_pontos_out;
    integer i;
    reg clock;

    calculadora_pontos DUT(
        .calcular(clock),
        .rodada(s_rodada),
        .erros(8'h00),
        .pontos_in(s_pontos),
        .pontos_out(s_pontos_out)
    );

    parameter clockPeriod = 1000; // 1000 ns (1us)
    // Geração do clock
    initial begin
        clock = 0;
    end
    always #(clockPeriod/2) clock = ~clock;

    initial begin
        s_pontos = 8'h00;
        for (i = 0; i < 16; i = i + 1) begin
            s_rodada = i;
            #(2*clockPeriod);
            s_pontos <= s_pontos_out;
        end
    end
endmodule
