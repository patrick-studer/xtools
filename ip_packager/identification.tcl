###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager - Identification
###################################################################################################

namespace eval ::xtools::ip_packager {
    # Export procs that should be allowed to import into other namespaces
    namespace export    set_identification
}

###################################################################################################
# Identification Procedures
###################################################################################################

proc ::xtools::ip_packager::set_identification {args} {
    # Summary: Set packaged IP-core identification values.
    
    # Argument Usage:
    # [-vendor <arg>]:                  Vendor sting of VLNV identifier (no white-spaces allowed)
    # [-library <arg>]:                 Library sting of VLNV identifier (no white-spaces allowed)
    # [-name <arg>]:                    Name sting of VLNV identifier (no white-spaces allowed)
    # [-version <arg>]:                 Version number of VLNV identifier (e.g. 1.0)
    # [-core_revision <arg>]:           Revision number. If not overwritten by the user, the revision identifier is set to seconds passed since 1 January 1970, 00:00 UTC (tcl: [clock seconds]).
    # [-display_name <arg>]:            Displayed name sting.
    # [-description <arg>]:             Description string.
    # [-display_vendor <arg>]:          Displayed vendor sting.
    # [-company_url <arg>]:             Company homepage URL.
    # [-taxonomy <arg>]:                Taxonomy sting. Separate subgroups with "/" and underscores are represented as white-spaces (e.g. "/MY_CORES/Ip_Packager").
    
    # Return Value: TCL_OK
    
    # Categories: xilinxtclstore, ip_packager
    
    # Default values
    set core_revision [clock seconds]
    
    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -vendor         {incr i; set vendor         [lindex $args $i]}
            -library        {incr i; set library        [lindex $args $i]}
            -name           {incr i; set name           [lindex $args $i]}
            -version        {incr i; set version        [lindex $args $i]}
            -core_revision  {incr i; set core_revision  [lindex $args $i]}
            -display_name   {incr i; set display_name   [lindex $args $i]}
            -description    {incr i; set description    [lindex $args $i]}
            -display_vendor {incr i; set display_vendor [lindex $args $i]}
            -company_url    {incr i; set company_url    [lindex $args $i]}
            -taxonomy       {incr i; set taxonomy       [lindex $args $i]}
        }
    }

    # Set provided properties
    if {[info exists vendor        ]} {set_property vendor              $vendor         [ipx::current_core]}
    if {[info exists library       ]} {set_property library             $library        [ipx::current_core]}
    if {[info exists name          ]} {set_property name                $name           [ipx::current_core]}
    if {[info exists version       ]} {set_property version             $version        [ipx::current_core]}
    if {[info exists core_revision ]} {set_property core_revision       $core_revision  [ipx::current_core]}
    if {[info exists display_name  ]} {set_property display_name        $display_name   [ipx::current_core]}
    if {[info exists description   ]} {set_property description         $description    [ipx::current_core]}
    if {[info exists display_vendor]} {set_property vendor_display_name $display_vendor [ipx::current_core]}
    if {[info exists company_url   ]} {set_property company_url         $company_url    [ipx::current_core]}
    if {[info exists taxonomy      ]} {set_property taxonomy            $taxonomy       [ipx::current_core]}
    
}

###################################################################################################
# EOF
###################################################################################################
