# Loading additional proc with user specified bodies to compute parameter values (user-specific).
source [file join [file dirname [file dirname [info script]]] gui/gui_support.tcl]
source [file join [file dirname [file dirname [info script]]] gui/gui_support2.tcl]

# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/IpPackager_2020_1_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_UserParam [ipgui::add_page $IPINST -name "Page_UserParam" -display_name {User Parameters}]
  set_property tooltip {User Parameters Page} ${Page_UserParam}
  #Adding Group
  set Group_HExample [ipgui::add_group $IPINST -name "Group_HExample" -parent ${Page_UserParam} -display_name {Example (horizontal)} -layout horizontal]
  set_property tooltip {Horizontal Group Example} ${Group_HExample}
  set TestBool_p [ipgui::add_param $IPINST -name "TestBool_p" -parent ${Group_HExample}]
  set_property tooltip {Settings Tooltip} ${TestBool_p}
  set TestLong_p [ipgui::add_param $IPINST -name "TestLong_p" -parent ${Group_HExample}]
  set_property tooltip {Long Tooltip} ${TestLong_p}
  set TestFloat_p [ipgui::add_param $IPINST -name "TestFloat_p" -parent ${Group_HExample} -widget comboBox]
  set_property tooltip {Float Tooltip} ${TestFloat_p}

  #Adding Group
  set Group_VExample [ipgui::add_group $IPINST -name "Group_VExample" -parent ${Page_UserParam} -display_name {Example (vertical)}]
  set_property tooltip {Vertical Group Example} ${Group_VExample}
  set TestBitString_p [ipgui::add_param $IPINST -name "TestBitString_p" -parent ${Group_VExample} -layout horizontal]
  set_property tooltip {BitString Tooltip} ${TestBitString_p}
  set TestString_p [ipgui::add_param $IPINST -name "TestString_p" -parent ${Group_VExample}]
  set_property tooltip {String Tooltip} ${TestString_p}
  set TestText_t [ipgui::add_static_text $IPINST -name "TestText_t" -parent ${Group_VExample} -text {This is a dummy Text!}]
  set_property tooltip {Text Tooltip} ${TestText_t}


  #Adding Page
  set Page_Config [ipgui::add_page $IPINST -name "Page_Config" -display_name {Configuration}]
  set_property tooltip {Configuration Page} ${Page_Config}
  #Adding Group
  set Group_Axi [ipgui::add_group $IPINST -name "Group_Axi" -parent ${Page_Config} -display_name {AXI4} -layout horizontal]
  set_property tooltip {AXI4 Master/Slave Configuration} ${Group_Axi}
  set HasAxi_p [ipgui::add_param $IPINST -name "HasAxi_p" -parent ${Group_Axi}]
  set_property tooltip {Enable AXI4 Interfaces} ${HasAxi_p}
  #Adding Group
  set Group_S_Axi [ipgui::add_group $IPINST -name "Group_S_Axi" -parent ${Group_Axi} -display_name {Slave}]
  set_property tooltip {AXI4 Slave Configuration} ${Group_S_Axi}
  set S_Axi_DataWidth_g [ipgui::add_param $IPINST -name "S_Axi_DataWidth_g" -parent ${Group_S_Axi} -widget comboBox]
  set_property tooltip {Define AXI4 Slave Data Width} ${S_Axi_DataWidth_g}
  set S_Axi_AddrWidth_g [ipgui::add_param $IPINST -name "S_Axi_AddrWidth_g" -parent ${Group_S_Axi} -widget comboBox]
  set_property tooltip {Define AXI4 Slave Address Width} ${S_Axi_AddrWidth_g}

  #Adding Group
  set Group_M_Axi [ipgui::add_group $IPINST -name "Group_M_Axi" -parent ${Group_Axi} -display_name {Master}]
  set_property tooltip {AXI4 Master Configuration} ${Group_M_Axi}
  set M_Axi_DataWidth_g [ipgui::add_param $IPINST -name "M_Axi_DataWidth_g" -parent ${Group_M_Axi} -widget comboBox]
  set_property tooltip {Define AXI4 Master Data Width} ${M_Axi_DataWidth_g}
  set M_Axi_AddrWidth_g [ipgui::add_param $IPINST -name "M_Axi_AddrWidth_g" -parent ${Group_M_Axi} -widget comboBox]
  set_property tooltip {Define AXI4 Master Address Width} ${M_Axi_AddrWidth_g}


  #Adding Group
  set Group_Axis [ipgui::add_group $IPINST -name "Group_Axis" -parent ${Page_Config} -display_name {AXI4-Stream} -layout horizontal]
  set_property tooltip {AXI4-Stream Master/Slave Configuration} ${Group_Axis}
  set HasAxis_p [ipgui::add_param $IPINST -name "HasAxis_p" -parent ${Group_Axis}]
  set_property tooltip {Enable AXI4-Stream Interfaces} ${HasAxis_p}
  #Adding Group
  set Group_S_Axis [ipgui::add_group $IPINST -name "Group_S_Axis" -parent ${Group_Axis} -display_name {Slave}]
  set_property tooltip {AXI4-Stream Slave Configuration} ${Group_S_Axis}
  set S_Axis_TDataWidth_g [ipgui::add_param $IPINST -name "S_Axis_TDataWidth_g" -parent ${Group_S_Axis} -widget comboBox]
  set_property tooltip {Define AXI4-Stream Slave TData Width} ${S_Axis_TDataWidth_g}
  set S_Axis_TUserWidth_g [ipgui::add_param $IPINST -name "S_Axis_TUserWidth_g" -parent ${Group_S_Axis}]
  set_property tooltip {Define AXI4 Slave TUser Width} ${S_Axis_TUserWidth_g}

  #Adding Group
  set Group_M_Axis [ipgui::add_group $IPINST -name "Group_M_Axis" -parent ${Group_Axis} -display_name {Master}]
  set_property tooltip {AXI4-Stream Master Configuration} ${Group_M_Axis}
  set M_Axis_TDataWidth_g [ipgui::add_param $IPINST -name "M_Axis_TDataWidth_g" -parent ${Group_M_Axis} -widget comboBox]
  set_property tooltip {Define AXI4-Stream Master TData Width} ${M_Axis_TDataWidth_g}
  set M_Axis_TUserWidth_g [ipgui::add_param $IPINST -name "M_Axis_TUserWidth_g" -parent ${Group_M_Axis}]
  set_property tooltip {Define AXI4 Master TUser Width} ${M_Axis_TUserWidth_g}


  #Adding Group
  set Group_Uart [ipgui::add_group $IPINST -name "Group_Uart" -parent ${Page_Config} -display_name {UART}]
  set_property tooltip {UART Configuration} ${Group_Uart}
  set HasUartRx_p [ipgui::add_param $IPINST -name "HasUartRx_p" -parent ${Group_Uart}]
  set_property tooltip {Enable Uart_Rx port} ${HasUartRx_p}
  set HasUartTx_p [ipgui::add_param $IPINST -name "HasUartTx_p" -parent ${Group_Uart}]
  set_property tooltip {Enable Uart_Tx port} ${HasUartTx_p}


  #Adding Page
  set Page_BdTclExample [ipgui::add_page $IPINST -name "Page_BdTclExample" -display_name {bd.tcl Example}]
  set_property tooltip {bd.tcl Example Page} ${Page_BdTclExample}
  set Clk_FreqHz_g [ipgui::add_param $IPINST -name "Clk_FreqHz_g" -parent ${Page_BdTclExample}]
  set_property tooltip {Propagated Clk FreqHz parameter} ${Clk_FreqHz_g}
  ipgui::add_static_text $IPINST -name "Clk_FreqHz_t" -parent ${Page_BdTclExample} -text {This parameter gets automatically updated by bd.tcl file.}


}

