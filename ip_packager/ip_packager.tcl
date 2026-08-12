###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

package provide ::xtools::ip_packager 1.0

package require Tcl 8.5
package require Vivado 1.2020.1
package require ::tclapp::support::appinit 1.2

###################################################################################################
# IP Packager - Global Reload Functionality
###################################################################################################

namespace eval :: {
    proc reload_xtools_ip_packager {} {
        ::tclapp::support::appinit::unload_app "::xtools::ip_packager" "ip_packager"
        catch {namespace delete ::xtools::ip_packager}
        catch {namespace delete ::xtools}
        catch {namespace delete ::ip_packager}
        
        # Reinstall the packager
        set pkg_path ""
        foreach path $::auto_path {
            if {[file tail [file normalize $path]] eq "xtools"} {
                set pkg_path [file dirname [file normalize $path]]
                send_msg_id {XTOOLS 1-902} "INFO" "\[reload_xtools_ip_packager\] Found XTOOLS IP-Packager in ${pkg_path} directory."
                break
            }
        }
        ::tclapp::support::appinit::load_app $pkg_path "::xtools::ip_packager" "ip_packager"
        ::rdi::set_help_config -expose_namespace "ip_packager"
    }
}

###################################################################################################
# IP Packager - Main
###################################################################################################

namespace eval ::xtools::ip_packager {

    # Global Variables
    variable Home                   [file normalize [file dirname [info script]]]
    variable CurrentNamespace       [namespace tail [namespace current]]
    variable CurrentGuiParent       "nullptr"
    variable OldXguiFile            ""
    variable SwDriverTclFile        ""
    variable SwDriverTclBaseValues  [list]
    variable SwDriverTclHighValues  [list]
    variable GuiSupportTcl          [list]
    variable RootDir                "./.."
    variable ReportDir              "./reports"
    variable VivadoVersion          [version -short]

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
