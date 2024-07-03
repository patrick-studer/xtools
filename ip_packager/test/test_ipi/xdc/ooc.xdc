###################################################################################################
# Copyright (c) 2024 by XTools, Switzerland
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

set_false_path -to   [all_outputs]
set_false_path -from [all_inputs]

###################################################################################################
# EOF
###################################################################################################
