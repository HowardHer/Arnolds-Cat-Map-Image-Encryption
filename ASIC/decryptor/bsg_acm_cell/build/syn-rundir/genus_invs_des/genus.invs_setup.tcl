################################################################################
#
# Innovus setup file
# Created by Genus(TM) Synthesis Solution 21.12-s068_1
#   on 06/03/2024 08:05:08
#
################################################################################
#
# Genus(TM) Synthesis Solution setup file
# This file can only be run in Innovus Common UI mode.
#
################################################################################


# Version Check
###########################################################

      namespace eval ::genus_innovus_version_check { 
        set minimum_version 21
        set maximum_version 22
        regexp {\d\d} [get_db program_version] this_version
        puts "Checking Innovus major version against Genus expectations ..."
        if { $this_version < $minimum_version || $this_version > $maximum_version } {
          error "**ERROR: this operation requires Innovus major version to be between '$minimum_version' and '$maximum_version'."
        }
      }
    
set _t0 [clock seconds]
puts [format  {%%%s Begin Genus to Innovus Setup (%s)} \# [clock format $_t0 -format {%m/%d %H:%M:%S}]]
set_db read_physical_allow_multiple_port_pin_without_must_join true
set_db must_join_all_ports true
set_db timing_cap_unit 1pf
set_db timing_time_unit 1ns


# Design Import
################################################################################
source -quiet /home/projects/ee477.2023wtr/cad/cadence/GENUS/GENUS211/tools.lnx86/lib/cdn/rc/edi/innovus_procs_common_ui.tcl
## Reading FlowKit settings file
source genus_invs_des/genus.flowkit_settings.tcl

source genus_invs_des/genus.invs_init.tcl

# Reading metrics file
################################################################################
read_metric -id current genus_invs_des/genus.metrics.json
## Reading Innovus Mode attributes file
pqos_eval {rcp::read_taf genus_invs_des/genus.mode_attributes.taf.gz}

## Reading common preserve file for dont_touch and dont_use preserve settings
source -quiet genus_invs_des/genus.preserve.tcl



# Mode Setup
################################################################################
source genus_invs_des/genus.mode


# MSV Setup
################################################################################

# Reading write_name_mapping file
################################################################################

      if { [is_attribute -obj_type port original_name] &&
           [is_attribute -obj_type pin original_name] &&
           [is_attribute -obj_type pin is_phase_inverted]} {
        source genus_invs_des/genus.wnm_attrs.tcl
      }
    

# Reading NDR file
source genus_invs_des/genus.ndr.tcl

# Reading Instance Attributes file
pqos_eval { rcp::read_taf genus_invs_des/genus.inst_attributes.taf.gz}

# Reading minimum routing layer data file
################################################################################
eval_legacy {gpsPrivate::readMinLayerCstr -file genus_invs_des/genus.min_layer} 

eval_legacy {set edi_pe::pegConsiderMacroLayersUnblocked 1}
eval_legacy {set edi_pe::pegPreRouteWireWidthBasedDensityCalModel 1}

      set _t1 [clock seconds]
      puts [format  {%%%s End Genus to Innovus Setup (%s, real=%s)} \# [clock format $_t1 -format {%m/%d %H:%M:%S}] [clock format [expr {28800 + $_t1 - $_t0}] -format {%H:%M:%S}]]
    
