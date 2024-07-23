###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager - Interfaces
###################################################################################################

namespace eval ::xtools::ip_packager {
    # Export procs that should be allowed to import into other namespaces
    namespace export    import_bus_definition \
                        auto_infer_interface \
                        add_axi_interface \
                        add_axis_interface \
                        add_clock_interface \
                        add_clockenable_interface \
                        add_data_interface \
                        add_reset_interface \
                        add_interrupt_interface \
                        add_bus_interface \
                        associate_interface_clock \
                        associate_clock_reset \
                        set_interface_enablement \
                        set_port_enablement
}

###################################################################################################
# Helper Procedures
###################################################################################################

proc ::xtools::ip_packager::_get_ports {port_name {filter_expr ""}} {
    # Summary: Guarded get_ports function. Checks if the port exists before returning.

    # Argument Usage:
    # port_name:        Port name/pattern.
    # [filter_expr]:    Additional filter condition.

    # Return Value:     TCL_ERROR if port was not found, else TCL_OK.

    # Categories: xilinxtclstore, ip_packager
    if {![string match $filter_expr ""]} {set filter_expr "&& (${filter_expr})"}
    set foundPorts [ipx::get_ports -of_objects [ipx::current_core] -filter "name =~ ${port_name} ${filter_expr}"]
    if {[llength $foundPorts] == 0} {
            error "ERROR: \[_get_ports\] No ports matched pattern ${port_name}. Please verify spelling of this port."
    }
    return $foundPorts
}

proc ::xtools::ip_packager::_get_bus_interfaces {interface_name {filter_expr ""}} {
    # Summary: Guarded get_bus_interface function. Checks if the interface exists before returning.

    # Argument Usage:
    # interface_name:   Interface name/pattern.
    # [filter_expr]:    Additional filter condition.

    # Return Value:     TCL_ERROR if interface was not found, else TCL_OK.

    # Categories: xilinxtclstore, ip_packager
    if {![string match $filter_expr ""]} {set filter_expr "&& (${filter_expr})"}
    set foundInterfaces [ipx::get_bus_interfaces -of_objects [ipx::current_core] -filter "name =~ ${interface_name} ${filter_expr}"]
    if {[llength $foundInterfaces] == 0} {
            error "ERROR: \[_get_bus_interfaces\] No interface matched pattern ${interface_name}. Please verify spelling or add the interface first if not done yet."
    }
    return $foundInterfaces
}

###################################################################################################
# Ports + Interfaces Procedures
###################################################################################################

# Create/Import User Interfaces -------------------------------------------------------------------

# proc ::xtools::ip_packager::create_bus_definition {bus} {
    # TODO: add this very cool routine :D
# }

proc ::xtools::ip_packager::import_bus_definition {args} {
    # Summary: Import/Copy existing interface/bus definition and abstraction XML into packaged IP-core.

    # Argument Usage:
    # -files <arg>:            List of interface definitions/abstractions XML to be added to the packager project.
    # [-copy_to <arg>]:        Path to folder, where to copy/import the added interface definitions/abstractions XML.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -files          {incr i; set files          [lindex $args $i]}
            -copy_to        {incr i; set copy_to        [lindex $args $i]}
        }
    }

    # Copy files if needed
    if {[info exists copy_to]} {
        file mkdir [set copyToDir [file normalize [path_relative_to_pwd $copy_to]]]
        file copy -force {*}[path_relative_to_pwd $files] $copyToDir
        set copiedFiles [list]
        foreach file $files {
            lappend copiedFiles [file join $copyToDir [file tail $file]]
        }
        set files $copiedFiles
    }

    # Find new IP-Repos to be added to IP-Catalog (no dublicates)
    set ipRepos [get_property ip_repo_paths [current_project]]
    foreach file $files {
        if {[string match "../*" [path_relative_to_root $file]]} {
            set dir [file dirname [file normalize [path_relative_to_pwd $file]]]
            if {$dir ni $ipRepos} {lappend ipRepos $dir}
        }
    }

    # Filter out directories contained inside an other directory-path to keep top-most folders only
    set ipRepos [lsort -dictionary $ipRepos]
    set compareIndex 0
    set ipReposFiltered [lindex $ipRepos 0]
    for {set i 1} {$i < [llength $ipRepos]} {incr i} {
        if {![string match "[lindex $ipRepos $compareIndex]/*" [lindex $ipRepos $i]]} {
            lappend ipReposFiltered [lindex $ipRepos $i]
            set compareIndex $i
        }
    }

    # Update Vivado project IP-Repository with new paths
    set_property ip_repo_paths $ipReposFiltered [current_project]
    update_ip_catalog -rebuild
}


