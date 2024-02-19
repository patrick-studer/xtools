###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

set currentNamespace [namespace current]
puts "DEBUG: bd.tcl sourced now into namespace ${currentNamespace}" 

###################################################################################################
# Init (create_bd_cell)
###################################################################################################
proc init {cellpath otherInfo } {
    puts "DEBUG: Call init()"
    
    set paramList "Clk_FreqHz_g"
    set cell_handle [get_bd_cells $cellpath]
    bd::mark_propagate_overrideable $cell_handle $paramList
    set clk_pin_handle [get_bd_pins $cellpath/Clk]
    set_property CONFIG.FREQ_HZ 50000000 $clk_pin_handle
}

###################################################################################################
# Post-Configuration (set_property CONFIG.<>)
###################################################################################################
proc post_config_ip {cellpath otherInfo} {
    puts "DEBUG: Call post_config_ip()"
}

###################################################################################################
# Propagate (validate_bd_design)
###################################################################################################
proc propagate {cellpath otherInfo} {
    puts "DEBUG: Call propagate()"
}

###################################################################################################
# Post-Propagate (validate_bd_design)
###################################################################################################
proc post_propagate {cellpath otherInfo} {
    puts "DEBUG: Call post_propagate()"
    
    set cell_handle [get_bd_cells $cellpath]
    ##set intf_handle [get_bd_intf_pins $cellpath/aclk]
   
    ## Assign AXI clock frequency to parameter 
    set clk_pin_handle [get_bd_pins $cellpath/Clk]
    set freq [get_property CONFIG.FREQ_HZ $clk_pin_handle]
    if { $freq == "" } {
      set_property MSG.ERROR "Clk CLOCK Frequency is not propagated from Clock Interface" $cell_handle
    } else {
      set freq_Hz [expr int($freq)] 
      set_property CONFIG.Clk_FreqHz_g $freq_Hz $cell_handle
    }
}