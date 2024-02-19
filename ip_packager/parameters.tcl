###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager - Parameters
###################################################################################################

namespace eval ::xtools::ip_packager {
    # Export procs that should be allowed to import into other namespaces
    namespace export    create_user_param \
                        set_param_config \
                        set_param_validation \
                        set_param_enablement \
                        set_param_value
}

###################################################################################################
# Parameters Procedures
###################################################################################################

proc ::xtools::ip_packager::create_user_param {args} {
    # Summary: Create new parameter which is not already in the MODELPARAM space (generics).
    
    # Argument Usage:
    # -param_name <arg>:            Parameter name (e.g. User_p)
    # [-format <arg> = string]:     Parameter format (bitString, bool, float, long and string)
    # [-bit_string_length <arg>]:   Mandatory length for bitString parameters
    # [-value <arg>]:               Optional parameter default value. Only use -value and -value_tcl_expr exclusively.
    # [-value_tcl_expr <arg>]:      Optional parameter value expression (e.g. \$User_p * 8). Only use -value and -value_tcl_expr exclusively.
    # [-validation_range <arg>]:    Optional validation range for float and long parameters (e.g. [list <minimum> <maximum>] or [list <minimum> -])
    # [-validation_list <arg>]:     Optional validation list (e.g. [list 1 3 5] or ["100" "010" "001"])
    # [-validation_pairs <arg>]:    Optional validation pairs (e.g. [list key1 1 key2 2 ...])
    # [-enablement_tcl_expr <arg>]: Optional parameter enablement expression (e.g. "\$i > 2)
    
    # Return Value: TCL_OK
    
    # Categories: xilinxtclstore, ip_packager
    
    # Default values
    set value_resolve_type "user"
    set format "string"
    
    # Parse optional arguments
    set configArgs [list]
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -param_name             {incr i; set param_name        [lindex $args $i]}
            -format                 {incr i; set format            [lindex $args $i]}
            -bit_string_length      {incr i; set bit_string_length [lindex $args $i]}
            -value                  {lappend configArgs [lindex $args $i]; incr i; lappend configArgs [lindex $args $i]}
            -value_tcl_expr         {lappend configArgs [lindex $args $i]; incr i; lappend configArgs [lindex $args $i]}
            -validation_range       {lappend configArgs [lindex $args $i]; incr i; lappend configArgs [lindex $args $i]}
            -validation_list        {lappend configArgs [lindex $args $i]; incr i; lappend configArgs [lindex $args $i]}
            -validation_pairs       {lappend configArgs [lindex $args $i]; incr i; lappend configArgs [lindex $args $i]}
            -enablement_tcl_expr    {lappend configArgs [lindex $args $i]; incr i; lappend configArgs [lindex $args $i]}
        }
    }

    # Ensure value_bit_string_length is defined for bitString parameters
    if {$format == "bitString" && ![info exists bit_string_length]} {error "ERROR: \[create_user_param\] Invalid configuration, -format = bitString requires -bit_string_length > 0."}
    
    # Add user parameter to IPI
    set addedParam [ipx::add_user_parameter $param_name [ipx::current_core]]
    
    # Call individual helper funcitons
    if {[info exists value_resolve_type]} {set_property value_resolve_type      $value_resolve_type  $addedParam}
    if {[info exists format            ]} {set_property value_format            $format              $addedParam}
    if {[info exists bit_string_length ]} {set_property value_bit_string_length $bit_string_length   $addedParam}
    
    if {[llength configArgs] != 0} {
        set_param_config -param_name $param_name {*}$configArgs
    }
}

proc ::xtools::ip_packager::set_param_config {args} {
    # Summary: Configure existing MODELPARAM (generic) or added user parameter.
    
    # Argument Usage:
    # -param_name <arg>:            Parameter name (e.g. User_p)
    # [-value <arg>]:               Optional parameter default value. Only use -value and -value_tcl_expr exclusively.
    # [-value_tcl_expr <arg>]:      Optional parameter value expression (e.g. \$User_p * 8). Only use -value and -value_tcl_expr exclusively.
    # [-validation_range <arg>]:    Optional validation range for float and long parameters (e.g. [list <minimum> <maximum>] or [list <minimum> -])
    # [-validation_list <arg>]:     Optional validation list (e.g. [list 1 3 5] or ["100" "010" "001"])
    # [-validation_pairs <arg>]:    Optional validation pairs (e.g. [list key1 1 key2 2 ...])
    # [-enablement_tcl_expr <arg>]: Optional parameter enablement expression (e.g. "\$i > 2)
    
    # Return Value: TCL_OK
    
    # Categories: xilinxtclstore, ip_packager
    
    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -param_name             {incr i; set param_name          [lindex $args $i]}
            -value                  {incr i; set value               [lindex $args $i]}
            -value_tcl_expr         {incr i; set value_tcl_expr      [lindex $args $i]}
            -validation_range       {incr i; set validation_range    [lindex $args $i]}
            -validation_list        {incr i; set validation_list     [lindex $args $i]}
            -validation_pairs       {incr i; set validation_pairs    [lindex $args $i]}
            -enablement_tcl_expr    {incr i; set enablement_tcl_expr [lindex $args $i]}
        }
    }

    # Call individual helper funcitons
    if {[info exists value              ]} {set_param_value      -param_name $param_name -value    $value}
    if {[info exists value_tcl_expr     ]} {set_param_value      -param_name $param_name -tcl_expr $value_tcl_expr}
    if {[info exists validation_range   ]} {set_param_validation -param_name $param_name -value    $validation_range -type "range" }
    if {[info exists validation_list    ]} {set_param_validation -param_name $param_name -value    $validation_list  -type "list"  }
    if {[info exists validation_pairs   ]} {set_param_validation -param_name $param_name -value    $validation_pairs -type "pairs" }
    if {[info exists enablement_tcl_expr]} {set_param_enablement -param_name $param_name -tcl_expr $enablement_tcl_expr}
}

