###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager Configuraton
###################################################################################################

set src_dir     [file normalize [file join [file dirname [info script]] ".."]];     # IPI source directory.
set root_dir    [file normalize [file join $src_dir ".." "test_ipi_externally"]];   # IPI root directory.

###################################################################################################
# Import IP Packager Package (including Xilinx Help infrastructure)
###################################################################################################

# pkg_path must point to the app directory (folder which contains the "xtools" directory).
set pkg_path                            [file normalize [file join $src_dir "../../../.."]];
lappend auto_path                       [file join $pkg_path "xtools"]
::tclapp::support::appinit::load_app    $pkg_path "::xtools::ip_packager" "ip_packager"
::rdi::set_help_config                  -expose_namespace "ip_packager"

###################################################################################################
# Configure IP Packager (optional)
###################################################################################################

# ip_packager::config_package_project     -msg_config_overwrite       false \
                                        -remove_inferred_interfaces true \
                                        -msg_config_overwrite       false \
                                        -synth_reports              false \
                                        -synth_latch_check          false \
                                        -impl_reports               false \
                                        -impl_timing_check          false \
                                        -impl_failed_nets_check     false \
                                        -impl_timing_wns            -0.0 \
                                        -impl_timing_whs            -0.0 \

###################################################################################################
# Create Package Project
###################################################################################################

# Delete build directory (IPI root_dir) to enforce clean packaging
file delete -force                      $root_dir

ip_packager::create_package_project     -prj_name       "packager_prj" \
                                        -root_dir       $root_dir \
                                        -top_file       "${src_dir}/hdl/IpPackager_2020_1_ipi.vhd" \
                                        -copy_to        "hdl" \
                                        -part           "xc7z020iclg400-1L"

###################################################################################################
# Identification
###################################################################################################

ip_packager::set_identification         -vendor         "xtools.ch" \
                                        -name           "IpPackager_2020_1_Externally" \
                                        -library        "IpPackagerTb" \
                                        -version        1.0 \
                                        -display_name   "IP Packager 2020.1 Testbench" \
                                        -description    "This is a dummy IPI for testing the IpPackager." \
                                        -display_vendor "XTools" \
                                        -company_url    "https://www.github.com/patrick-studer" \
                                        -taxonomy       "/XTools/IP_Packager_Testbench"

###################################################################################################
# Compatibility
###################################################################################################

# ip_packager::set_supported_families                     {artix7 Production zynq Beta}
# ip_packager::set_auto_family_support                    "level_1"
ip_packager::set_unsupported_simulators                 {xcelium vcs riviera activehdl}

###################################################################################################
# File Groups
###################################################################################################

# IP Core Design Files ----------------------------------------------------------------------------
ip_packager::add_design_sources         -files          [list \
                                                            "${src_dir}/hdl/IpPackager_2020_1.vhd" \
                                                            "${src_dir}/hdl/IpPackager_2020_1_pkg.vhd" \
                                                        ] \
                                        -copy_to        "hdl" \

ip_packager::add_design_sources         -files          [list \
                                                            "${src_dir}/hdl/IpPackager_2020_1_sub.v" \
                                                        ] \
                                        -copy_to        "hdl" \

ip_packager::add_design_simulation      -files          [list \
                                                            "${src_dir}/tb/IpPackager_2020_1_ipi_tb.vhd" \
                                                        ] \
                                        -copy_to        "tb" \
                                        -file_type      "VHDL 2008" \

ip_packager::add_design_constraints     -files          [list \
                                                            "${src_dir}/xdc/ooc.xdc" \
                                                        ] \
                                        -copy_to        "xdc" \
                                        -used_in        "out_of_context" \

ip_packager::add_design_constraints     -files          [list \
                                                            "${src_dir}/xdc/synth.xdc" \
                                                        ] \
                                        -copy_to        "xdc" \
                                        -used_in        "synthesis" \

ip_packager::add_design_constraints     -files          [list \
                                                            "${src_dir}/xdc/impl.xdc" \
                                                        ] \
                                        -copy_to        "xdc" \
                                        -used_in        "implementation" \

# Example Design Files ----------------------------------------------------------------------------
# ip_packager::add_exdes_script           -Files          [list \
                                                            "${src_dir}/exdes/IpPackager_2020_1_exdes.tcl" \
                                                        ] \
                                        -copy_to        "exdes" \

