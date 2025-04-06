module notas2letras(
    input [2:0] nota,
    input [1:0] contagem_display,
    output reg [4:0] letras
);

    always @(*) begin
        if (contagem_display != 2'b11)
            letras[2:0] <= 3'b000;
        else if (contagem_display == 2'b11) begin  
            if (nota < 5)
                letras[2:0] <= nota + 2'b11;
            else if (nota >= 5)
                letras[2:0] <= nota + 3'b100;
        end
	 letras[4:3] <= 2'b00;
    end
    
endmodule