# Auto-Infer Interfaces ---------------------------------------------------------------------------

proc ::xtools::ip_packager::auto_infer_interface {args} {
    # Summary: Auto-infer bus interface for all ports with a given pattern.

    # Argument Usage:
    # -interface_name <arg>:    Define the interface name.
    # -vlnv <arg>:              Name or fully qualified VLNV identifier of bus interface (e.g. "aximm_rtl" or "xilinx.com:interface:aximm_rtl:1.0").
    # [-port_pattern <arg>]:    Optionally overwrite default wildcard pattern of infered ports (default = <interface_name>_*).
    # [-bus_params <arg>]:      Optionally add list of bus parameters and values (e.g. [list [list PARAM_1 1] [list PARAM_2 2]]).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name {incr i; set interface_name [lindex $args $i]}
            -vlnv           {incr i; set vlnv           [lindex $args $i]}
            -port_pattern   {incr i; set port_pattern   [lindex $args $i]}
            -bus_params     {incr i; set bus_params     [lindex $args $i]}
        }
    }

    # Find unique bus interface abstraction from Name or VLNV
    set ifBusAbs [_find_unique_bus_abstraction $vlnv]

    # Find interface ports
    if {![info exists port_pattern]} {
        set port_pattern "${interface_name}_*"
    }
    set ifPorts [_get_ports $port_pattern]

    # Auto-infer bus interface
    set addedInterface [ipx::infer_bus_interface [get_property name $ifPorts] [get_property vlnv $ifBusAbs] [ipx::current_core]]

    # Remove all auto-inferred parameters
    set autoInfParameters [ipx::get_bus_parameters -of_objects $addedInterface]
    foreach autoInfParameter $autoInfParameters {
        ipx::remove_bus_parameter [get_property name $autoInfParameter] $addedInterface
    }

    # Overwrite default interface name
    set_property name $interface_name $addedInterface

    # Add optional bus parameters
    if {[info exists bus_params]} {
        foreach busParam $bus_params {
            set_property value [lindex $busParam 1] [ipx::add_bus_parameter [lindex $busParam 0] $addedInterface]
        }
    }

    # Create default memory-map (AXI4 Slaves) or address-space (AXI4-Masters)
    if {[string match [get_property vlnv $ifBusAbs] "xilinx.com:interface:aximm_rtl:1.0"]} {
        set interfaceMode [get_property interface_mode $addedInterface]
        if {[string match $interfaceMode "slave"]} {
            ipx::infer_memory_address_block $addedInterface
            # Workaround to force base_address to format long (introduced in newer Vivado versions around 2021.x)
            set addressBlock [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps $interface_name -of_objects [ipx::current_core]]]
            set_property base_address              0      $addressBlock
            set_property base_address_format       "long" $addressBlock
            set_property base_address_resolve_type "user" $addressBlock
        } elseif {[string match $interfaceMode "master"]} {
            ipx::infer_address_space $addedInterface
        }
    }

}

proc ::xtools::ip_packager::add_axi_interface {args} {
    # Summary: Auto-infer AXI4 interface for all ports with a given pattern.

    # Argument Usage:
    # -interface_name <arg>:    Define the interface name (e.g. M_Axi).
    # [-port_pattern <arg>]:    Optionally overwrite default wildcard pattern of infered ports (default = <interface_name>_*).
    # [-bus_params <arg>]:      Optionally add list of bus parameters and values (e.g. [list [list PARAM_1 1] [list PARAM_2 2]]).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set bus_params [list]
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name {incr i; set interface_name [lindex $args $i]}
            -port_pattern   {incr i; set port_pattern   [lindex $args $i]}
            -bus_params     {incr i; set bus_params     [lindex $args $i]}
        }
    }

    # Find interface ports
    if {![info exists port_pattern]} {
        set port_pattern "${interface_name}_*"
    }

    # Auto-infer bus interface
    auto_infer_interface -interface_name $interface_name -vlnv "xilinx.com:interface:aximm_rtl:1.0" -port_pattern $port_pattern -bus_params $bus_params
}