# ip_packager::add_exdes_sources          -files          [list \
                                                            "${src_dir}/exdes/IpPackager_2020_1_exdes.vhd" \
                                                        ] \
                                        -copy_to        "exdes" \

# Documentation Files -----------------------------------------------------------------------------
ip_packager::add_logo                   -file           "${src_dir}/doc/logo.png" \
                                        -copy_to        "doc" \

ip_packager::add_readme                 -file           "${src_dir}/doc/readme.pdf" \
                                        -copy_to        "doc" \

ip_packager::add_product_guide          -file           "${src_dir}/doc/product_guide.htm" \
                                        -copy_to        "doc" \

ip_packager::add_changelog              -file           "${src_dir}/doc/changelog.txt" \
                                        -copy_to        "doc" \


# Software Driver Files ---------------------------------------------------------------------------
ip_packager::add_software_driver        -driver_dir     "${src_dir}/drivers" \
                                        -copy_to        "drivers" \
                                        -driver_name    "IpPackager_2020_1" \

# Advanced Scripting Files ------------------------------------------------------------------------
ip_packager::add_bd_tcl                 -file           "${src_dir}/bd/bd.tcl" \
                                        -copy_to        "bd" \

ip_packager::add_utility_scripts        -files          [list \
                                                            "${src_dir}/utils/any_util.xit" \
                                                        ] \
                                        -copy_to        "utils" \

ip_packager::add_upgrade_tcl            -files          [list \
                                                            "${src_dir}/utils/ip_upgrade.tcl" \
                                                        ] \
                                        -copy_to        "utils" \
                                        -versions       [list 0.1] \

ip_packager::add_gui_support_tcl        -files          [list \
                                                            "${src_dir}/gui/gui_support.tcl" \
                                                            "${src_dir}/gui/gui_support2.tcl" \
                                                        ] \
                                        -copy_to        "gui" \

###################################################################################################
# Customization Paramenters
###################################################################################################

# User Parameters ---------------------------------------------------------------------------------
ip_packager::create_user_param          -param_name             "TestBool_p" \
                                        -format                 "bool" \
                                        -value                  true \

ip_packager::create_user_param          -param_name             "TestLong_p" \
                                        -format                 "long" \
                                        -value                  1 \
                                        -validation_range       [list 0 10] \
                                        -enablement_tcl_expr    "\$TestBool_p == true" \

ip_packager::create_user_param          -param_name             "TestFloat_p" \
                                        -format                 "float" \
                                        -value                  1.5 \
                                        -validation_list        [list 1.0 1.5 2.0 2.5] \
                                        -enablement_tcl_expr    "\$TestBool_p == false" \

ip_packager::create_user_param          -param_name             "TestBitString_p" \
                                        -format                 "bitString" \
                                        -bit_string_length      5 \
                                        -validation_pairs       [list A {"01010"} B {"10101"}] \
                                        -value                  {"10101"} \

ip_packager::create_user_param          -param_name             "TestString_p" \
                                        -format                 "string" \
                                        -value_tcl_expr         "\[test_gui_support2 \$TestLong_p\]" \
                                        -value                  2 \

ip_packager::create_user_param          -param_name             "HasAxi_p" \
                                        -format                 "bool" \
                                        -value                  true \

ip_packager::create_user_param          -param_name             "HasAxis_p" \
                                        -format                 "bool" \
                                        -value                  true \

ip_packager::create_user_param          -param_name             "HasUartRx_p" \
                                        -format                 "bool" \
                                        -value                  false \

ip_packager::create_user_param          -param_name             "HasUartTx_p" \
                                        -format                 "bool" \
                                        -value                  true \

# HDL Parameters ----------------------------------------------------------------------------------
ip_packager::set_param_config           -param_name             "Clk_FreqHz_g" \
                                        -validation_range       [list 10000000 -] \
                                        -value                  50000000 \

ip_packager::set_param_config           -param_name             "M_Axi_DataWidth_g" \
                                        -validation_list        [list 8 16 32 64] \
                                        -value                  64 \
                                        -enablement_tcl_expr    "\$HasAxi_p == true" \

ip_packager::set_param_config           -param_name             "M_Axi_AddrWidth_g" \
                                        -validation_range       [list 12 64] \
                                        -value                  16 \
                                        -enablement_tcl_expr    "\$HasAxi_p == true" \

