###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager - Compartibility
###################################################################################################

namespace eval ::xtools::ip_packager {
    # Export procs that should be allowed to import into other namespaces
    namespace export    set_supported_families \
                        set_auto_family_support \
                        set_unsupported_simulators
}

###################################################################################################
# Compartibility Procedures
###################################################################################################

proc ::xtools::ip_packager::set_supported_families {families_lifecycle_pairs} {
    # Summary: Set supported families for this packaged IP-core.
    
    # Argument Usage:
    # families_lifecycle_pairs: List with pairs of FPGA-familiy identifiers and lifecycle identifiers
    
    # Return Value: TCL_OK
    
    # Categories: xilinxtclstore, ip_packager
    
    set_property auto_family_support_level "level_0" [ipx::current_core]
    set_property supported_families $families_lifecycle_pairs [ipx::current_core]
}

proc ::xtools::ip_packager::set_auto_family_support {level_str} {
    # Summary:  Set automated family support level for this packaged IP-core.
    
    # Argument Usage:
    # level_str:        Auto familiy support level string (e.g. "level_1")
    
    # Return Value: TCL_OK
    
    # Categories: xilinxtclstore, ip_packager
    
    set_property supported_families "" [ipx::current_core]
    set_property auto_family_support_level $level_str [ipx::current_core]
}

proc ::xtools::ip_packager::set_unsupported_simulators {simulators} {
    # Summary: Define unsupported simulators for this packaged IP-core.
    
    # Argument Usage:
    # simulators:       List of unsupported simulators identifiers (e.g. xsim, modelsim, questa, xcelium, vcs, riviera, activehdl)
    
    # Return Value: TCL_OK
    
    # Categories: xilinxtclstore, ip_packager
    
    set_property unsupported_simulators $simulators [ipx::current_core]
}

###################################################################################################
# EOF
###################################################################################################
