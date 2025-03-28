module pontuacao();
// ======================================================
    // Lógica de Cálculo de Pontos
    // ======================================================
    // Registrador de pontos – ao ser "limpo" (clear) carrega o valor inicial de 100.
    registrador_7_init RegPontos (
      .clock  ( clock ),      
      .clear  ( zeraPontos ),      
      .enable ( regPontos ),     
      .D      ( s_resultado ), 
      .Q      ( s_pontos )
    );
    
    // Definir o total de rodadas com base no nível:
    // Se nivel = 0 (nível baixo) -> 8 rodadas; se nivel = 1 -> 16 rodadas.
    wire [7:0] total_rounds = (nivel) ? 8'd16 : 8'd8;
    // Soma dos números de 1 até total_rounds: total_rounds*(total_rounds+1)/2
    wire [15:0] sum_rounds = (total_rounds * (total_rounds + 8'd1)) >> 1;  // divisão por 2
    
    // Número da rodada atual (1-based): considerando que s_limite é o contador reiniciado a cada rodada.
    wire [7:0] round_num = {4'b0, s_limite} + 8'd1;
    
    // Cálculo dos pontos "base" para esta rodada, de forma que a soma dos pontos
    // de todas as rodadas seja 100 se não houver erros.
    wire [15:0] base_points_temp = round_num * 16'd100;
    wire [7:0] base_points = (base_points_temp / sum_rounds);  // divisão inteira
    
    // Penalidade: cada erro subtrai um valor fixo
    parameter PENALTY_UNIT = 8'd2;  // 2 pontos por erro
    wire [7:0] penalty = s_erros * PENALTY_UNIT;
    
    // Pontos ganhos na rodada: se a penalidade for maior que a base, ganha 0 pontos.
    wire [7:0] round_gain = (base_points > penalty) ? (base_points - penalty) : 8'd0;
    
    // Acumulação dos pontos: s_pontos é o acumulador atual (inicializado com 0).
    // Some o ganho da rodada, garantindo que o total não ultrapasse 100.
    wire [8:0] temp_score = s_pontos + round_gain;  // 9 bits para prevenir overflow
    wire [6:0] new_score = (temp_score > 9'd100) ? 7'd100 : temp_score[6:0];

    // Detecção da última rodada
    wire last_round = (round_num == total_rounds);
    
    // Bônus: se for a última rodada e não houve erros (em toda a rodada, ou se o contador de erros for zero),
    // soma 100 pontos (atenção: se desejar limitar o máximo a 100 mesmo com bônus, a lógica precisará ser ajustada).
    wire [7:0] perfect = (last_round && (s_erros == 4'd0)) ? 1'b1 : 1'b0;
    
    // Atualiza o registrador de pontos com o novo valor:
    // Se não for a última rodada, atualiza com new_score; se for, com final_score.
    
	 assign s_resultado = perfect ? 7'd100 : new_score;
	 always @(*) begin
		
		assign pontos = s_pontos;
	 end
end module