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

  




endmodule
