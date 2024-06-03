################################################################################
#
# Init setup file
# Created by Genus(TM) Synthesis Solution on 06/03/2024 08:05:08
#
################################################################################
if { ![is_common_ui_mode] } { error "ERROR: This script requires common_ui to be active."}

read_mmmc genus_invs_des/genus.mmmc.tcl

read_physical -lef {/home/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption/ASIC/encryptor/bsg_acm_cell/build/tech-sky130-cache/sky130_fd_sc_hd__nom.tlef /home/projects/ee477.2023wtr/cad/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef}

read_netlist genus_invs_des/genus.v.gz

init_design
