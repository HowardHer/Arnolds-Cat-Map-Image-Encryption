# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.12-s068_1 on Mon Jun 03 08:05:07 UTC 2024

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design bsg_acm_cell

create_clock -name "clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk_i]
set_load -pin_load 0.005 [get_ports data_o]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports en_i]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports {data_i[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports {data_i[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports {data_i[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports {data_i[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports {data_i[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports {data_i[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports {data_i[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports {data_i[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports update_i]
set_input_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports update_val_i]
set_output_delay -clock [get_clocks clk] -add_delay -max 5.0 [get_ports data_o]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports en_i]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {data_i[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {data_i[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {data_i[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {data_i[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {data_i[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {data_i[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {data_i[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {data_i[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports update_i]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports update_val_i]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports data_o]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__probe_p_8]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__probec_p_8]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfbbn_1]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfbbn_2]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfbbp_1]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfrbp_1]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfrbp_2]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfrtn_1]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfrtp_1]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfrtp_2]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfrtp_4]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfsbp_1]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfsbp_2]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfstp_1]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfstp_2]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfstp_4]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfxbp_1]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfxbp_2]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfxtp_1]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfxtp_2]
set_dont_use true [get_lib_cells sky130_fd_sc_hd__ss_100C_1v60/sky130_fd_sc_hd__sdfxtp_4]
set_clock_uncertainty -setup 0.1 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]