ip_packager::set_param_config           -param_name             "S_Axi_DataWidth_g" \
                                        -validation_list        [list 8 16 32 64] \
                                        -value                  64 \
                                        -enablement_tcl_expr    "\$HasAxi_p == true" \

ip_packager::set_param_config           -param_name             "S_Axi_AddrWidth_g" \
                                        -validation_range       [list 12 64] \
                                        -value                  16 \
                                        -enablement_tcl_expr    "\$HasAxi_p == true" \

ip_packager::set_param_config           -param_name             "M_Axis_TDataWidth_g" \
                                        -validation_list        [list 8 16 32 64] \
                                        -value                  32 \
                                        -enablement_tcl_expr    "\$HasAxis_p == true" \

ip_packager::set_param_config           -param_name             "M_Axis_TUserWidth_g" \
                                        -value                  12 \
                                        -enablement_tcl_expr    "\$HasAxis_p == true" \

ip_packager::set_param_config           -param_name             "S_Axis_TDataWidth_g" \
                                        -validation_list        [list 8 16 32 64] \
                                        -value                  32 \
                                        -enablement_tcl_expr    "\$HasAxis_p == true" \

ip_packager::set_param_config           -param_name             "S_Axis_TUserWidth_g" \
                                        -value                  12 \
                                        -enablement_tcl_expr    "\$HasAxis_p == true" \

# Note the different value formatting possibilities for bitStrings (binary)! The "..." need to be present in the passed value.
ip_packager::set_param_config           -param_name             "TestSL_g" \
                                        -format                 "bitString" \
                                        -bit_string_length      1 \
                                        -validation_list        [list {"0"} "\"1\""] \
                                        -value                  {"0"} \

# Note the different value formatting possibilities for bitStrings (hex)! The 0x prefix needs to be present in the passed value.
ip_packager::set_param_config           -param_name             "TestSLV_g" \
                                        -format                 "bitString" \
                                        -bit_string_length      2 \
                                        -validation_list        [list {0x0} "0x1" 0x2] \
                                        -value                  0x0 \


###################################################################################################
# Ports and Interfaces
###################################################################################################

# Create/Import User Interfaces -------------------------------------------------------------------
# ip_packager::import_bus_definition      -files                  [list \
                                                                    "<your_bus_definition>.xml" \
                                                                    "<your_bus_definition>_rtl.xml" \
                                                                ] \
                                        -copy_to                "interfaces" \

# Auto-Infer Interfaces ---------------------------------------------------------------------------
ip_packager::auto_infer_interface       -interface_name         "S_Axi" \
                                        -vlnv                   "aximm_rtl" \

ip_packager::auto_infer_interface       -interface_name         "S_Axis" \
                                        -vlnv                   "axis_rtl" \

ip_packager::add_axi_interface          -interface_name         "M_Axi" \

ip_packager::add_axis_interface         -interface_name         "M_Axis" \

ip_packager::add_interrupt_interface    -interface_name         "Interrupt" \
                                        -sensitivity            "LEVEL_HIGH" \

ip_packager::add_reset_interface        -interface_name         "Rst" \
                                        -polarity               "ACTIVE_HIGH" \

ip_packager::add_reset_interface        -interface_name         "Axis_ResetN" \
                                        -polarity               "ACTIVE_LOW" \

ip_packager::add_reset_interface        -interface_name         "Axi_ResetN" \
                                        -polarity               "ACTIVE_LOW" \

ip_packager::add_clock_interface        -interface_name         "Clk" \

ip_packager::add_clock_interface        -interface_name         "Axi_Clk" \

ip_packager::add_clock_interface        -interface_name         "Axis_Clk" \

# Manually-Mapped Interfaces ----------------------------------------------------------------------
ip_packager::add_bus_interface          -interface_name         "UART" \
                                        -vlnv                   "uart_rtl" \
                                        -interface_mode         "Master" \
                                        -port_map               [list \
                                                                    [list "Uart_Tx" "TxD"] \
                                                                    [list "Uart_Rx" "RxD"] \
                                                                ] \

# Associate Clock/Reset ---------------------------------------------------------------------------
ip_packager::associate_interface_clock  -interface_name         "*_Axis" \
                                        -clock                  "Axis_Clk" \

ip_packager::associate_interface_clock  -interface_name         "*_Axi" \
                                        -clock                  "Axi_Clk" \

