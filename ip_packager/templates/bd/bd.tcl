###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# Init (create_bd_cell)
###################################################################################################
proc init {cellpath otherInfo} {
    puts "DEBUG: Call init()"
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
    #demo cellpath otherInfo
}

###################################################################################################
# User Procedures
###################################################################################################
proc demo {cellpath otherInfo} {
    # Define handles
    set CellHandle      [get_bd_cells $cellpath]
    set PinHandle       [get_bd_pins "${cellpath}/Clk"]

    # Load IP parameters
    set AnyParameter_p  [get_property CONFIG.AnyParameter_p $Cell_Handle]
    set AnyGeneric_g    [get_property CONFIG.AnyGeneric_g $Cell_Handle]

    # Get interface parameters
    set Pin_FreqHz      [get_property CONFIG.FREQ_HZ $PinHandle]
    set Pin_ClkDomain   [get_property CONFIG.CLK_DOMAIN $PinHandle]
}