proc update_PARAM_VALUE.M_Axi_AddrWidth_g { PARAM_VALUE.M_Axi_AddrWidth_g PARAM_VALUE.HasAxi_p } {
	# Procedure called to update M_Axi_AddrWidth_g when any of the dependent parameters in the arguments change
	
	set M_Axi_AddrWidth_g ${PARAM_VALUE.M_Axi_AddrWidth_g}
	set HasAxi_p ${PARAM_VALUE.HasAxi_p}
	set values(HasAxi_p) [get_property value $HasAxi_p]
	if { [gen_USERPARAMETER_M_Axi_AddrWidth_g_ENABLEMENT $values(HasAxi_p)] } {
		set_property enabled true $M_Axi_AddrWidth_g
	} else {
		set_property enabled false $M_Axi_AddrWidth_g
	}
}

proc validate_PARAM_VALUE.M_Axi_AddrWidth_g { PARAM_VALUE.M_Axi_AddrWidth_g } {
	# Procedure called to validate M_Axi_AddrWidth_g
	return true
}

proc update_PARAM_VALUE.M_Axi_DataWidth_g { PARAM_VALUE.M_Axi_DataWidth_g PARAM_VALUE.HasAxi_p } {
	# Procedure called to update M_Axi_DataWidth_g when any of the dependent parameters in the arguments change
	
	set M_Axi_DataWidth_g ${PARAM_VALUE.M_Axi_DataWidth_g}
	set HasAxi_p ${PARAM_VALUE.HasAxi_p}
	set values(HasAxi_p) [get_property value $HasAxi_p]
	if { [gen_USERPARAMETER_M_Axi_DataWidth_g_ENABLEMENT $values(HasAxi_p)] } {
		set_property enabled true $M_Axi_DataWidth_g
	} else {
		set_property enabled false $M_Axi_DataWidth_g
	}
}

