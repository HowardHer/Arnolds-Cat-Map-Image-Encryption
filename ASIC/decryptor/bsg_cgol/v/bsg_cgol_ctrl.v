module bsg_cgol_ctrl #(
   parameter `BSG_INV_PARAM(board_width_p)
  ,parameter `BSG_INV_PARAM(max_game_length_p)
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

  // assign frames_n = (ready_o & v_i) ? frames_i : 
  //                   (state_r == eRUN) ? frames_r - 1 : frames_r;


  // Determine how many times to run decryption 
  logic [32-1:0] log5_div2; // Assume for now greatest size is 256
  logic [32-1:0] log5;
  logic [32-1:0] log5_div6;

  log_base5 #(
    .board_width_p(board_width_p)
  ) log5_by2 (
    .val( (board_width_p / 2) ), 
    .log5( log5_div2 )
  );

  log_base5 #(
    .board_width_p(board_width_p)
  ) log5_by1 (
    .val( board_width_p ), 
    .log5( log5 )
  );

  log_base5 #(
    .board_width_p(board_width_p)
  ) log5_by6 (
    .val( (board_width_p / 6) ), 
    .log5( log5_div6 )
  );

  always_comb begin
    // BASE CASE
    frames_n = frames_r;

    // IF the program is already running, decrement by 1
    if (state_r == eRUN) begin
        frames_n = frames_r - 1;
    end
    
    // ELSE find the number of times to decrypt img
    else if (ready_o & v_i) begin
      if ((board_width_p % 2 == 0) && ((5 ** log5_div2) == (board_width_p >> 1))) begin
        frames_n = 3 * board_width_p - frames_i;
      end else if ((5 ** log5) == (board_width_p)) begin
        frames_n = 2 * board_width_p - frames_i;
      end else if ((board_width_p % 6 == 0) && ((5 ** log5_div6) == (board_width_p / 6))) begin
        frames_n = 2 * board_width_p - frames_i;
      end else begin
        frames_n = ((12 * board_width_p) / 7) - frames_i;
      end
    end
  end


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

// log_base5 log5_dim2 (.val(val), .log5())
module log_base5 #(
    parameter `BSG_INV_PARAM(board_width_p)
   ,localparam tmp_width_p = 32
) (
  input [tmp_width_p-1:0] val, // Assume for now greatest size is 256
  output logic [tmp_width_p-1:0] log5
);
  logic [tmp_width_p-1:0] val_copy;
  logic [5:0] i;
  
  always_comb begin
    log5 = 0;
    val_copy = val;

    for (i = 0; i < tmp_width_p; i = i + 1) begin
      if (val_copy >= 5) begin
        val_copy = val_copy / 5;
        log5 = log5 + 1;
      end else begin
        break;
      end
    end
  end

endmodule