ip_packager::associate_interface_clock  -interface_name         [list \
                                                                    "Interrupt" \
                                                                    "UART" \
                                                                ] \
                                        -clock                  "Clk" \

ip_packager::associate_clock_reset      -clock                  "Axis_Clk" \
                                        -reset                  "Axis_ResetN" \

ip_packager::associate_clock_reset      -clock                  "Axi_Clk" \
                                        -reset                  "Axi_ResetN" \

ip_packager::associate_clock_reset      -clock                  "Clk" \
                                        -reset                  "Rst" \

# Enablement Control ------------------------------------------------------------------------------
ip_packager::set_interface_enablement   -interface_name         "*_Axi" \
                                        -dependency             "\$HasAxi_p == true" \

ip_packager::set_interface_enablement   -interface_name         "*_Axis" \
                                        -dependency             "\$HasAxis_p == true" \

ip_packager::set_port_enablement        -port_name              "Uart_Rx" \
                                        -dependency             "\$HasUartRx_p == true" \
                                        -driver_value           1 \

ip_packager::set_port_enablement        -port_name              "Uart_Tx" \
                                        -dependency             "\$HasUartTx_p == true" \

ip_packager::set_interface_enablement   -interface_name         "UART" \
                                        -dependency             "\$HasUartRx_p == true || \$HasUartTx_p == true" \

###################################################################################################
# Adressing and Memory
###################################################################################################

# Not implemented yet

###################################################################################################
# Customization GUI
###################################################################################################

# ROOT --------------------------------------------------------------------------------------------
ip_packager::gui_set_parent     "root"

ip_packager::gui_add_page       -page_name      "Page_UserParam" \
                                -display_name   "User Parameters" \
                                -tooltip        "User Parameters Page" \
                                -layout         "vertical" \

    # PAGE User Parameters ------------------------------------------------------------------------
    ip_packager::gui_add_group      -group_name     "Group_HExample" \
                                    -display_name   "Example (horizontal)" \
                                    -tooltip        "Horizontal Group Example" \
                                    -layout         "horizontal" \

        # GROUP Horizontal Example ----------------------------------------------------------------
        ip_packager::gui_add_param      -param_name     "TestBool_p" \
                                        -display_name   "Random Boolean" \
                                        -tooltip        "Settings Tooltip" \

        ip_packager::gui_add_param      -param_name     "TestLong_p" \
                                        -display_name   "Random Long" \
                                        -tooltip        "Long Tooltip" \

        ip_packager::gui_add_param      -param_name     "TestFloat_p" \
                                        -display_name   "Random Float" \
                                        -tooltip        "Float Tooltip" \
                                        -widget         "comboBox" \

    # PAGE User Parameters ------------------------------------------------------------------------
    ip_packager::gui_set_parent     "Page_UserParam"

    ip_packager::gui_add_group      -group_name     "Group_VExample" \
                                    -display_name   "Example (vertical)" \
                                    -tooltip        "Vertical Group Example" \
                                    -layout         "vertical" \

        # GROUP Vertical Example ------------------------------------------------------------------
        ip_packager::gui_add_param      -param_name     "TestBitString_p" \
                                        -display_name   "Random BitString" \
                                        -tooltip        "BitString Tooltip" \
                                        -widget         "radioGroup" \
                                        -layout         "horizontal" \

        ip_packager::gui_add_param      -param_name     "TestString_p" \
                                        -display_name   "Random String" \
                                        -tooltip        "String Tooltip" \

        ip_packager::gui_add_text       -text_name      "TestText_t" \
                                        -text           "This is a dummy Text!" \
                                        -tooltip        "Text Tooltip" \

# ROOT --------------------------------------------------------------------------------------------
ip_packager::gui_set_parent     "root"

