###################################################################################################
# Copyright (c) 2026, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# Constraints for Out-Of-Context Synthesis and Implementation
###################################################################################################

# Set clock to 400MHz for OOC to challange routing in an empty device.
create_clock -period 2.500 -name Axi_Clk  [get_ports Axi_Clk]
create_clock -period 2.500 -name Axis_Clk [get_ports Axis_Clk]
create_clock -period 2.500 -name Clk      [get_ports Clk]

set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports Axi_Clk]
set_property HD.CLK_SRC BUFGCTRL_X0Y1 [get_ports Axis_Clk]
set_property HD.CLK_SRC BUFGCTRL_X0Y2 [get_ports Clk]

# Ignore timing from unconnected input/output ports (because OOC).
set_false_path -to   [get_ports -filter {DIRECTION == OUT}]
set_false_path -from [get_ports -filter {DIRECTION == IN}]

###################################################################################################
# EOF
###################################################################################################
