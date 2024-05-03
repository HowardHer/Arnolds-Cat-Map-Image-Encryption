// ee477-designs-final-project/bsg_cgol_cell/v/bsg_cgol_cell.v

/**
* Conway's Game of Life Cell
*
* data_i[7:0] is status of 8 neighbor cells
* data_o is status this cell
* 1: alive, 0: death
*
* when en_i==1:
*   simulate the cell transition with 8 given neighors
* else when update_i==1:
*   update the cell status to update_val_i
* else:
*   cell status remains unchanged
**/

module bsg_cgol_cell 
(    input clk_i

    ,input en_i          
    ,input [7:0] data_i

    ,input update_i     
    ,input update_val_i

    ,output logic data_o
  );

  // TODO: Design your bsg_cgl_cell
  // Hint: Find the module to count the number of neighbors from basejump
  
  logic data_r, data_n;
  logic [3:0] count;

  bsg_popcount #(.width_p(8)) COUNT_ONE (.i(data_i) , .o(count));

  always_comb begin
    data_n = data_r;
    if (en_i) begin
      if ((data_r == 1'b0) && (count == 3'b011)) begin
          data_n = 1'b1;
      end else if ((data_r == 1'b1) && (count < 3'b010)) begin
          data_n = 1'b0;
      end else if ((data_r == 1'b1) && (count > 3'b011)) begin
          data_n = 1'b0;
      end else if (data_r == 1'b1 && (count == 3'b010 || count == 3'b011)) begin
          data_n = 1'b1;
      end
    end else if (update_i) begin
        data_n = update_val_i; 
    end
  end

  always_ff @ (posedge clk_i) begin
    data_r <= data_n;
  end

  assign data_o = data_r;

endmodule