proc ::xtools::ip_packager::add_axis_interface {args} {
    # Summary: Auto-infer AXI4-Stream interface for all ports with a given pattern.

    # Argument Usage:
    # -interface_name <arg>:    Define the interface name (e.g. M_Axis).
    # [-port_pattern <arg>]:    Optionally overwrite default wildcard pattern of infered ports (default = <interface_name>_*).
    # [-bus_params <arg>]:      Optionally add list of bus parameters and values (e.g. [list [list PARAM_1 1] [list PARAM_2 2]]).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set bus_params [list]
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name {incr i; set interface_name [lindex $args $i]}
            -port_pattern   {incr i; set port_pattern   [lindex $args $i]}
            -bus_params     {incr i; set bus_params     [lindex $args $i]}
        }
    }

    # Find interface ports
    if {![info exists port_pattern]} {
        set port_pattern "${interface_name}_*"
    }

    # Auto-infer bus interface
    auto_infer_interface -interface_name $interface_name -vlnv "xilinx.com:interface:axis_rtl:1.0"  -port_pattern $port_pattern -bus_params $bus_params
}

proc ::xtools::ip_packager::add_clock_interface {args} {
    # Summary: Auto-infer Clock interface for single-bit port with same name.

    # Argument Usage:
    # -interface_name <arg>:    Define the interface name (e.g. User_Clk).
    # [-freq_hz <arg>]:         Optionally add FREQ_HZ value to bus_param list (only define if the clock interface requires a specific frequency).
    # [-bus_params <arg>]:      Optionally add list of bus parameters and values (e.g. [list [list PARAM_1 1] [list PARAM_2 2]]).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set bus_params [list]
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name {incr i; set interface_name [lindex $args $i]}
            -freq_hz        {incr i; set freq_hz        [lindex $args $i]}
            -bus_params     {incr i; set bus_params     [lindex $args $i]}
        }
    }

    # Auto-infer bus interface
    if {[info exists freq_hz]} {lappend bus_params [list FREQ_HZ $freq_hz]}
    auto_infer_interface -interface_name $interface_name -vlnv "xilinx.com:signal:clock_rtl:1.0" -port_pattern $interface_name -bus_params $bus_params
}

proc ::xtools::ip_packager::add_clockenable_interface {args} {
    # Summary: Auto-infer Clock-Enable interface for single-bit port with same name.

    # Argument Usage:
    # -interface_name <arg>:    Define the interface name (e.g. User_ClkEna).
    # [-bus_params <arg>]:      Optionally add list of bus parameters and values (e.g. [list [list PARAM_1 1] [list PARAM_2 2]]).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set bus_params [list]
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name {incr i; set interface_name [lindex $args $i]}
            -bus_params     {incr i; set bus_params     [lindex $args $i]}
        }
    }

    # Auto-infer bus interface
    auto_infer_interface -interface_name $interface_name -vlnv "xilinx.com:signal:clockenable_rtl:1.0" -port_pattern $interface_name -bus_params $bus_params
}

proc ::xtools::ip_packager::add_data_interface {args} {
    # Summary: Auto-infer Data interface for single port with same name.

    # Argument Usage:
    # -interface_name <arg>:    Define the interface name (e.g. User_Data).
    # [-bus_params <arg>]:      Optionally add list of bus parameters and values (e.g. [list [list PARAM_1 1] [list PARAM_2 2]]).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set bus_params [list]
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name {incr i; set interface_name [lindex $args $i]}
            -bus_params     {incr i; set bus_params     [lindex $args $i]}
        }
    }

    # Auto-infer bus interface
    auto_infer_interface -interface_name $interface_name -vlnv "xilinx.com:signal:data_rtl:1.0" -port_pattern $interface_name -bus_params $bus_params
}

