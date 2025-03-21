module memoria_notas(endereco, nota);
    input   	[5:0]   endereco;
    output reg [2:0]   nota;

    reg [3:0] notas [64:0];
    //$readmemb("memoria_notas.mem", notas);

    always @(*)begin
        nota <= notas[endereco];
    end

    initial
        begin
            //notas teste
            notas[0]  = 4'b000;
            notas[1]  = 4'b001;
            notas[2]  = 4'b010;
            notas[3]  = 4'b011;
            notas[4]  = 4'b100;
            notas[5]  = 4'b101;
            notas[6]  = 4'b110;
            notas[7]  = 4'b110;
            notas[8]  = 4'b101;
            notas[9]  = 4'b100;
            notas[10] = 4'b011;
            notas[11] = 4'b010;
            notas[12] = 4'b001;
            notas[13] = 4'b000;
            notas[14] = 4'b011;
            notas[15] = 4'b110;

            //notas desafio1
            notas[16]  = 4'b000;
            notas[17]  = 4'b001;
            notas[18]  = 4'b010;
            notas[19]  = 4'b011;
            notas[20]  = 4'b100;
            notas[21]  = 4'b101;
            notas[22]  = 4'b110;
            notas[23]  = 4'b110;
            notas[24]  = 4'b101;
            notas[25]  = 4'b100;
            notas[26]  = 4'b011;
            notas[27]  = 4'b010;
            notas[28]  = 4'b001;
            notas[29]  = 4'b000;
            notas[30]  = 4'b011;
            notas[31]  = 4'b110;

            //notas desafio2
            notas[32]  = 4'b000;
            notas[33]  = 4'b001;
            notas[34]  = 4'b010;
            notas[35]  = 4'b011;
            notas[36]  = 4'b100;
            notas[37]  = 4'b101;
            notas[38]  = 4'b110;
            notas[39]  = 4'b110;
            notas[40]  = 4'b101;
            notas[41]  = 4'b100;
            notas[42]  = 4'b011;
            notas[43]  = 4'b010;
            notas[44]  = 4'b001;
            notas[45]  = 4'b000;
            notas[46]  = 4'b011;
            notas[47]  = 4'b110;

            //notas desafio3
            notas[48]  = 4'b000;
            notas[49]  = 4'b001;
            notas[50]  = 4'b010;
            notas[51]  = 4'b011;
            notas[52]  = 4'b100;
            notas[53]  = 4'b101;
            notas[54]  = 4'b110;
            notas[55]  = 4'b110;
            notas[56]  = 4'b101;
            notas[57]  = 4'b100;
            notas[58]  = 4'b011;
            notas[59]  = 4'b010;
            notas[60]  = 4'b001;
            notas[61]  = 4'b000;
            notas[62]  = 4'b011;
            notas[63]  = 4'b110;

        end 
endmodule
