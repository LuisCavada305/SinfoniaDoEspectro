module mux_2x1_5bits (
  input   	[4:0]   D0,
  input   	[4:0]   D1,
  input         	  SEL,
  output reg [4:0]   OUT
);

always @(*) begin
    case (SEL)
        1'b0:    OUT = D0;
        1'b1:    OUT = D1;
        default:  OUT = 5'b11111; // saida em 1
    endcase
end

endmodule