/**
* Arnold's Cat Map Encryption
*
* when en_i==1:
*   simulate the image pixel cell transition of image bit (1 or 0)
* else when update_i==1:
*   update the image pixel cell status to update_val_i
* else:
*   image pixel cell status remains unchanged
**/

module bsg_acm_cell 
(    input clk_i

    ,input en_i          
    ,input [7:0] data_i

    ,input update_i     
    ,input update_val_i

    ,output logic data_o
  );
  
  logic data_r, data_n;
  logic [3:0] count;

  bsg_popcount #(.width_p(8)) COUNT_ONE (.i(data_i) , .o(count));

  always_comb begin
    data_n = data_r;
    if (en_i) begin
      data_n = ((data_r | count[0]) & (count[1] & ~count[2]));
    end else if (update_i) begin
      data_n = update_val_i; 
    end
  end

  always_ff @ (posedge clk_i) begin
    data_r <= data_n;
  end

  assign data_o = data_r;

endmodule