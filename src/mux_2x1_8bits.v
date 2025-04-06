module mux_2x1_8bits (
  input   	[7:0]   D0,
  input   	[7:0]   D1,
  input         	  SEL,
  output reg [7:0]   OUT
);

always @(*) begin
    case (SEL)
        1'b0:    OUT = D0;
        1'b1:    OUT = D1;
        default:  OUT = 8'b11111111; // saida em 1
    endcase
end

endmodule
