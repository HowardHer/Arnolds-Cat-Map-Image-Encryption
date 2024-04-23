module bsg_cgol_ctrl #(
   parameter `BSG_INV_PARAM(max_game_length_p)
  ,localparam game_len_width_lp=`BSG_SAFE_CLOG2(max_game_length_p+1)
) (
   input clk_i
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
  
  // TODO: Design your control logic

  typedef enum logic [1:0] {eWAIT, eRUN, eDONE} state_e;

  state_e  state_n, state_r;

  assign ready_o = state_r == eWAIT;
  assign     v_o = state_r == eDONE;

  assign update_o = (state_r == eWAIT) & v_i;
  assign en_o     = (state_r == eRUN) ? 1 : 0;

  logic [game_len_width_lp-1:0] frames_n, frames_r;

  assign frames_n = (ready_o & v_i) ? frames_i : 
                    (state_r == eRUN) ? frames_r - 1 : frames_r;

  // Determine State
  always_comb begin
    state_n = state_r;
    if (ready_o & v_i) begin
      state_n = eRUN;
      // WAIT -> RUN
    end else if ((state_r == eRUN) & (frames_n == 0)) begin
      state_n = eDONE;
      // RUN -> DONE
    end else if (v_o & yumi_i) begin
      state_n = eWAIT;
      // DONE -> WAIT
    end
  end

  always_ff @ (posedge clk_i) begin
    frames_r <= frames_n;
  end

  always_ff @ (posedge clk_i) begin
    if (reset_i)
      state_r <= eWAIT;
    else
      state_r <= state_n;
  end

endmodule