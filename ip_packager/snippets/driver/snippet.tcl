###################################################################################################
# Copyright (c) 2026, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

proc generate {drv_handle} {
    puts "Generate Driver (OS = [common::get_property NAME [hsi::get_os]])"
    if {[common::get_property NAME [hsi::get_os]] == "device_tree"} {
        generate_dt $drv_handle
    } else {
        generate_sw_driver $drv_handle
    }
}

###################################################################################################
# Vitis Callback
###################################################################################################
proc generate_sw_driver {drv_handle} {

    ::hsi::utils::define_include_file $drv_handle "xparameters.h" \
        <DRIVER_NAME> \
        "NUM_INSTANCES" "DEVICE_ID" <BASEADDR_LIST> <HIGHADDR_LIST> \
        <PARAM_LIST>

    if {<GEN_CONFIG_FILE>} {
        ::hsi::utils::define_config_file $drv_handle "<DRIVER_NAME>_g.c" \
            <DRIVER_NAME> \
            "DEVICE_ID" <BASEADDR_LIST> \
            <PARAM_LIST>
    }

    ::hsi::utils::define_canonical_xpars $drv_handle "xparameters.h" \
        <DRIVER_NAME> \
        "DEVICE_ID" <BASEADDR_LIST> <HIGHADDR_LIST> \
        <PARAM_LIST>

}

###################################################################################################
# DTS (device-tree) Callback
###################################################################################################
proc generate_dt {drv_handle} {

    # ---------------------------------------------------------------------------------------------
    # IP metadata
    # ---------------------------------------------------------------------------------------------
    set ip [get_cells -hier $drv_handle]
    # report_property -all $drv_handle
    # report_property -all $ip
    
    set ip_vlnv [get_property VLNV $ip]
    lassign [split $ip_vlnv ":"] ip_vendor ip_library ip_name ip_version
    
    # ---------------------------------------------------------------------------------------------
    # Create Linux compatible string
    # ---------------------------------------------------------------------------------------------
    set vendor_fmt  [format_compatible_name $ip_vendor]
    set ip_name_fmt [format_compatible_name $ip_name]
    set comp_string "${vendor_fmt},${ip_name_fmt}-${ip_version}"
    puts "DT compatible string = $comp_string"

    if {<GEN_UIO_SUPPORT>} {
        lappend comp_string "generic-uio"
        set inst_name [get_property HW_INSTANCE $drv_handle]
        hsi::utils::add_new_property \
            $drv_handle \
            "linux,uio-name" \
            "string" \
            $inst_name
    }
    
    hsi::utils::add_new_property \
        $drv_handle \
        "compatible" \
        "stringlist" \
        $comp_string

    # ---------------------------------------------------------------------------------------------
    # Export Vivado IP parameters into device tree
    # ---------------------------------------------------------------------------------------------
    set params      {<PARAM_LIST>}
    # set param_types {<PARAM_TYPES_LIST>}
    
    foreach param $params {

        set config_name "CONFIG.$param"
        set val [get_property $config_name $ip]

        # Skip empty parameters
        if {$val == ""} {
            continue
        }

        set dt_name [format_dt_name $param]
        set dt_type [detect_dt_type $val]

        puts "Adding DT property: $dt_name = $val ($dt_type)"

        switch $dt_type {
            boolean {
                if {[string equal -nocase $val "true"]} {
                    hsi::utils::add_new_property \
                        $drv_handle \
                        $dt_name \
                        "boolean" \
                        ""
                }
            }
            int {
                hsi::utils::add_new_property \
                    $drv_handle \
                    $dt_name \
                    "int" \
                    $val
            }
            float {
                hsi::utils::add_new_property \
                    $drv_handle \
                    $dt_name \
                    "string" \
                    $val
            }
            bitstring {
                set clean_val [string trim $val "\""]
                set int_val [expr {"0b$clean_val"}]
                set hex_val [format "0x%X" $int_val]
                hsi::utils::add_new_property \
                    $drv_handle \
                    $dt_name \
                    "int" \
                    $hex_val
            }
            default {
                hsi::utils::add_new_property \
                    $drv_handle \
                    $dt_name \
                    "string" \
                    $val
            }
        }
    }

    # ---------------------------------------------------------------------------------------------
    # Explicitly enable node
    # ---------------------------------------------------------------------------------------------
    hsi::utils::add_new_property \
        $drv_handle \
        "status" \
        "string" \
        "okay"
}

###################################################################################################
# Helper Procedures
###################################################################################################

proc detect_dt_type {val} {
    if {[string equal -nocase $val "true"] ||
        [string equal -nocase $val "false"]} {

        return "boolean"
    }
    if {[string is integer -strict $val]} {
        return "int"
    }
    if {[string is double -strict $val]} {
        return "float"
    }
    if {[regexp {^\"?[01]+\"?$} $val]} {
        return "bitstring"
    }
    return "string"
}

proc format_dt_name {name} {

    # Insert '-' before capitals
    set result [regsub -all {([A-Z])} $name {-\1}]

    # Lowercase
    set result [string tolower $result]

    # Remove leading '-'
    set result [string trimleft $result "-"]

    # Replace '_' by '-'
    set result [regsub -all {_} $result "-"]

    return $result
}

proc format_compatible_name {name} {

    set result [string tolower $name]

    # Replace underscores by '-'
    set result [regsub -all {_} $result "-"]

    # Replace spaces by '-'
    set result [regsub -all {\s+} $result "-"]

    return $result
}

###################################################################################################
# EOF
###################################################################################################