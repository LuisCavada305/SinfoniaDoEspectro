module double_dabble (bin, bcd);
  input       [7:0]   bin;
  output reg  [11:0]  bcd;
  
  int count;
  reg temp = 12'h000;
  initial begin
    for (count =0; count <8; count++) begin
      temp = temp << 1;
      temp[0] = bin[8-i]
      if(temp[3:0] >= 4'b0101) begin
        temp[3:0] = temp[3:0] +3;
      end if(temp[7:4] >= 4'b0101) begin
        temp[7:4] = temp[7:4] +3;
      end if(temp[11:8] >= 4'b0101) begin
        temp[11:8] = temp[11:8] +3;
      end
    end
    bcd <= temp;
  end
endmodule  