proc validate_PARAM_VALUE.M_Axi_DataWidth_g { PARAM_VALUE.M_Axi_DataWidth_g } {
	# Procedure called to validate M_Axi_DataWidth_g
	return true
}

proc update_PARAM_VALUE.M_Axis_TDataWidth_g { PARAM_VALUE.M_Axis_TDataWidth_g PARAM_VALUE.HasAxis_p } {
	# Procedure called to update M_Axis_TDataWidth_g when any of the dependent parameters in the arguments change
	
	set M_Axis_TDataWidth_g ${PARAM_VALUE.M_Axis_TDataWidth_g}
	set HasAxis_p ${PARAM_VALUE.HasAxis_p}
	set values(HasAxis_p) [get_property value $HasAxis_p]
	if { [gen_USERPARAMETER_M_Axis_TDataWidth_g_ENABLEMENT $values(HasAxis_p)] } {
		set_property enabled true $M_Axis_TDataWidth_g
	} else {
		set_property enabled false $M_Axis_TDataWidth_g
	}
}

proc validate_PARAM_VALUE.M_Axis_TDataWidth_g { PARAM_VALUE.M_Axis_TDataWidth_g } {
	# Procedure called to validate M_Axis_TDataWidth_g
	return true
}

proc update_PARAM_VALUE.M_Axis_TUserWidth_g { PARAM_VALUE.M_Axis_TUserWidth_g PARAM_VALUE.HasAxis_p } {
	# Procedure called to update M_Axis_TUserWidth_g when any of the dependent parameters in the arguments change
	
	set M_Axis_TUserWidth_g ${PARAM_VALUE.M_Axis_TUserWidth_g}
	set HasAxis_p ${PARAM_VALUE.HasAxis_p}
	set values(HasAxis_p) [get_property value $HasAxis_p]
	if { [gen_USERPARAMETER_M_Axis_TUserWidth_g_ENABLEMENT $values(HasAxis_p)] } {
		set_property enabled true $M_Axis_TUserWidth_g
	} else {
		set_property enabled false $M_Axis_TUserWidth_g
	}
}

