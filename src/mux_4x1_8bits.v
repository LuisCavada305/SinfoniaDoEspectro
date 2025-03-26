module mux_4x1_8bits (
  input   	[7:0]   D0,
  input   	[7:0]   D1,
  input   	[7:0]   D2,
  input   	[7:0]   D3,
  input     [1:0]	  SEL,
  output reg [7:0]   OUT
);

always @(*) begin
    case (SEL)
        2'b00:    OUT = D0;
        2'b01:    OUT = D1;
        2'b10:    OUT = D2;
        2'b11:    OUT = D3;
        default:  OUT = 8'b11111111; // saida em 1
    endcase
end

endmodule
