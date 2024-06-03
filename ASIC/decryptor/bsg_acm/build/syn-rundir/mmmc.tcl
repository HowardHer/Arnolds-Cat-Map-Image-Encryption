puts "create_constraint_mode -name my_constraint_mode -sdc_files [list /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/build/syn-rundir/clock_constraints_fragment.sdc /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/build/syn-rundir/pin_constraints_fragment.sdc /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/cfg/../../../ee477-hammer-cad/tcl/bsg_tag_timing.tcl /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/cfg/../../../ee477-hammer-cad/tcl/bsg_chip/bsg_chip_timing_constraint.tcl /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/cfg/constraints.tcl]" 
create_constraint_mode -name my_constraint_mode -sdc_files [list /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/build/syn-rundir/clock_constraints_fragment.sdc /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/build/syn-rundir/pin_constraints_fragment.sdc /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/cfg/../../../ee477-hammer-cad/tcl/bsg_tag_timing.tcl /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/cfg/../../../ee477-hammer-cad/tcl/bsg_chip/bsg_chip_timing_constraint.tcl /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/decryptor/bsg_acm/cfg/constraints.tcl]
puts "create_library_set -name ss_100C_1v60.setup_set -timing [list /home/projects/ee477.2023wtr/cad/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib]" 
create_library_set -name ss_100C_1v60.setup_set -timing [list /home/projects/ee477.2023wtr/cad/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib]
puts "create_timing_condition -name ss_100C_1v60.setup_cond -library_sets [list ss_100C_1v60.setup_set]" 
create_timing_condition -name ss_100C_1v60.setup_cond -library_sets [list ss_100C_1v60.setup_set]
puts "create_rc_corner -name ss_100C_1v60.setup_rc -temperature 100.0  -cap_table /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/ee477-hammer-cad/hammer/src/hammer-vlsi/technology/sky130/extra/sky130.captbl" 
create_rc_corner -name ss_100C_1v60.setup_rc -temperature 100.0  -cap_table /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/ee477-hammer-cad/hammer/src/hammer-vlsi/technology/sky130/extra/sky130.captbl
puts "create_delay_corner -name ss_100C_1v60.setup_delay -timing_condition ss_100C_1v60.setup_cond -rc_corner ss_100C_1v60.setup_rc" 
create_delay_corner -name ss_100C_1v60.setup_delay -timing_condition ss_100C_1v60.setup_cond -rc_corner ss_100C_1v60.setup_rc
puts "create_analysis_view -name ss_100C_1v60.setup_view -delay_corner ss_100C_1v60.setup_delay -constraint_mode my_constraint_mode" 
create_analysis_view -name ss_100C_1v60.setup_view -delay_corner ss_100C_1v60.setup_delay -constraint_mode my_constraint_mode
puts "create_library_set -name ff_n40C_1v95.hold_set -timing [list /home/projects/ee477.2023wtr/cad/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95_ccsnoise.lib]" 
create_library_set -name ff_n40C_1v95.hold_set -timing [list /home/projects/ee477.2023wtr/cad/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95_ccsnoise.lib]
puts "create_timing_condition -name ff_n40C_1v95.hold_cond -library_sets [list ff_n40C_1v95.hold_set]" 
create_timing_condition -name ff_n40C_1v95.hold_cond -library_sets [list ff_n40C_1v95.hold_set]
puts "create_rc_corner -name ff_n40C_1v95.hold_rc -temperature -40.0  -cap_table /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/ee477-hammer-cad/hammer/src/hammer-vlsi/technology/sky130/extra/sky130.captbl" 
create_rc_corner -name ff_n40C_1v95.hold_rc -temperature -40.0  -cap_table /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/ee477-hammer-cad/hammer/src/hammer-vlsi/technology/sky130/extra/sky130.captbl
puts "create_delay_corner -name ff_n40C_1v95.hold_delay -timing_condition ff_n40C_1v95.hold_cond -rc_corner ff_n40C_1v95.hold_rc" 
create_delay_corner -name ff_n40C_1v95.hold_delay -timing_condition ff_n40C_1v95.hold_cond -rc_corner ff_n40C_1v95.hold_rc
puts "create_analysis_view -name ff_n40C_1v95.hold_view -delay_corner ff_n40C_1v95.hold_delay -constraint_mode my_constraint_mode" 
create_analysis_view -name ff_n40C_1v95.hold_view -delay_corner ff_n40C_1v95.hold_delay -constraint_mode my_constraint_mode
puts "create_library_set -name tt_025C_1v80.extra_set -timing [list /home/projects/ee477.2023wtr/cad/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib]" 
create_library_set -name tt_025C_1v80.extra_set -timing [list /home/projects/ee477.2023wtr/cad/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib]
puts "create_timing_condition -name tt_025C_1v80.extra_cond -library_sets [list tt_025C_1v80.extra_set]" 
create_timing_condition -name tt_025C_1v80.extra_cond -library_sets [list tt_025C_1v80.extra_set]
puts "create_rc_corner -name tt_025C_1v80.extra_rc -temperature 25.0  -cap_table /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/ee477-hammer-cad/hammer/src/hammer-vlsi/technology/sky130/extra/sky130.captbl" 
create_rc_corner -name tt_025C_1v80.extra_rc -temperature 25.0  -cap_table /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/ee477-hammer-cad/hammer/src/hammer-vlsi/technology/sky130/extra/sky130.captbl
puts "create_delay_corner -name tt_025C_1v80.extra_delay -timing_condition tt_025C_1v80.extra_cond -rc_corner tt_025C_1v80.extra_rc" 
create_delay_corner -name tt_025C_1v80.extra_delay -timing_condition tt_025C_1v80.extra_cond -rc_corner tt_025C_1v80.extra_rc
puts "create_analysis_view -name tt_025C_1v80.extra_view -delay_corner tt_025C_1v80.extra_delay -constraint_mode my_constraint_mode" 
create_analysis_view -name tt_025C_1v80.extra_view -delay_corner tt_025C_1v80.extra_delay -constraint_mode my_constraint_mode
puts "set_analysis_view -setup { ss_100C_1v60.setup_view } -hold { ff_n40C_1v95.hold_view tt_025C_1v80.extra_view }" 
set_analysis_view -setup { ss_100C_1v60.setup_view } -hold { ff_n40C_1v95.hold_view tt_025C_1v80.extra_view }