proc validate_PARAM_VALUE.M_Axis_TUserWidth_g { PARAM_VALUE.M_Axis_TUserWidth_g } {
	# Procedure called to validate M_Axis_TUserWidth_g
	return true
}

proc update_PARAM_VALUE.S_Axi_AddrWidth_g { PARAM_VALUE.S_Axi_AddrWidth_g PARAM_VALUE.HasAxi_p } {
	# Procedure called to update S_Axi_AddrWidth_g when any of the dependent parameters in the arguments change
	
	set S_Axi_AddrWidth_g ${PARAM_VALUE.S_Axi_AddrWidth_g}
	set HasAxi_p ${PARAM_VALUE.HasAxi_p}
	set values(HasAxi_p) [get_property value $HasAxi_p]
	if { [gen_USERPARAMETER_S_Axi_AddrWidth_g_ENABLEMENT $values(HasAxi_p)] } {
		set_property enabled true $S_Axi_AddrWidth_g
	} else {
		set_property enabled false $S_Axi_AddrWidth_g
	}
}

proc validate_PARAM_VALUE.S_Axi_AddrWidth_g { PARAM_VALUE.S_Axi_AddrWidth_g } {
	# Procedure called to validate S_Axi_AddrWidth_g
	return true
}

proc update_PARAM_VALUE.S_Axi_DataWidth_g { PARAM_VALUE.S_Axi_DataWidth_g PARAM_VALUE.HasAxi_p } {
	# Procedure called to update S_Axi_DataWidth_g when any of the dependent parameters in the arguments change
	
	set S_Axi_DataWidth_g ${PARAM_VALUE.S_Axi_DataWidth_g}
	set HasAxi_p ${PARAM_VALUE.HasAxi_p}
	set values(HasAxi_p) [get_property value $HasAxi_p]
	if { [gen_USERPARAMETER_S_Axi_DataWidth_g_ENABLEMENT $values(HasAxi_p)] } {
		set_property enabled true $S_Axi_DataWidth_g
	} else {
		set_property enabled false $S_Axi_DataWidth_g
	}
}

proc validate_PARAM_VALUE.S_Axi_DataWidth_g { PARAM_VALUE.S_Axi_DataWidth_g } {
	# Procedure called to validate S_Axi_DataWidth_g
	return true
}

proc update_PARAM_VALUE.S_Axis_TDataWidth_g { PARAM_VALUE.S_Axis_TDataWidth_g PARAM_VALUE.HasAxis_p } {
	# Procedure called to update S_Axis_TDataWidth_g when any of the dependent parameters in the arguments change
	
	set S_Axis_TDataWidth_g ${PARAM_VALUE.S_Axis_TDataWidth_g}
	set HasAxis_p ${PARAM_VALUE.HasAxis_p}
	set values(HasAxis_p) [get_property value $HasAxis_p]
	if { [gen_USERPARAMETER_S_Axis_TDataWidth_g_ENABLEMENT $values(HasAxis_p)] } {
		set_property enabled true $S_Axis_TDataWidth_g
	} else {
		set_property enabled false $S_Axis_TDataWidth_g
	}
}

proc validate_PARAM_VALUE.S_Axis_TDataWidth_g { PARAM_VALUE.S_Axis_TDataWidth_g } {
	# Procedure called to validate S_Axis_TDataWidth_g
	return true
}

proc update_PARAM_VALUE.S_Axis_TUserWidth_g { PARAM_VALUE.S_Axis_TUserWidth_g PARAM_VALUE.HasAxis_p } {
	# Procedure called to update S_Axis_TUserWidth_g when any of the dependent parameters in the arguments change
	
	set S_Axis_TUserWidth_g ${PARAM_VALUE.S_Axis_TUserWidth_g}
	set HasAxis_p ${PARAM_VALUE.HasAxis_p}
	set values(HasAxis_p) [get_property value $HasAxis_p]
	if { [gen_USERPARAMETER_S_Axis_TUserWidth_g_ENABLEMENT $values(HasAxis_p)] } {
		set_property enabled true $S_Axis_TUserWidth_g
	} else {
		set_property enabled false $S_Axis_TUserWidth_g
	}
}