proc ::xtools::ip_packager::add_reset_interface {args} {
    # Summary: Auto-infer Reset interface for single-bit port with same name.

    # Argument Usage:
    # -interface_name <arg>:    Define the interface name (e.g. User_Rst).
    # [-polarity <arg>]:        Optionally add POLARITY value to bus_param list.
    # [-bus_params <arg>]:      Optionally add list of bus parameters and values (e.g. [list [list PARAM_1 1] [list PARAM_2 2]]).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set bus_params [list]
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name {incr i; set interface_name [lindex $args $i]}
            -polarity       {incr i; set polarity       [lindex $args $i]}
            -bus_params     {incr i; set bus_params     [lindex $args $i]}
        }
    }

    # Auto-infer bus interface
    if {[info exists polarity]} {lappend bus_params [list POLARITY $polarity]}
    auto_infer_interface -interface_name $interface_name -vlnv "xilinx.com:signal:reset_rtl:1.0" -port_pattern $interface_name -bus_params $bus_params
}

proc ::xtools::ip_packager::add_interrupt_interface {args} {
    # Summary: Auto-infer Reset interface for single-bit port with same name.

    # Argument Usage:
    # -interface_name <arg>:    Define the interface name (e.g. User_Irq).
    # [-sensitivity <arg>]:     Optionally add SENSITIVITY value to bus_param list.
    # [-bus_params <arg>]:      Optionally add list of bus parameters and values (e.g. [list [list PARAM_1 1] [list PARAM_2 2]]).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set bus_params [list]
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name {incr i; set interface_name [lindex $args $i]}
            -sensitivity    {incr i; set sensitivity    [lindex $args $i]}
            -bus_params     {incr i; set bus_params     [lindex $args $i]}
        }
    }

    # Auto-infer bus interface
    if {[info exists sensitivity]} {lappend bus_params [list SENSITIVITY $sensitivity]}
    auto_infer_interface -interface_name $interface_name -vlnv "xilinx.com:signal:interrupt_rtl:1.0" -port_pattern $interface_name -bus_params $bus_params
}

# Manually-Mapped Interfaces ----------------------------------------------------------------------

proc ::xtools::ip_packager::add_bus_interface {args} {
    # Summary: Manually map bus interface.

    # Argument Usage:
    # -interface_name <arg>:    Define the interface name (e.g. User_Rst).
    # -vlnv <arg>:              Name or fully qualified VLNV identifier of bus interface (e.g. "aximm_rtl" or "xilinx.com:interface:aximm_rtl:1.0").
    # -interface_mode <arg>:    Interface mode (e.g. master, slave, system, mirroredMaster, mirroredSlave, mirroredSystem or monitor).
    # -port_map <arg>:          List of portmap pairs (e.g. [list [list physicalName abstractionName] [...]]).
    # [-bus_params <arg>]:      Optionally add list of bus parameters and values (e.g. [list [list PARAM_1 1] [list PARAM_2 2]]).
    # [-clock <arg>]:           Optionally define associated interface clock.
    # [-reset <arg>]:           Optionally define associated reset for interface clock (only in combination with -clock <arg>).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name     {incr i; set interface_name [lindex $args $i]}
            -vlnv               {incr i; set vlnv           [lindex $args $i]}
            -interface_mode     {incr i; set interface_mode [lindex $args $i]}
            -port_map           {incr i; set port_map       [lindex $args $i]}
            -bus_params         {incr i; set bus_params     [lindex $args $i]}
            -clock              {incr i; set clk            [lindex $args $i]}
            -reset              {incr i; set rst            [lindex $args $i]}
        }
    }

    # Find unique bus interface abstraction from Name or VLNV
    set ifBusAbs [_find_unique_bus_abstraction $vlnv]

    # Add new bus interface
    set addedInterface [ipx::add_bus_interface $interface_name [ipx::current_core]]
    set_property bus_type_vlnv         [get_property bus_type_vlnv $ifBusAbs] $addedInterface
    set_property abstraction_type_vlnv [get_property vlnv          $ifBusAbs] $addedInterface
    set_property interface_mode $interface_mode $addedInterface

    # Manually map bus interface ports
    foreach portMapPair $port_map {
        set physicalName    [lindex $portMapPair 0]
        set abstractionName [lindex $portMapPair 1]
        set abstractionList [get_property name [ipx::get_bus_abstraction_ports -of_objects $ifBusAbs]]
        if {[lsearch -exact $abstractionList $abstractionName] == -1} {
            error "ERROR: \[add_bus_interface\] Found no abstraction port that is named ${abstractionName} (LIST: ${abstractionList}). Select a abstraction port from the list and define the name accordingly!"
        }
        # Verify if port exists
        _get_ports $physicalName
        set_property physical_name $physicalName [ipx::add_port_map $abstractionName $addedInterface]
    }

    # Add optional bus parameters
    if {[info exists bus_param]} {
        foreach busParam $bus_params {
            set_property value [lindex $busParam 1] [ipx::add_bus_parameter [lindex $busParam 0] $addedInterface]
        }
    }

    # Assosciate interface clock and reset
    if {[info exists clk]} {
        associate_interface_clock -interface_name [get_property name $addedInterface] -clock $clk
        if {[info exists rst]} {
            associate_interface_clock -clock $clk -reset $rst
        }
    }
}

