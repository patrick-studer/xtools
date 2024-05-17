###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

package provide ::xtools::ip_packager 1.0

package require Tcl 8.5
package require Vivado 1.2020.1
package require ::tclapp::support::appinit 1.2

###################################################################################################
# IP Packager - Main
###################################################################################################

namespace eval ::xtools::ip_packager {

    # Global Variables
    variable Home               [file normalize [file dirname [info script]]]
    variable CurrentNamespace   [namespace tail [namespace current]]
    variable CurrentGuiParent   "nullptr"
    variable OldXguiFile        ""
    variable GuiSupportTcl      [list]
    variable RootDir            "."
    variable VivadoVersion      [version -short]
    
    namespace eval ::xtools::ip_packager::config {
    # Configuration Variables
        variable MsgConfigOverwrite         true
        variable RemoveInferredInterfaces   true
        variable SynthReports               true
        variable SynthLatchCheck            true
        variable ImplReports                true
        variable ImplTimingCheck            true
        variable ImplFailedNetsCheck        true
        variable ImplTimingWns              -0.0
        variable ImplTimingWhs              -0.0
    }
    
     # Allow Tcl to find tclIndex
    if {[lsearch -exact $::auto_path $Home] == -1} {
        lappend ::auto_path $Home
    }

}

###################################################################################################
# EOF
###################################################################################################
