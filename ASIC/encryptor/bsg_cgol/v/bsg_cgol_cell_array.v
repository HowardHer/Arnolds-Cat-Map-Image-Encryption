module bsg_cgol_cell_array #(
   parameter `BSG_INV_PARAM(board_width_p)
  ,localparam num_total_cells_lp = board_width_p*board_width_p
)
  (input clk_i

  ,input [num_total_cells_lp-1:0] data_i
  ,input en_i
  ,input update_i

  ,output logic [num_total_cells_lp-1:0] data_o
  );

  logic [num_total_cells_lp-1:0] data_r;
  logic [num_total_cells_lp-1:0] data_n;

  always_comb begin
    data_n = data_r;
    if (en_i) begin
        // Arnold Cat Transform (Encryption) 
        for(int x = 0; x < board_width_p; x++) begin
          for(int y = 0; y < board_width_p; y++) begin
            data_n[x*board_width_p+y] = data_r[((x+y)%board_width_p)*board_width_p + ((x+2*y)%board_width_p)];
          end
        end
    end else if (update_i) begin
        data_n = data_i; 
    end
  end

  always_ff @ (posedge clk_i) begin
    data_r <= data_n;
  end

  assign data_o = data_r;
  
endmodule