# Associate Clock/Reset ---------------------------------------------------------------------------

proc ::xtools::ip_packager::associate_interface_clock {args} {
    # Summary: Associate clock to interface.

    # Argument Usage:
    # -interface_name <arg>:    List of interface names (supports wildcards).
    # -clock <arg>:             Name of clock interface.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name     {incr i; set interface_name [lindex $args $i]}
            -clock              {incr i; set clock          [lindex $args $i]}
        }
    }

    # Associate clock to interface
    foreach interface $interface_name {
        foreach foundInterface [get_property name [_get_bus_interfaces ${interface} "bus_type_name !~ reset && bus_type_name !~ clock"]] {
            foreach clk $clock {
                if {[get_property bus_type_name [_get_bus_interfaces $clk]] != "clock"} {
                    error "ERROR: \[associate_interface_clock\] Option -clock must include interfaces of type clock."
                }
                ipx::associate_bus_interfaces -busif $foundInterface -clock $clk [ipx::current_core]
            }
        }
    }
}

proc ::xtools::ip_packager::associate_clock_reset {args} {
    # Summary: Associate reset to clock.

    # Argument Usage:
    # -clock <arg>:     List of clock interface names.
    # -reset <arg>:     List of reset interface names.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact [set option [string trim [lindex $args $i]]] {
            -clock      {incr i; set clock  [lindex $args $i]}
            -reset      {incr i; set reset  [lindex $args $i]}
        }
    }

    # Associate reset to clock-interface
    foreach clk $clock {
        if {[get_property bus_type_name [_get_bus_interfaces $clk]] != "clock"} {
            error "ERROR: \[associate_clock_reset\] Option -clock must include interfaces of type clock."
        }
        foreach rst $reset {
            if {[get_property bus_type_name [_get_bus_interfaces $rst]] != "reset"} {
                error "ERROR: \[associate_clock_reset\] Option -reset must include interfaces of type reset."
            }
            ipx::associate_bus_interfaces -clock $clk -reset $rst [ipx::current_core]
        }
    }
}

# Enablement Control ------------------------------------------------------------------------------

proc ::xtools::ip_packager::set_interface_enablement {args} {
    # Summary: Define interface enablement dependency.

    # Argument Usage:
    # -interface_name <arg>:    List of interface names.
    # -dependency <arg>:        Dependency condition (e.g. "\$i > 2").

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -interface_name     {incr i; set interface_name [lindex $args $i]}
            -dependency         {incr i; set dependency     [lindex $args $i]}
        }
    }

    # Set interface enablement condition
    set_property enablement_dependency $dependency [_get_bus_interfaces $interface_name]
}

proc ::xtools::ip_packager::set_port_enablement {args} {
    # Summary: Define port enablement dependency.

    # Argument Usage:
    # -port_name <arg>:         List of port names.
    # -dependency <arg>:        Dependency condition (e.g. "\$i > 2").
    # [-driver_value <arg>]:    Default driver value if input is not connected.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -port_name          {incr i; set port_name    [lindex $args $i]}
            -dependency         {incr i; set dependency   [lindex $args $i]}
            -driver_value       {incr i; set driver_value [lindex $args $i]}
        }
    }

    # Set port enablement condition
    set_property enablement_dependency $dependency [_get_ports $port_name]
    if {[info exists driver_value]} {
        set_property driver_value $driver_value [_get_ports $port_name]
    }
}

###################################################################################################
# EOF
###################################################################################################
