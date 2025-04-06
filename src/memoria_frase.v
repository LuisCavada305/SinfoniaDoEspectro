module memoria_frase (address, data_out);
    input      [4:0] address;
    output reg [4:0] data_out;

    always @ (address)
    begin
        case (address)
            5'h00: data_out = 5'h05;
            5'h01: data_out = 5'h13;
            5'h02: data_out = 5'h03;
            5'h03: data_out = 5'h0f;
            5'h04: data_out = 5'h0c;
            5'h05: data_out = 5'h08;
            5'h06: data_out = 5'h01;
            5'h07: data_out = 5'h00;
            5'h08: data_out = 5'h15;
            5'h09: data_out = 5'h0d;
            5'h0a: data_out = 5'h01;
            5'h0b: data_out = 5'h00;
            5'h0c: data_out = 5'h0d;
            5'h0d: data_out = 5'h15;
            5'h0e: data_out = 5'h13;
            5'h0f: data_out = 5'h09;
            5'h10: data_out = 5'h03;
            5'h11: data_out = 5'h01;
            5'h12: data_out = 5'h00;
            5'h13: data_out = 5'h00;
            5'h14: data_out = 5'h00;
            5'h15: data_out = 5'h05;
            5'h16: data_out = 5'h13;
            5'h17: data_out = 5'h03;
            default: data_out = 5'h00;
        endcase
    end
endmodule