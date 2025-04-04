module comparador_85_7bits (ALBi, AGBi, AEBi, A, B, ALBo, AGBo, AEBo);

    input[6:0] A, B;
    input      ALBi, AGBi, AEBi;
    output     ALBo, AGBo, AEBo;
    wire[7:0]  CSL, CSG;

    assign CSL  = ~A + B + ALBi;
    assign ALBo = ~CSL[7];
    assign CSG  = A + ~B + AGBi;
    assign AGBo = ~CSG[7];
    assign AEBo = ((A == B) && AEBi);

endmodule