proc validate_PARAM_VALUE.S_Axis_TUserWidth_g { PARAM_VALUE.S_Axis_TUserWidth_g } {
	# Procedure called to validate S_Axis_TUserWidth_g
	return true
}

proc update_PARAM_VALUE.TestFloat_p { PARAM_VALUE.TestFloat_p PARAM_VALUE.TestBool_p } {
	# Procedure called to update TestFloat_p when any of the dependent parameters in the arguments change
	
	set TestFloat_p ${PARAM_VALUE.TestFloat_p}
	set TestBool_p ${PARAM_VALUE.TestBool_p}
	set values(TestBool_p) [get_property value $TestBool_p]
	if { [gen_USERPARAMETER_TestFloat_p_ENABLEMENT $values(TestBool_p)] } {
		set_property enabled true $TestFloat_p
	} else {
		set_property enabled false $TestFloat_p
	}
}

proc validate_PARAM_VALUE.TestFloat_p { PARAM_VALUE.TestFloat_p } {
	# Procedure called to validate TestFloat_p
	return true
}

proc update_PARAM_VALUE.TestLong_p { PARAM_VALUE.TestLong_p PARAM_VALUE.TestBool_p } {
	# Procedure called to update TestLong_p when any of the dependent parameters in the arguments change
	
	set TestLong_p ${PARAM_VALUE.TestLong_p}
	set TestBool_p ${PARAM_VALUE.TestBool_p}
	set values(TestBool_p) [get_property value $TestBool_p]
	if { [gen_USERPARAMETER_TestLong_p_ENABLEMENT $values(TestBool_p)] } {
		set_property enabled true $TestLong_p
	} else {
		set_property enabled false $TestLong_p
	}
}

proc validate_PARAM_VALUE.TestLong_p { PARAM_VALUE.TestLong_p } {
	# Procedure called to validate TestLong_p
	return true
}

proc update_PARAM_VALUE.TestString_p { PARAM_VALUE.TestString_p PARAM_VALUE.TestLong_p } {
	# Procedure called to update TestString_p when any of the dependent parameters in the arguments change
	
	set TestString_p ${PARAM_VALUE.TestString_p}
	set TestLong_p ${PARAM_VALUE.TestLong_p}
	set values(TestLong_p) [get_property value $TestLong_p]
	set_property value [gen_USERPARAMETER_TestString_p_VALUE $values(TestLong_p)] $TestString_p
}

proc validate_PARAM_VALUE.TestString_p { PARAM_VALUE.TestString_p } {
	# Procedure called to validate TestString_p
	return true
}

proc update_PARAM_VALUE.Clk_FreqHz_g { PARAM_VALUE.Clk_FreqHz_g } {
	# Procedure called to update Clk_FreqHz_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Clk_FreqHz_g { PARAM_VALUE.Clk_FreqHz_g } {
	# Procedure called to validate Clk_FreqHz_g
	return true
}

proc update_PARAM_VALUE.HasAxi_p { PARAM_VALUE.HasAxi_p } {
	# Procedure called to update HasAxi_p when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HasAxi_p { PARAM_VALUE.HasAxi_p } {
	# Procedure called to validate HasAxi_p
	return true
}

proc update_PARAM_VALUE.HasAxis_p { PARAM_VALUE.HasAxis_p } {
	# Procedure called to update HasAxis_p when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HasAxis_p { PARAM_VALUE.HasAxis_p } {
	# Procedure called to validate HasAxis_p
	return true
}

