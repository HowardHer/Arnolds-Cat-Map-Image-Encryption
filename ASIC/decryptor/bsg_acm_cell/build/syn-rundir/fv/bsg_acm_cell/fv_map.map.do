
//input ports
add mapped point clk_i clk_i -type PI PI
add mapped point en_i en_i -type PI PI
add mapped point data_i[7] data_i[7] -type PI PI
add mapped point data_i[6] data_i[6] -type PI PI
add mapped point data_i[5] data_i[5] -type PI PI
add mapped point data_i[4] data_i[4] -type PI PI
add mapped point data_i[3] data_i[3] -type PI PI
add mapped point data_i[2] data_i[2] -type PI PI
add mapped point data_i[1] data_i[1] -type PI PI
add mapped point data_i[0] data_i[0] -type PI PI
add mapped point update_i update_i -type PI PI
add mapped point update_val_i update_val_i -type PI PI

//output ports
add mapped point data_o data_o -type PO PO

//inout ports




//Sequential Pins
add mapped point data_r/q data_r_reg/Q  -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
