module sinfonia_do_espectro (
    
    // Entradas
    input         clock,
    input         reset,
    input         jogar,
    input         treinamento,
    input  [6:0]  botoes,
    
    // Saidas
    output        acertou,
    output        errou,
    output        pronto,
    output [2:0]  arduino_out,
    output [11:0] display,
    
    // Depuração
    output        db_clock,
    output        db_reset,
    output        db_jogar,
    output        db_botoesIgualMemoria,
    output        db_tem_botao_pressionado,
    output [2:0]  db_data_out_sync,
    output [6:0]  db_jogada,
    output [6:0]  db_memoria,
    output [6:0]  db_contagem,
    output [6:0]  db_limite,
    output [6:0]  db_estado0,
    output [6:0]  db_estado1,
    output [6:0]  db_ones,
    output [6:0]  db_tens,
    output [6:0]  db_hundreds
	 
);

// Sinais internos
    wire s_activate_arduino;
    wire s_botoesIgualMemoria;
    wire s_calcular_pontos;
    wire s_enable_timer_buzzer;
    wire s_enable_contador_erro;
    wire s_enable_contador_msg;
    wire s_select_mux_display;
    wire s_enable_registrador_botoes; 
    wire s_enable_registrador_musica;
    wire s_enable_timer_msg;
    wire s_enable_contador_jogada; 
    wire s_enable_contador_rodada; 
    wire s_enderecoIgualMemoria;
    wire s_enderecoIgualLimite;
    wire s_fimL;    
    wire s_jogar; 
    wire s_mostraPontos;
    wire s_timeout_contador_buzzer;
    wire s_enable_registrador_pontos;
    wire s_select_mux_arduino; 
    wire s_select_mux_letra;
    wire s_tem_botao_pressionado;
    wire s_tem_jogada;
    wire s_timeout_contador_msg;
    wire s_zera_contador_msg;
    wire s_zera_contador_display;
    wire s_zera_contador_jogada; 
    wire s_zera_contador_rodada; 
    wire s_zera_registrador_botoes; 
    wire s_zera_timer_msg;
    wire s_zera_timer_buzzer;
    wire s_zera_contador_erro;
    wire s_zera_registrador_pontos;
    wire [1:0] s_contagem_display;
    wire [3:0] s_ones;
    wire [3:0] s_tens;
    wire [3:0] s_hundreds;
    wire [3:0] s_contagem;
    wire [3:0] s_limite;
    wire [4:0] s_estado;
    wire [4:0] s_letra;
    wire [6:0] s_jogada;
    wire [6:0] s_memoria;
    wire [7:0] s_pontos;

    // Instância do módulo de fluxo de dados
    fluxo_dados FD(
        .activate_arduino           (s_activate_arduino         ),
        .arduino_out                (arduino_out                ),
        .botoes                     (botoes                     ),
        .botoesIgualMemoria         (s_botoesIgualMemoria       ),
        .calcular_pontos            (s_calcular_pontos          ),
        .clock                      (clock                      ),
        .enable_timer_buzzer        (s_enable_timer_buzzer      ),
        .enable_contador_erro       (s_enable_contador_erro     ),
        .contagem_display           (s_contagem_display         ),
        .db_limite                  (s_limite                   ),
        .db_contagem                (s_contagem                 ),
        .db_data_out_sync           (db_data_out_sync           ),
        .db_jogada                  (s_jogada                   ),
        .db_memoria                 (s_memoria                  ),
        .enable_contador_jogada     (s_enable_contador_jogada   ),
        .enable_contador_msg        (s_enable_contador_msg      ),
        .enable_contador_rodada     (s_enable_contador_rodada   ),
        .enable_registrador_botoes  (s_enable_registrador_botoes),
        .enable_registrador_musica  (s_enable_registrador_musica),
        .enable_timer_msg           (s_enable_timer_msg         ),
        .enderecoIgualLimite        (s_enderecoIgualMemoria     ),
        .fimL                       (s_fimL                     ),
        .letra                      (s_letra                    ),
        .timeout_contador_buzzer    (s_timeout_contador_buzzer  ),
        .pontos                     (s_pontos                   ),
        .enable_registrador_pontos  (s_enable_registrador_pontos),
        .select_mux_arduino         (s_select_mux_arduino       ),
        .select_mux_letra           (s_select_mux_letra         ),
        .tem_botao_pressionado      (s_tem_botao_pressionado    ),
        .tem_jogada                 (s_tem_jogada               ),
        .timeout_contador_msg       (s_timeout_contador_msg     ),
        .zera_contador_erro         (s_zera_contador_erro       ),
        .zera_contador_rodada       (s_zera_contador_rodada     ),
        .zera_contador_msg          (s_zera_contador_msg        ),
        .zera_contador_jogada       (s_zera_contador_jogada     ),
        .zera_registrador_botoes    (s_zera_registrador_botoes  ),
        .zera_timer_buzzer          (s_zera_timer_buzzer        ),
        .zera_timer_msg             (s_zera_timer_msg           ),
        .zera_registrador_pontos    (s_zera_registrador_pontos  )
      );

    // Instância do módulo de unidade de controle
    unidade_controle UC(
        .acertou                    (acertou                    ),
        .activate_arduino           (s_activate_arduino         ),
        .botoesIgualMemoria         (s_botoesIgualMemoria       ),
        .calcular_pontos            (s_calcular_pontos          ),
        .enable_timer_buzzer        (s_enable_timer_buzzer      ),
        .enable_contador_erro       (s_enable_contador_erro     ),
        .clock                      (clock                      ),
        .db_estado                  (s_estado                   ),
        .enderecoIgualLimite        (s_enderecoIgualMemoria     ),
        .fimL                       (s_fimL                     ),
        .enable_contador_jogada     (s_enable_contador_jogada   ),
        .enable_contador_msg        (s_enable_contador_msg      ),
        .enable_contador_rodada     (s_enable_contador_rodada   ),
        .enable_registrador_botoes  (s_enable_registrador_botoes),
        .enable_registrador_musica  (s_enable_registrador_musica),
        .enable_timer_msg           (s_enable_timer_msg         ),
        .jogar                      (s_jogar                    ),
        .mostraPontos               (s_mostraPontos             ),
        .timeout_contador_buzzer    (s_timeout_contador_buzzer  ),
        .pronto                     (pronto                     ),
        .enable_registrador_pontos  (s_enable_registrador_pontos),
        .reset                      (reset                      ),
        .select_mux_arduino         (s_select_mux_arduino       ),
        .select_mux_letra           (s_select_mux_letra         ),
        .select_mux_display         (s_select_mux_display       ),
        .errou                      (errou                      ),
        .tem_botao_pressionado      (s_tem_botao_pressionado    ),
        .tem_jogada                 (s_tem_jogada               ),
        .timeout_contador_msg       (s_timeout_contador_msg     ),
        .treinamento                (treinamento                ),
        .zera_contador_display      (s_zera_contador_display    ),
        .zera_contador_jogada       (s_zera_contador_jogada     ),
        .zera_contador_msg          (s_zera_contador_msg        ),
        .zera_contador_rodada       (s_zera_contador_rodada     ),
        .zera_registrador_botoes    (s_zera_registrador_botoes  ),
        .zera_timer_msg             (s_zera_timer_msg           ),
        .zera_timer_buzzer          (s_zera_timer_buzzer        ),
        .zera_contador_erro         (s_zera_contador_erro       ),
        .zera_registrador_pontos    (s_zera_registrador_pontos  )
    );

    // Instâncias de módulos de depuração e exibição
    hexa7seg HEX0(
        .hexa       (s_ones),
        .display    (db_ones)
    );
	 
	 hexa7seg HEX1(
        .hexa       (s_tens),
        .display    (db_tens)
    );
	 
	 hexa7seg HEX2(
        .hexa       (s_hundreds ),
        .display    (db_hundreds)
    );

    hexa7seg HEX3(
        .hexa       (s_limite   ),
        .display    (db_limite  )
    );

    hexa7seg HEX4(
        .hexa       (s_estado[3:0]  ),
        .display    (db_estado0     )
    );

    hexa7seg HEX5(
        .hexa       ({3'b000, s_estado[4]}  ),
        .display    (db_estado1             )
    );

    hexa7seg HEX6(
        .hexa       (s_contagem  ),
        .display    (db_contagem )
    );

    // O módulo edge_detector gera o sinal s_jogar a partir do sinal jogar
    edge_detector detector_borda(
        .clock(clock    ),
        .reset(reset    ),
        .sinal(jogar    ),
        .pulso(s_jogar  )
    );
    
    // Sinais de depuração adicionais
    assign db_botoesIgualMemoria    = s_botoesIgualMemoria;
    assign db_clock                 = clock;
    assign db_jogada                = s_jogada;
    assign db_jogar                 = jogar;
    assign db_memoria               = s_memoria;
    assign db_reset                 = reset;
    assign db_tem_botao_pressionado = s_tem_botao_pressionado;
    
    conversor7seg convPontos (
        .clock(clock),
        .zera_contador_display  (s_zera_contador_display),
        .letra                  (s_letra                ),
        .numero                 (s_pontos               ),
        .select                 (s_select_mux_display   ),
        .contagem_display       (s_contagem_display     ),
        .db_ones                (s_ones                 ),
        .db_tens                (s_tens                 ),
        .db_hundreds            (s_hundreds             ),
        .display                (display                )
    );

endmodule