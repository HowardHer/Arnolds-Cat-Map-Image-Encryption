module bsg_cgol_ctrl #(parameter `BSG_INV_PARAM(max_game_length_p)
  ,localparam game_len_width_lp=`BSG_SAFE_CLOG2(max_game_length_p+1)) 
  
  (input clk_i
  ,input reset_i
  ,input en_i

  // Input Data Channel
  ,input  [game_len_width_lp-1:0] frames_i
  ,input  v_i
  ,output ready_o

  // Output Data Channel
  ,input yumi_i
  ,output v_o

  // Cell Array
  ,output update_o
  ,output en_o
);

  wire unused = en_i; // for clock gating, unused
  
  // Design of control logic
  typedef enum logic [1:0] {eWAIT, eRUN, eDONE} state_e;

  state_e  state_n, state_r;

  logic [game_len_width_lp-1:0] frames_n, frames_r;

  assign ready_o = state_r == eWAIT;
  assign     v_o = state_r == eDONE;

  assign update_o = (state_r == eWAIT) & v_i;
  assign en_o     = state_r == eRUN;

  // Determine State
  always_comb begin
    state_n = state_r;
    if (ready_o & v_i) begin // WAIT -> UPDATE
      state_n = eRUN;
    end else if ((state_r == eRUN) & (frames_n == 0)) begin  // RUN -> DONE
      state_n = eDONE;
    end else if (v_o & yumi_i) begin  // DONE -> WAIT
      state_n = eWAIT;
    end
  end

  always_ff @ (posedge clk_i) begin
    if (reset_i)
      state_r <= eWAIT;
    else
      state_r <= state_n;
  end
  
  assign frames_n = (ready_o & v_i) ? frames_i :                          // WAIT
                    ((state_r == eRUN) & (frames_r > 0)) ? frames_r - 1 : // RUN
                     frames_r;

  always_ff @ (posedge clk_i) begin
    frames_r <= frames_n;
  end



endmodule