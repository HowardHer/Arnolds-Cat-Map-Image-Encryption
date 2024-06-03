puts "set_db hdl_error_on_blackbox true" 
set_db hdl_error_on_blackbox true
puts "set_db max_cpus_per_server 8" 
set_db max_cpus_per_server 8
puts "set_db hdl_auto_sync_set_reset true" 
set_db hdl_auto_sync_set_reset true
puts "set_db hdl_unconnected_value none" 
set_db hdl_unconnected_value none
puts "set_db lp_clock_gating_infer_enable  true" 
set_db lp_clock_gating_infer_enable  true
puts "set_db lp_clock_gating_prefix  {CLKGATE}" 
set_db lp_clock_gating_prefix  {CLKGATE}
puts "set_db lp_insert_clock_gating  true" 
set_db lp_insert_clock_gating  true
puts "set_db lp_clock_gating_hierarchical true" 
set_db lp_clock_gating_hierarchical true
puts "set_db lp_insert_clock_gating_incremental true" 
set_db lp_insert_clock_gating_incremental true
puts "set_db lp_clock_gating_register_aware true" 
set_db lp_clock_gating_register_aware true
puts "read_mmmc /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/syn-rundir/mmmc.tcl" 
read_mmmc /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/syn-rundir/mmmc.tcl
puts "read_physical -lef { /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/tech-sky130-cache/sky130_fd_sc_hd__nom.tlef /home/projects/ee477.2023wtr/cad/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef }" 
read_physical -lef { /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/tech-sky130-cache/sky130_fd_sc_hd__nom.tlef /home/projects/ee477.2023wtr/cad/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef }
puts "read_hdl -sv { /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/v/bsg_acm_cell.v /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/basejump_stl/bsg_misc/bsg_popcount.v }" 
read_hdl -sv { /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/v/bsg_acm_cell.v /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/basejump_stl/bsg_misc/bsg_popcount.v }
puts "elaborate bsg_acm_cell" 
elaborate bsg_acm_cell
puts "init_design -top bsg_acm_cell" 
init_design -top bsg_acm_cell
puts "set_db root: .auto_ungroup none" 
set_db root: .auto_ungroup none
puts "set_units -capacitance 1.0pF" 
set_units -capacitance 1.0pF
puts "set_load_unit -picofarads 1" 
set_load_unit -picofarads 1
puts "set_units -time 1.0ns" 
set_units -time 1.0ns

puts "set_dont_use \[get_db lib_cells */*sdf*\]"
if { [get_db lib_cells */*sdf*] ne "" } {
    set_dont_use [get_db lib_cells */*sdf*]
} else {
    puts "WARNING: cell */*sdf* was not found for set_dont_use"
}
            

puts "set_dont_use \[get_db lib_cells */sky130_fd_sc_hd__probe_p_*\]"
if { [get_db lib_cells */sky130_fd_sc_hd__probe_p_*] ne "" } {
    set_dont_use [get_db lib_cells */sky130_fd_sc_hd__probe_p_*]
} else {
    puts "WARNING: cell */sky130_fd_sc_hd__probe_p_* was not found for set_dont_use"
}
            

puts "set_dont_use \[get_db lib_cells */sky130_fd_sc_hd__probec_p_*\]"
if { [get_db lib_cells */sky130_fd_sc_hd__probec_p_*] ne "" } {
    set_dont_use [get_db lib_cells */sky130_fd_sc_hd__probec_p_*]
} else {
    puts "WARNING: cell */sky130_fd_sc_hd__probec_p_* was not found for set_dont_use"
}
            
puts "write_db -to_file pre_genus_syn_with_preserve" 
write_db -to_file pre_genus_syn_with_preserve
puts "syn_generic" 
syn_generic
puts "write_db -to_file pre_genus_maybe_syn_map" 
write_db -to_file pre_genus_maybe_syn_map
puts "syn_map" 
syn_map
puts "write_db -to_file pre_add_tieoffs" 
write_db -to_file pre_add_tieoffs
puts "set_db message:WSDF-201 .max_print 20" 
set_db message:WSDF-201 .max_print 20
puts "set_db use_tiehilo_for_const duplicate" 
set_db use_tiehilo_for_const duplicate
puts "add_tieoffs -high sky130_fd_sc_hd__conb_1 -low sky130_fd_sc_hd__conb_1 -max_fanout 1 -verbose" 
add_tieoffs -high sky130_fd_sc_hd__conb_1 -low sky130_fd_sc_hd__conb_1 -max_fanout 1 -verbose
puts "write_db -to_file pre_write_regs" 
write_db -to_file pre_write_regs

        set write_cells_ir "./find_regs_cells.json"
        set write_cells_ir [open $write_cells_ir "w"]
        puts $write_cells_ir "\["

        set refs [get_db [get_db lib_cells -if .is_sequential==true] .base_name]

        set len [llength $refs]

        for {set i 0} {$i < [llength $refs]} {incr i} {
            if {$i == $len - 1} {
                puts $write_cells_ir "    \"[lindex $refs $i]\""
            } else {
                puts $write_cells_ir "    \"[lindex $refs $i]\","
            }
        }

        puts $write_cells_ir "\]"
        close $write_cells_ir
        set write_regs_ir "./find_regs_paths.json"
        set write_regs_ir [open $write_regs_ir "w"]
        puts $write_regs_ir "\["

        set regs [get_db [get_db [all_registers -edge_triggered -output_pins] -if .direction==out] .name]

        set len [llength $regs]

        for {set i 0} {$i < [llength $regs]} {incr i} {
            #regsub -all {/} [lindex $regs $i] . myreg
            set myreg [lindex $regs $i]
            if {$i == $len - 1} {
                puts $write_regs_ir "    \"$myreg\""
            } else {
                puts $write_regs_ir "    \"$myreg\","
            }
        }

        puts $write_regs_ir "\]"

        close $write_regs_ir
        
puts "write_db -to_file pre_generate_reports" 
write_db -to_file pre_generate_reports
puts "write_reports -directory reports -tag final" 
write_reports -directory reports -tag final
puts "write_db -to_file pre_write_outputs" 
write_db -to_file pre_write_outputs
puts "update_names -suffix _mapped -module" 
update_names -suffix _mapped -module
puts "write_hdl > /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/syn-rundir/bsg_acm_cell.mapped.v" 
write_hdl > /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/syn-rundir/bsg_acm_cell.mapped.v
puts "write_script > bsg_acm_cell.mapped.scr" 
write_script > bsg_acm_cell.mapped.scr
puts "write_sdc -view ss_100C_1v60.setup_view > /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/syn-rundir/bsg_acm_cell.mapped.sdc" 
write_sdc -view ss_100C_1v60.setup_view > /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/syn-rundir/bsg_acm_cell.mapped.sdc
puts "write_sdf -nosplit_timing_check -timescale ns > /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/syn-rundir/bsg_acm_cell.mapped.sdf" 
write_sdf -nosplit_timing_check -timescale ns > /home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/syn-rundir/bsg_acm_cell.mapped.sdf
puts "write_design -innovus -hierarchical -gzip_files bsg_acm_cell" 
write_design -innovus -hierarchical -gzip_files bsg_acm_cell
puts "quit" 
quit