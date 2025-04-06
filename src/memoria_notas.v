module memoria_notas (clock, address, select_musica, data_out);
    input            clock;
    input      [3:0] address;
    input      [2:0] select_musica;
    output reg [6:0] data_out;

    wire [6:0] music_address = {select_musica, address};
    always @ (posedge clock)
    begin
        case (music_address)
            // Musica 1 - Cantina Band - Star Wars
            7'h00: data_out = 7'b0100000;
            7'h01: data_out = 7'b0000010;
            7'h02: data_out = 7'b0001000;
            7'h03: data_out = 7'b0100000;
            7'h04: data_out = 7'b0000010;
            7'h05: data_out = 7'b0001000;
            7'h06: data_out = 7'b0100000;
            7'h07: data_out = 7'b0000100;
            7'h08: data_out = 7'b0000001;
            7'h09: data_out = 7'b0010000;
            7'h0a: data_out = 7'b0000010;
            7'h0b: data_out = 7'b0001000;
            7'h0c: data_out = 7'b0100000;
            7'h0d: data_out = 7'b0000010;
            7'h0e: data_out = 7'b0001000;
            7'h0f: data_out = 7'b0100000;
            
            // Musica 2 - Marcha Imperial - Darth Brunoro
            7'h10: data_out = 7'b0100000;
            7'h11: data_out = 7'b0100000;
            7'h12: data_out = 7'b0100000;
            7'h13: data_out = 7'b0001000;
            7'h14: data_out = 7'b0000001;
            7'h15: data_out = 7'b0100000;
            7'h16: data_out = 7'b0001000;
            7'h17: data_out = 7'b0000001;
            7'h18: data_out = 7'b0100000;
            7'h19: data_out = 7'b0000100;
            7'h1a: data_out = 7'b0000100;
            7'h1b: data_out = 7'b0000100;
            7'h1c: data_out = 7'b0001000;
            7'h1d: data_out = 7'b0000001;
            7'h1e: data_out = 7'b0010000;
				7'h1f: data_out = 7'b0000100;

            // Musica 3 - Aquarela 
            7'h20: data_out = 7'b0000100;
            7'h21: data_out = 7'b0010000;
            7'h22: data_out = 7'b0010000;
            7'h23: data_out = 7'b0010000;
            7'h24: data_out = 7'b0100000;
            7'h25: data_out = 7'b0010000;
            7'h26: data_out = 7'b0001000;
            7'h27: data_out = 7'b0000100;
            7'h28: data_out = 7'b0001000;
            7'h29: data_out = 7'b0010000;
            7'h2a: data_out = 7'b0000100;
            7'h2b: data_out = 7'b0000100;
            7'h2c: data_out = 7'b0010000;
            7'h2d: data_out = 7'b0010000;
            7'h2e: data_out = 7'b0010000;
            7'h2f: data_out = 7'b0100000;

            // Musica 4 - Asa Branca
            7'h30: data_out = 7'b0000100;
            7'h31: data_out = 7'b0001000;
            7'h32: data_out = 7'b0010000;
            7'h33: data_out = 7'b0000100;
            7'h34: data_out = 7'b0010000;
            7'h35: data_out = 7'b0010000;
            7'h36: data_out = 7'b0010000;
            7'h37: data_out = 7'b0001000;
            7'h38: data_out = 7'b0010000;
            7'h39: data_out = 7'b0001000;
            7'h3a: data_out = 7'b0000100;
            7'h3b: data_out = 7'b0000010;
            7'h3c: data_out = 7'b0000100;
            7'h3d: data_out = 7'b0000100;
            7'h3e: data_out = 7'b0000100;
            7'h3f: data_out = 7'b0001000;

            // Musica 5 - Evidencias
            7'h40: data_out = 7'b0000100;
            7'h41: data_out = 7'b0010000;
            7'h42: data_out = 7'b0010000;
            7'h43: data_out = 7'b0100000;
            7'h44: data_out = 7'b0010000;
            7'h45: data_out = 7'b0001000;
            7'h46: data_out = 7'b0000100;
            7'h47: data_out = 7'b0000100;
            7'h48: data_out = 7'b0010000;
            7'h49: data_out = 7'b0010000;
            7'h4a: data_out = 7'b0100000;
            7'h4b: data_out = 7'b0010000;
            7'h4c: data_out = 7'b0001000;
            7'h4d: data_out = 7'b0000100;
            7'h4e: data_out = 7'b0000100;
            7'h4f: data_out = 7'b0001000;

            // Musica 6 - Mario Bros
            7'h50: data_out = 7'b0000100;
            7'h51: data_out = 7'b0000100;
            7'h52: data_out = 7'b0000100;
            7'h53: data_out = 7'b0000001;
            7'h54: data_out = 7'b0000100;
            7'h55: data_out = 7'b0010000;
            7'h56: data_out = 7'b0010000;
            7'h57: data_out = 7'b0000001;
            7'h58: data_out = 7'b0010000;
            7'h59: data_out = 7'b0000100;
            7'h5a: data_out = 7'b0100000;
            7'h5b: data_out = 7'b1000000;
            7'h5c: data_out = 7'b0100000;
            7'h5d: data_out = 7'b0010000;
            7'h5e: data_out = 7'b0000001;
            7'h5f: data_out = 7'b0000001;

            // Musica 7
            7'h60: data_out = 7'b0000001;
            7'h61: data_out = 7'b0000010;
            7'h62: data_out = 7'b0000100;
            7'h63: data_out = 7'b0001000;
            7'h64: data_out = 7'b0010000;
            7'h65: data_out = 7'b0100000;
            7'h66: data_out = 7'b1000000;
            7'h67: data_out = 7'b0100000;
            7'h68: data_out = 7'b0010000;
            7'h69: data_out = 7'b0001000;
            7'h6a: data_out = 7'b0000100;
            7'h6b: data_out = 7'b0000010;
            7'h6c: data_out = 7'b0000001;
            7'h6d: data_out = 7'b0000010;
            7'h6e: data_out = 7'b0000100;
            7'h6f: data_out = 7'b0001000;

            // Musica 8
            7'h70: data_out = 7'b0000001;
            7'h71: data_out = 7'b0000010;
            7'h72: data_out = 7'b0000100;
            7'h73: data_out = 7'b0001000;
            7'h74: data_out = 7'b0010000;
            7'h75: data_out = 7'b0100000;
            7'h76: data_out = 7'b1000000;
            7'h77: data_out = 7'b0100000;
            7'h78: data_out = 7'b0010000;
            7'h79: data_out = 7'b0001000;
            7'h7a: data_out = 7'b0000100;
            7'h7b: data_out = 7'b0000010;
            7'h7c: data_out = 7'b0000001;
            7'h7d: data_out = 7'b0000010;
            7'h7e: data_out = 7'b0000100;
            7'h7f: data_out = 7'b0001000;
        endcase
    end
endmodule