ip_packager::gui_add_page       -page_name      "Page_Config" \
                                -display_name   "Configuration" \
                                -tooltip        "Configuration Page" \
                                -layout         "vertical" \

    # PAGE Configuration --------------------------------------------------------------------------
    ip_packager::gui_add_group      -group_name     "Group_Test" \
                                    -display_name   "Test SL/SLV" \
                                    -tooltip        "Test std_logic and std_logic_vector" \
                                    -layout         "horizontal" \

        # GROUP AXI4 ------------------------------------------------------------------------------
        ip_packager::gui_add_param      -param_name     "TestSL_g" \
                                        -display_name   "Test std_logic generic" \
                                        -widget         "comboBox" \

        ip_packager::gui_add_param      -param_name     "TestSLV_g" \
                                        -display_name   "Test std_logic_vector generic" \
                                        -widget         "comboBox" \

    # PAGE Configuration --------------------------------------------------------------------------
    ip_packager::gui_set_parent     "Page_Config"

    # PAGE Configuration --------------------------------------------------------------------------
    ip_packager::gui_add_group      -group_name     "Group_Axi" \
                                    -display_name   "AXI4" \
                                    -tooltip        "AXI4 Master/Slave Configuration" \
                                    -layout         "horizontal" \

        # GROUP AXI4 ------------------------------------------------------------------------------
        ip_packager::gui_add_param      -param_name     "HasAxi_p" \
                                        -display_name   "Has AXI4 Slave/Master" \
                                        -tooltip        "Enable AXI4 Interfaces" \

        ip_packager::gui_add_group      -group_name     "Group_S_Axi" \
                                        -display_name   "Slave" \
                                        -tooltip        "AXI4 Slave Configuration" \
                                        -layout         "vertical" \

            # GROUP AXI4 Slave --------------------------------------------------------------------
            ip_packager::gui_add_param      -param_name     "S_Axi_DataWidth_g" \
                                            -display_name   "AXI4 Slave Data Width (bits)" \
                                            -tooltip        "Define AXI4 Slave Data Width" \
                                            -widget         "comboBox" \

            ip_packager::gui_add_param      -param_name     "S_Axi_AddrWidth_g" \
                                            -display_name   "AXI4 Slave Address Width (bits)" \
                                            -tooltip        "Define AXI4 Slave Address Width" \
                                            -widget         "comboBox" \

        # GROUP AXI4 ------------------------------------------------------------------------------
        ip_packager::gui_set_parent     "Group_Axi"

        ip_packager::gui_add_group      -group_name     "Group_M_Axi" \
                                        -display_name   "Master" \
                                        -tooltip        "AXI4 Master Configuration" \
                                        -layout         "vertical" \

            # GROUP AXI4 Master -------------------------------------------------------------------
            ip_packager::gui_add_param      -param_name     "M_Axi_DataWidth_g" \
                                            -display_name   "AXI4 Master Data Width (bits)" \
                                            -tooltip        "Define AXI4 Master Data Width" \
                                            -widget         "comboBox" \

            ip_packager::gui_add_param      -param_name     "M_Axi_AddrWidth_g" \
                                            -display_name   "AXI4 Master Address Width (bits)" \
                                            -tooltip        "Define AXI4 Master Address Width" \
                                            -widget         "comboBox" \

    # PAGE Configuration --------------------------------------------------------------------------
    ip_packager::gui_set_parent     "Page_Config"

    ip_packager::gui_add_group      -group_name     "Group_Axis" \
                                    -display_name   "AXI4-Stream" \
                                    -tooltip        "AXI4-Stream Master/Slave Configuration" \
                                    -layout         "horizontal" \

        # GROUP AXI4-Stream -----------------------------------------------------------------------
        ip_packager::gui_add_param      -param_name     "HasAxis_p" \
                                        -display_name   "Has AXI4-Stream Slave/Master" \
                                        -tooltip        "Enable AXI4-Stream Interfaces" \

        ip_packager::gui_add_group      -group_name     "Group_S_Axis" \
                                        -display_name   "Slave" \
                                        -tooltip        "AXI4-Stream Slave Configuration" \
                                        -layout         "vertical" \

            # GROUP AXI4-Stream Slave -------------------------------------------------------------
            ip_packager::gui_add_param      -param_name     "S_Axis_TDataWidth_g" \
                                            -display_name   "AXI4-Stream Slave TData Width (bits)" \
                                            -tooltip        "Define AXI4-Stream Slave TData Width" \
                                            -widget         "comboBox" \

            ip_packager::gui_add_param      -param_name     "S_Axis_TUserWidth_g" \
                                            -display_name   "AXI4-Stream Slave TUser Width (bits)" \
                                            -tooltip        "Define AXI4 Slave TUser Width" \
                                            -widget         "textEdit" \

        # GROUP AXI4 ------------------------------------------------------------------------------
        ip_packager::gui_set_parent     "Group_Axis"

        ip_packager::gui_add_group      -group_name     "Group_M_Axis" \
                                        -display_name   "Master" \
                                        -tooltip        "AXI4-Stream Master Configuration" \
                                        -layout         "vertical" \

            # GROUP AXI4-Stream Master ------------------------------------------------------------
            ip_packager::gui_add_param      -param_name     "M_Axis_TDataWidth_g" \
                                            -display_name   "AXI4-Stream Master TData Width (bits)" \
                                            -tooltip        "Define AXI4-Stream Master TData Width" \
                                            -widget         "comboBox" \

            ip_packager::gui_add_param      -param_name     "M_Axis_TUserWidth_g" \
                                            -display_name   "AXI4-Stream Master TUser Width (bits)" \
                                            -tooltip        "Define AXI4 Master TUser Width" \
                                            -widget         "textEdit" \

    # PAGE Configuration --------------------------------------------------------------------------
    ip_packager::gui_set_parent     "Page_Config"

    ip_packager::gui_add_group      -group_name     "Group_Uart" \
                                    -display_name   "UART" \
                                    -tooltip        "UART Configuration" \
                                    -layout         "vertical" \

        # GROUP AXI4 ------------------------------------------------------------------------------
        ip_packager::gui_add_param      -param_name     "HasUartRx_p" \
                                        -display_name   "Has UART Rx" \
                                        -tooltip        "Enable Uart_Rx port" \

        ip_packager::gui_add_param      -param_name     "HasUartTx_p" \
                                        -display_name   "Has UART Tx" \
                                        -tooltip        "Enable Uart_Tx port" \

