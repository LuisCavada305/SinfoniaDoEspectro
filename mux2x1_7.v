

module mux2x1_7 (
    input   	[6:0]   D0,
    input   	[6:0]   D1,
    input     			  SEL,
    output reg [6:0]   OUT
);

always @(*) begin
    case (SEL)
        1'b0:    OUT = D0;
        1'b1:    OUT = D1;
        default: OUT = 7'b1111111; // saida em 1
    endcase
end

endmodule
