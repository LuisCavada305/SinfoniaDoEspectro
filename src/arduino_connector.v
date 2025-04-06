// arduino_connection.v
// Módulo para converter entrada one-hot de 7 bits na posição correspondente (3 bits).
// Se o sinal de enable estiver desativado, a saída será 3'b000.

module arduino_connection(
    input  wire [6:0] entrada,  // entrada one-hot (apenas um bit ativo)
    input  wire       enable,   // sinal de habilitação
    output reg  [2:0] saida     // saída que indica a posição do bit ativo
);

    always @(*) begin
        if (!enable)
            saida = 3'b000;
        else begin
            case (entrada)
                7'b0000000: saida = 3'b000; // nenhum bit ativo
                7'b0000001: saida = 3'b001; // bit 1 ativo
                7'b0000010: saida = 3'b010; // bit 2 ativo
                7'b0000100: saida = 3'b011; // bit 3 ativo
                7'b0001000: saida = 3'b100; // bit 4 ativo
                7'b0010000: saida = 3'b101; // bit 5 ativo
                7'b0100000: saida = 3'b110; // bit 6 ativo
                7'b1000000: saida = 3'b111; // bit 7 ativo
                default:   saida = 3'b000; // caso nenhum bit seja válido (ou múltiplos bits ativos)
            endcase
        end
    end

endmodule