# ROOT --------------------------------------------------------------------------------------------
ip_packager::gui_set_parent     "root"

ip_packager::gui_add_page       -page_name      "Page_BdTclExample" \
                                -display_name   "bd.tcl Example" \
                                -tooltip        "bd.tcl Example Page" \
                                -layout         "vertical" \

    # PAGE bd.tcl Example -------------------------------------------------------------------------
    ip_packager::gui_add_param      -param_name     "Clk_FreqHz_g" \
                                    -display_name   "Clk Frequency \[Hz\]" \
                                    -tooltip        "Propagated Clk FreqHz parameter" \
                                    -widget         "textEdit" \

    ip_packager::gui_add_text       -text_name      "Clk_FreqHz_t" \
                                    -text           "This parameter gets automatically updated by bd.tcl file." \

# -------------------------------------------------------------------------------------------------

###################################################################################################
# Review and Package
###################################################################################################

ip_packager::simulate_package_project   -generics       [list \
                                                            "Clk_FreqHz_g=100000000" \
                                                            "M_Axi_DataWidth_g=16" \
                                                            "M_Axi_AddrWidth_g=16" \
                                                            "S_Axi_DataWidth_g=16" \
                                                            "S_Axi_AddrWidth_g=16" \
                                                            "M_Axis_TDataWidth_g=16" \
                                                            "M_Axis_TUserWidth_g=16" \
                                                            "S_Axis_TDataWidth_g=16" \
                                                            "S_Axis_TUserWidth_g=16" \
                                                            "TestSL_Int_g=1" \
                                                            "TestSLV_Int_g=3" \
                                                        ] \

ip_packager::synth_package_project

# ip_packager::synth_package_project      -generics       [list \
                                                            "Clk_FreqHz_g=100000000" \
                                                            "M_Axi_DataWidth_g=16" \
                                                            "M_Axi_AddrWidth_g=16" \
                                                            "S_Axi_DataWidth_g=16" \
                                                            "S_Axi_AddrWidth_g=16" \
                                                            "M_Axis_TDataWidth_g=16" \
                                                            "M_Axis_TUserWidth_g=16" \
                                                            "S_Axis_TDataWidth_g=16" \
                                                            "S_Axis_TUserWidth_g=16" \
                                                            "TestSL_g=1'b1" \
                                                            "TestSLV_g=2'b11" \
                                                        ] \

# ip_packager::synth_package_project      -part           "xczu11eg-ffvb1517-2-e" \

# ip_packager::synth_package_project      -part           "xc7z030ifbg484-2L" \

ip_packager::impl_package_project

# ip_packager::impl_package_project       -part           "xczu11eg-ffvb1517-2-e" \

# ip_packager::impl_package_project       -part           "xc7z030ifbg484-2L" \

ip_packager::save_package_project

ip_packager::close_package_project      -delete         "false"

###################################################################################################
# EOF
###################################################################################################