proc update_PARAM_VALUE.HasUartRx_p { PARAM_VALUE.HasUartRx_p } {
	# Procedure called to update HasUartRx_p when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HasUartRx_p { PARAM_VALUE.HasUartRx_p } {
	# Procedure called to validate HasUartRx_p
	return true
}

proc update_PARAM_VALUE.HasUartTx_p { PARAM_VALUE.HasUartTx_p } {
	# Procedure called to update HasUartTx_p when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HasUartTx_p { PARAM_VALUE.HasUartTx_p } {
	# Procedure called to validate HasUartTx_p
	return true
}

proc update_PARAM_VALUE.TestBitString_p { PARAM_VALUE.TestBitString_p } {
	# Procedure called to update TestBitString_p when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TestBitString_p { PARAM_VALUE.TestBitString_p } {
	# Procedure called to validate TestBitString_p
	return true
}

proc update_PARAM_VALUE.TestBool_p { PARAM_VALUE.TestBool_p } {
	# Procedure called to update TestBool_p when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TestBool_p { PARAM_VALUE.TestBool_p } {
	# Procedure called to validate TestBool_p
	return true
}


proc update_MODELPARAM_VALUE.Clk_FreqHz_g { MODELPARAM_VALUE.Clk_FreqHz_g PARAM_VALUE.Clk_FreqHz_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Clk_FreqHz_g}] ${MODELPARAM_VALUE.Clk_FreqHz_g}
}

proc update_MODELPARAM_VALUE.M_Axi_DataWidth_g { MODELPARAM_VALUE.M_Axi_DataWidth_g PARAM_VALUE.M_Axi_DataWidth_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_Axi_DataWidth_g}] ${MODELPARAM_VALUE.M_Axi_DataWidth_g}
}

proc update_MODELPARAM_VALUE.M_Axi_AddrWidth_g { MODELPARAM_VALUE.M_Axi_AddrWidth_g PARAM_VALUE.M_Axi_AddrWidth_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_Axi_AddrWidth_g}] ${MODELPARAM_VALUE.M_Axi_AddrWidth_g}
}

proc update_MODELPARAM_VALUE.S_Axi_DataWidth_g { MODELPARAM_VALUE.S_Axi_DataWidth_g PARAM_VALUE.S_Axi_DataWidth_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_Axi_DataWidth_g}] ${MODELPARAM_VALUE.S_Axi_DataWidth_g}
}

proc update_MODELPARAM_VALUE.S_Axi_AddrWidth_g { MODELPARAM_VALUE.S_Axi_AddrWidth_g PARAM_VALUE.S_Axi_AddrWidth_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_Axi_AddrWidth_g}] ${MODELPARAM_VALUE.S_Axi_AddrWidth_g}
}

proc update_MODELPARAM_VALUE.M_Axis_TDataWidth_g { MODELPARAM_VALUE.M_Axis_TDataWidth_g PARAM_VALUE.M_Axis_TDataWidth_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_Axis_TDataWidth_g}] ${MODELPARAM_VALUE.M_Axis_TDataWidth_g}
}

proc update_MODELPARAM_VALUE.M_Axis_TUserWidth_g { MODELPARAM_VALUE.M_Axis_TUserWidth_g PARAM_VALUE.M_Axis_TUserWidth_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_Axis_TUserWidth_g}] ${MODELPARAM_VALUE.M_Axis_TUserWidth_g}
}

proc update_MODELPARAM_VALUE.S_Axis_TDataWidth_g { MODELPARAM_VALUE.S_Axis_TDataWidth_g PARAM_VALUE.S_Axis_TDataWidth_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_Axis_TDataWidth_g}] ${MODELPARAM_VALUE.S_Axis_TDataWidth_g}
}

proc update_MODELPARAM_VALUE.S_Axis_TUserWidth_g { MODELPARAM_VALUE.S_Axis_TUserWidth_g PARAM_VALUE.S_Axis_TUserWidth_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_Axis_TUserWidth_g}] ${MODELPARAM_VALUE.S_Axis_TUserWidth_g}
}


