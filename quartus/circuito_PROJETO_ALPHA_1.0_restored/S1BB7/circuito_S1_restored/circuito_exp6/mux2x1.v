/*------------------------------------------------------------------------
 * Arquivo   : mux2x1.v
 * Projeto   : Jogo do Desafio da Memoria
 *------------------------------------------------------------------------
 * Descricao : multiplexador 2x1
 * 
 * adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL"
 * 
 * exemplo de uso: ver testbench mux2x1_tb.v
 *------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     15/02/2024  1.0     Edson Midorikawa  criacao
 *     31/01/2025  1.1     Edson Midorikawa  revisao
 *------------------------------------------------------------------------
 */

module mux2x1 (
    input   	[3:0]   D0,
    input   	[3:0]   D1,
    input     			  SEL,
    output reg [3:0]   OUT
);

always @(*) begin
    case (SEL)
        1'b0:    OUT = D0;
        1'b1:    OUT = D1;
        default: OUT = 4'b1111; // saida em 1
    endcase
end

endmodule