proc ::xtools::ip_packager::set_param_validation {args} {
    # Summary: Set value validation condition for existing MODELPARAM (generic) or added user parameter.
    
    # Argument Usage:
    # -param_name <arg>:    Parameter name (e.g. User_p)
    # -type <arg>:          Validation type (e.g. range, list or pairs)
    # -value <arg>:         Validation value dependend on -type argument
    
    # Return Value: TCL_OK
    
    # Categories: xilinxtclstore, ip_packager
    
    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact [set option [string trim [lindex $args $i]]] {
            -param_name {incr i; set param_name [lindex $args $i]}
            -type       {incr i; set type       [lindex $args $i]}
            -value      {incr i; set value      [lindex $args $i]}
        }
    }

    # Add validation rule to IPI parameter
    set hdlParam    [ipx::get_hdl_parameters  $param_name -of_objects [ipx::current_core]]
    set userParam   [ipx::get_user_parameters $param_name -of_objects [ipx::current_core]]
    set valueFormat [get_property value_format $userParam]
    
    # Set validation type and related values
    foreach param [concat $hdlParam $userParam] {
        switch -glob -- "${type}-${valueFormat}" {
            "*-bool" - "range-bitString" - "range-string" {
                error "ERROR: \[set_param_validation\] Validation ${type} for ${valueFormat} parameters not supported."
            }
            "range-long" - "range-float" {
                set_property value_validation_type "range_${valueFormat}" $param
                if {[string is double -strict [lindex $value 0]]} {
                    set_property value_validation_range_minimum [lindex $value 0] $param
                }
                if {[string is double -strict [lindex $value 1]]} {
                    set_property value_validation_range_maximum [lindex $value 1] $param
                }
            }
            "list-*" {
                set_property value_validation_type "list"  $param
                set_property value_validation_list $value  $param
            }
            "pairs-*" {
                set_property value_validation_type "pairs" $param
                set_property value_validation_pairs $value $param
            }
            default {"ERROR: \[set_param_validation\] does not know validation ${type} for ${valueFormat} parameters."}
        }
    }
}

proc ::xtools::ip_packager::set_param_enablement {args} {
    # Summary: Set parameter enablement expression for existing MODELPARAM (generic) or added user parameter.
    
    # Argument Usage:
    # -param_name <arg>:    Parameter name (e.g. User_p)
    # -tcl_expr <arg>:      Parameter enablement expression (e.g. "\$i > 2)
    
    # Return Value: TCL_OK
    
    # Categories: xilinxtclstore, ip_packager
    
    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -param_name {incr i; set param_name [lindex $args $i]}
            -tcl_expr   {incr i; set tcl_expr   [lindex $args $i]}
        }
    }

    # Add enablement condition to IPI parameter
    set hdlParam  [ipx::get_hdl_parameters  $param_name -of_objects [ipx::current_core]]
    set userParam [ipx::get_user_parameters $param_name -of_objects [ipx::current_core]]
    foreach param [concat $hdlParam $userParam] {
        if {[info exists tcl_expr]} {set_property enablement_tcl_expr "expr ${tcl_expr}" $param; ipx::update_dependency $param}
    }
}

proc ::xtools::ip_packager::set_param_value {args} {
    # Summary: Set parameter value expression for existing MODELPARAM (generic) or added user parameter.
    
    # Argument Usage:
    # -param_name <arg>:    Parameter name (e.g. User_p)
    # [-value <arg>]:       Parameter default value. Only use -value and -tcl_expr exclusively.
    # [-tcl_expr <arg>]:    Parameter value expression (e.g. "\$User_p * 2). Only use -value and -tcl_expr exclusively.
    
    # Return Value: TCL_OK
    
    # Categories: xilinxtclstore, ip_packager
    
    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -param_name {incr i; set param_name [lindex $args $i]}
            -value      {incr i; set value      [lindex $args $i]}
            -tcl_expr   {incr i; set tcl_expr   [lindex $args $i]}
        }
    }

    set hdlParam  [ipx::get_hdl_parameters  $param_name -of_objects [ipx::current_core]]
    set userParam [ipx::get_user_parameters $param_name -of_objects [ipx::current_core]]
    foreach param [concat $hdlParam $userParam] {
        if {[info exists value   ]} {set_property value $value $param}
        if {[info exists tcl_expr]} {set_property enablement_value false $param; set_property value_tcl_expr "expr ${tcl_expr}" $param; ipx::update_dependency $param}
    }
}

###################################################################################################
# EOF
###################################################################################################
