###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager - Project
###################################################################################################

namespace eval ::xtools::ip_packager {
    # Export procs that should be allowed to import into other namespaces
    namespace export    config_package_project \
                        create_package_project \
                        simulate_package_project \
                        synth_package_project \
                        impl_package_project \
                        save_package_project \
                        close_package_project
}

###################################################################################################
# Helper Procedures
###################################################################################################

proc ::xtools::ip_packager::_check_vivado_version {} {
    # Summary: Internal procedure to check if actual Vivado version is supported by the IP Packager.

    # Argument Usage:

    # Return Value: TCL_ERROR if Vivado version is not supported, else TCL_OK.

    # Categories: xilinxtclstore, ip_packager

    variable VivadoVersion

    if {[package vsatisfies $VivadoVersion 2020.1-] == 0} {
        error "ERROR: \[_check_vivado_version\] Vivado ${VivadoVersion} is not supported for IpPackage 2020_1. Please upgrade your package.tcl script or use Vivado >=2020.1!"
    }
}

proc ::xtools::ip_packager::_overwrite_msg_config {} {
    # Summary: Internal procedure to configure Vivado message severities.

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable config::MsgConfigOverwrite

    if {$config::MsgConfigOverwrite} {
        reset_msg_config -id  *                     -default_severity -quiet
        set_msg_config   -id  {[Common 17-1361]}    -suppress -quiet
        set_msg_config   -id  {[Ipptcl 7-1550]}     -new_severity "INFO"
        set_msg_config   -id  {[Vivado 12-180]}     -new_severity "ERROR"
        set_msg_config   -id  {[Vivado 12-508]}     -new_severity "ERROR"
        set_msg_config   -id  {[Vivado 12-3631]}    -new_severity "INFO"
        set_msg_config   -id  {[Vivado 12-1348]}    -new_severity "INFO"
        set_msg_config   -id  {[Vivado 12-7122]}    -new_severity "INFO"  ; # Auto Incremental Compile:: No reference checkpoint was found in run synth_1. Auto-incremental flow will not be run, the standard flow will be run instead.
        set_msg_config   -id  {[IP_Flow 19-234]}    -suppress
        set_msg_config   -id  {[IP_Flow 19-377]}    -new_severity "INFO"
        set_msg_config   -id  {[IP_Flow 19-459]}    -new_severity "INFO"
        set_msg_config   -id  {[IP_Flow 19-1700]}   -suppress
        set_msg_config   -id  {[IP_Flow 19-3157]}   -new_severity "INFO"  ; # Bus Interface 'xxx': Bus parameter POLARITY is ACTIVE_LOW but port 'xxx' is not *resetn - please double check the POLARITY setting.
        set_msg_config   -id  {[IP_Flow 19-3656]}   -suppress
        set_msg_config   -id  {[IP_Flow 19-3833]}   -new_severity "ERROR"
        set_msg_config   -id  {[IP_Flow 19-4623]}   -suppress
        set_msg_config   -id  {[IP_Flow 19-4728]}   -suppress             ; # Bus Interface 'xxx': Added interface parameter 'xxx' with value 'xxx'.
        set_msg_config   -id  {[IP_Flow 19-5107]}   -suppress             ; # Inferred bus interface 'xxx' of definition 'vlnv' (from TCL Argument).
        set_msg_config   -id  {[IP_Flow 19-5226]}   -suppress             ; # Project source file 'xxx/component.xml' ignored by IP packager.
        set_msg_config   -id  {[IP_Flow 19-5905]}   -new_severity "INFO"
        set_msg_config   -id  {[IP_Flow 19-11770]}  -new_severity "INFO"  ; # Clock interface 'Clk' has no FREQ_HZ parameter.
        set_msg_config   -id  {[filemgmt 20-730]}   -new_severity "INFO"
        set_msg_config   -id  {[Route 35-198]}      -suppress             ; # Port <port_name> does not have an associated HD.PARTPIN_LOCS, which will prevent the partial routing of the signal <port_name>. Without this partial route, timing analysis to/from this port will not be accurate, and no routing information for this port can be exported.

    } else {
        puts "INFO: \[_overwrite_msg_config\] Message Config Overwrite is disabled. Continue with the default Vivado settings."
    }
}

proc ::xtools::ip_packager::_synth_checks {} {
    # Summary: Internal procedure to verify synthesis run resuls.

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable ReportDir
    variable config::SynthReports
    variable config::SynthLatchCheck

    # Open the synthesized design
    open_run [current_run -synthesis]

    # Check for latches
    if {$config::SynthLatchCheck} {
        variable latches [all_latches]
        if {$latches != ""} {
            error "ERROR: \[_synth_checks\] The synthesized design contains [llength ${latches}] latches (${latches})."
        } else {
            puts "INFO: \[_synth_checks\] No latches found."
        }
    } else {
        puts "WARNING: \[_synth_checks\] Synthesis Latch Checking is disabled."
    }

    # Export reports

    if {$config::SynthReports} {
        report_utilization -file "${ReportDir}/[current_run -synthesis]_utilization.rpt" -hierarchical
    }

    # Close the synthesized design
    close_design
}

proc ::xtools::ip_packager::_impl_checks {} {
    # Summary: Internal procedure to verify implementation run results.

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable ReportDir
    variable config::ImplReports
    variable config::ImplTimingCheck
    variable config::ImplFailedNetsCheck
    variable config::ImplTimingWns
    variable config::ImplTimingWhs

    # Open the synthesized design
    open_run [current_run -implementation]

    # Check implementation result
    set implStatus      [get_property STATUS            [current_run -implementation]]
    set implProgress    [get_property PROGRESS          [current_run -implementation]]
    set implStep        [get_property CURRENT_STEP      [current_run -implementation]]
    set implTime        [get_property STATS.ELAPSED     [current_run -implementation]]
    set implWns         [get_property STATS.WNS         [current_run -implementation]]
    set implWhs         [get_property STATS.WHS         [current_run -implementation]]
    set implFailedNets  [get_property STATS.FAILED_NETS [current_run -implementation]]

    if {$implProgress != "100%"} {
        if {[string match "Running*..." $implStatus]} {
            error "ERROR: \[_impl_checks\] Timeout in [current_run -implementation] (current step = ${implStep}, elapsed time = ${implTime}). Check if applied timeout is still enough."
        } else {
            error "ERROR: \[_impl_checks\] Failed in [current_run -implementation] with status \"${implStatus}\" (current step = ${implStep}, elapsed time = ${implTime}). Please check the logfile for further information."
        }
    } else {
        puts "INFO: \[_impl_checks\] Finished [current_run -implementation] sucessfully (elapsed time = ${implTime})."
    }

    if {$config::ImplTimingCheck} {
        # Check setup timing
        if {$implWns < $config::ImplTimingWns} {
            error "ERROR: \[_impl_checks\] Design has setup-timing violation (WNS = ${implWns})."
        } else {
            puts "INFO: \[_impl_checks\] Setup-timing OK (WNS = ${implWns})."
        }

        # Check hold timing
        if {$implWhs < $config::ImplTimingWhs} {
            error "ERROR: \[_impl_checks\] Design has hold-timing violation (WHS = ${implWhs})."
        } else {
            puts "INFO: \[_impl_checks\] Hold-timing OK (WHS = ${implWhs})."
        }
    } else {
        puts "WARNING: \[_impl_checks\] Implementation Timing Checking is disabled."
    }

    if {$config::ImplFailedNetsCheck} {
        # Check unrouted nets
        if {$implFailedNets > 0} {
            error "ERROR: \[_impl_checks\] Design has unrouted nets (failed nets = ${implFailedNets})."
        } else {
            puts "INFO: \[_impl_checks\] All nets are routed."
        }
    } else {
        puts "WARNING: \[_impl_checks\] Implementation Failed Nets Checking is disabled."
    }

    # Export reports
    if {$config::ImplReports} {
        report_methodology    -file "${ReportDir}/[current_run -implementation]_methodology.rpt"
        report_timing_summary -file "${ReportDir}/[current_run -implementation]_timing_summary.rpt" -no_detailed_paths
        report_drc            -file "${ReportDir}/[current_run -implementation]_drc.rpt"
    }

    # Close the implemented design
    close_design
}

proc ::xtools::ip_packager::_find_unique_bus_abstraction {vlnv} {
    # Summary: Internal procedure to find unique bus-abstraction from vlnv-identifier.

    # Argument Usage:
    # vlnv:             VLNV identifier.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Find unique bus interface abstraction from Name or VLNV
    if {[string last ":" $vlnv] == -1} {
        set ifBusAbs     [ipx::get_ipfiles -type "busabs" "*:${vlnv}:*"]
        if {[llength $ifBusAbs] == 0} {
            set ifBusAbs [ipx::get_ipfiles -type "busabs" "*:${vlnv}_*:*"]
        }
    } else {
        set ifBusAbs     [ipx::get_ipfiles -type "busabs" "*${vlnv}*"]
    }
    if {[llength $ifBusAbs] == 0} {
        error "ERROR: \[add_bus_interface\] Could not find an interface abstraction definition that matches ${vlnv}. Define a valid interface abstraction or use \"import_interface_definition\" if you forgot to import an user-created definition."
    } elseif {[llength $ifBusAbs] != 1} {
        error "ERROR: \[add_bus_interface\] Found multiple interface abstraction definitions that matches ${vlnv} (LIST: [get_property vlnv ${ifBusAbs}]). Select an abstraction definition (vlnv) from the list and define the fully qualified name accordingly!"
    }
    return $ifBusAbs
}

proc ::xtools::ip_packager::_find_unique_ip_core {vlnv} {
    # Summary: Internal procedure to find unique ip-core from vlnv-identifier.

    # Argument Usage:
    # vlnv:             VLNV identifier.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Find unique IP Core from Name or VLNV
    if {[string last ":" $vlnv] == -1} {
        set ipCore [ipx::get_cores -from catalog "*:${vlnv}:*"]
    } else {
        set ipCore [ipx::get_cores -from catalog "${vlnv}"]
    }
    if {[llength $ipCore] == 0} {
        error "ERROR: \[_find_unique_ip_core\] Could not find an IP core that matches ${vlnv}. Define a valid name or vlnv-identifier."
    } elseif {[llength $ipCore] != 1} {
        error "ERROR: \[_find_unique_ip_core\] Found multiple IP cores that match ${vlnv} (LIST: [get_property vlnv ${ipCore}]). Select an IP core from the list and define the vlnv-identifier accordingly!"
    }
}

###################################################################################################
# Package Project Procedures
###################################################################################################

proc ::xtools::ip_packager::config_package_project {args} {
    # Summary: Allows to modify/overwrite some IP-Packager configurations.

    # Argument Usage:
    # [-msg_config_overwrite <arg>]:        Set to false to disable overwriting of Vivado's message configuration.
    # [-remove_inferred_interfaces <arg>]:  Set to false to disable removal of automatically interred interfaces by Vivado (at package project creation).
    # [-synth_reports <arg>]:               Set to false to disable reports export for synthesized design.
    # [-synth_latch_check <arg>]:           Set to false to disable latch checking in synthesized design.
    # [-impl_reports <arg>]:                Set to false to disable reports export for implemented design.
    # [-impl_timing_check <arg>]:           Set to false to disable timing checking (WNS/WHS) in implemented design.
    # [-impl_failed_nets_check <arg>]:      Set to false to disable failed nets checking in implemented design.
    # [-impl_timing_wns <arg>]:             Set to negative value to relax implementation timing check of WNS (e.g. -0.2).
    # [-impl_timing_whs <arg>]:             Set to negative value to relax implementation timing check of WHS (e.g. -0.2).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable config::MsgConfigOverwrite
    variable config::RemoveInferredInterfaces
    variable config::SynthReports
    variable config::SynthLatchCheck
    variable config::ImplReports
    variable config::ImplTimingCheck
    variable config::ImplFailedNetsCheck
    variable config::ImplTimingWns
    variable config::ImplTimingWhs

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -msg_config_overwrite       {incr i; set msg_config_overwrite       [lindex $args $i]}
            -remove_inferred_interfaces {incr i; set remove_inferred_interfaces [lindex $args $i]}
            -synth_reports              {incr i; set synth_reports              [lindex $args $i]}
            -synth_latch_check          {incr i; set synth_latch_check          [lindex $args $i]}
            -impl_reports               {incr i; set impl_reports               [lindex $args $i]}
            -impl_timing_check          {incr i; set impl_timing_check          [lindex $args $i]}
            -impl_failed_nets_check     {incr i; set impl_failed_nets_check     [lindex $args $i]}
            -impl_timing_wns            {incr i; set impl_timing_wns            [lindex $args $i]}
            -impl_timing_whs            {incr i; set impl_timing_whs            [lindex $args $i]}
        }
    }

    # Overwrite global config variables
    if {[info exists msg_config_overwrite       ]} {set config::MsgConfigOverwrite          $msg_config_overwrite       }
    if {[info exists remove_inferred_interfaces ]} {set config::RemoveInferredInterfaces    $remove_inferred_interfaces }
    if {[info exists synth_reports              ]} {set config::SynthReports                $synth_reports              }
    if {[info exists synth_latch_check          ]} {set config::SynthLatchCheck             $synth_latch_check          }
    if {[info exists impl_reports               ]} {set config::ImplReports                 $impl_reports               }
    if {[info exists impl_timing_check          ]} {set config::ImplTimingCheck             $impl_timing_check          }
    if {[info exists impl_failed_nets_check     ]} {set config::ImplFailedNetsCheck         $impl_failed_nets_check     }
    if {[info exists impl_timing_wns            ]} {set config::ImplTimingWns               $impl_timing_wns            }
    if {[info exists impl_timing_whs            ]} {set config::ImplTimingWhs               $impl_timing_whs            }
}

proc ::xtools::ip_packager::create_package_project {args} {
    # Summary: Create a new IP package project for the specified top-level HDL file.

    # Argument Usage:
    # -top_file <arg>:                      Top-level HDL file for packaging.
    # [-copy_to <arg>]:                     Path to folder, where to copy/import the added Top-level HDL file.
    # [-library <arg>]:                     VHDL library to compile the Top-Level HDL file to.
    # [-root_dir <arg> = ./..]:             IP output root directory.
    # [-prj_name  <arg> = package_prj]:     Temporary package project name.
    # [-part <arg> = xc7z020iclg400-1L]:    FPGA part used for the package project.
    # [-report_dir <arg> = ./..]:           Directory location to store synth/impl reports.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable OldXguiFile
    variable RootDir
    variable ReportDir
    variable config::RemoveInferredInterfaces

    # Define default values for procedure arguments
    set prj_name    "package_prj"
    set part        "xc7z020iclg400-1L"

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -top_file   {incr i; set top_file   [lindex $args $i]}
            -copy_to    {incr i; set copy_to    [lindex $args $i]}
            -library    {incr i; set library    [lindex $args $i]}
            -root_dir   {incr i; set root_dir   [lindex $args $i]}
            -prj_name   {incr i; set prj_name   [lindex $args $i]}
            -part       {incr i; set part       [lindex $args $i]}
            -report_dir {incr i; set report_dir [lindex $args $i]}
        }
    }

    # Verify if function is called by a supported Vivado version
    _check_vivado_version

    # Verify if no project is opened
    if {[current_project -quiet] != ""} {
        error "ERROR: \[create_package_project\] There is a project opened in Vivado. Please close it before packaging a new IP Core."
    }

    # Define message severities
    _overwrite_msg_config
    
    # Limit maxThreads independently from OS
    set_param general.maxThreads 2

    # Update global RootDir variable
    if {[info exists root_dir]} {set RootDir [file normalize [path_relative_to [pwd] $root_dir]]}

    # Create package project
    create_project -part $part -force -quiet $prj_name $prj_name
    if {[info exists copy_to]} {
        set addedFiles [add_files -fileset "sources_1" -norecurse -force -copy_to [file normalize [path_relative_to_pwd $copy_to]] [path_relative_to_pwd $top_file]]
    } else {
        set addedFiles [add_files -fileset "sources_1" -norecurse -force [path_relative_to_pwd $top_file]]
    }
    if {[info exists library]} {set_property library $library $addedFiles}

    # Create reports directory
    if {[info exists report_dir]} {set ReportDir [file normalize [path_relative_to_pwd $report_dir]]}
    file delete -force $ReportDir
    file mkdir $ReportDir

    # Create new IPI component
    ipx::package_project -root_dir [file normalize $RootDir] -quiet

    # Disable OOC Synthesis Cache
    config_ip_cache -disable_cache

    # Add root_dir to IP location
    set_property ip_repo_paths $RootDir [current_project]
    update_ip_catalog -rebuild

    # Apply default family support
    set_property auto_family_support_level "level_2" [ipx::current_core]

    # IPI init (remove auto-generate stuff)
    ipgui::remove_page -component [ipx::current_core] [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core]]
    if {$config::RemoveInferredInterfaces} {
        foreach autoInfInterface [ipx::get_bus_interfaces -of_objects [ipx::current_core]] {
            ipx::remove_bus_interface [get_property name $autoInfInterface] [ipx::current_core]
        }
        foreach autoInfMemoryMap [ipx::get_memory_maps -of_objects [ipx::current_core]] {
            ipx::remove_memory_map [get_property name $autoInfMemoryMap] [ipx::current_core]
        }
        foreach autoInfAddressSpace [ipx::get_address_spaces -of_objects [ipx::current_core]] {
            ipx::remove_address_space [get_property name $autoInfAddressSpace] [ipx::current_core]
        }
    } else {
        puts "WARNING: \[create_package_project\] Removing inferred interfaces is disabled. The IP core will keep the automatically added interfaces. Please check in GUI if all interfaces are recognized correctly."
    }
    set OldXguiFile [file join $root_dir "xgui" "[get_property name [ipx::current_core]]_v[string map {. _} [get_property version [ipx::current_core]]].tcl"]
}

proc ::xtools::ip_packager::simulate_package_project {args} {
    # Summary: Launch Xilinx Simulator (xsim) on the package project.

    # Argument Usage:
    # -generics <arg>:    Define sim_1 top-level generics for simulation.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -generics   {incr i; set generics [lindex $args $i]}
        }
    }

    # Drive simulation top generics
    if {[info exists generics]} {
        set_property generic -value $generics -objects [get_filesets "sim_1"]
    } else {
        # Drive top-level generics with current default values from IPI
        set genericsList [list]
        set hdlParams [ipx::get_hdl_parameters]
        foreach hdlParam $hdlParams {
            set hdlParamType                [get_property data_type $hdlParam]
            set hdlParamBitStringLength     [get_property value_bit_string_length $hdlParam]
            set userParam                   [ipx::get_user_parameters [get_property name $hdlParam] -of_objects [ipx::current_core]]
            set userParamName               [get_property name $userParam]
            set userParamValue              [get_property value $userParam]
            if {[string match "std_logic" $hdlParamType] || [string match "std_logic_vector*" $hdlParamType]} {
                if {[string match "0x*" $userParamValue]} {
                    set userParamValue [string map [list "0x" "${hdlParamBitStringLength}'h"] [ipx::evaluate_to_bitstring_value -length $hdlParamBitStringLength $userParamValue [ipx::current_core]]]
                } else {
                    set userParamValue "${hdlParamBitStringLength}'b[string trim ${userParamValue} \"]"
                }
            }
            lappend genericsList "${userParamName}=${userParamValue}"
        }
        set_property generic -value $genericsList -objects [get_filesets "sim_1"]
    }

    # Run simulation
    update_compile_order -fileset "sim_1"
    launch_simulation
    close_sim
}

proc ::xtools::ip_packager::synth_package_project {args} {
    # Summary: Run test synthesis on package project.

    # Argument Usage:
    # [-part <arg>]:            Define specific part used for synthesis.
    # [-jobs <arg> = 1]:        Define number of jobs used for synthesis run.
    # [-timeout <arg>]:         Define synthesis run timeout in seconds.
    # [-generics <arg>]:        Define top-level generics for synthesis. If not defined, the current default values from the configuration GUI are used.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Define default values for procedure arguments
    set jobs 1

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -part       {incr i; set part       [lindex $args $i]}
            -jobs       {incr i; set jobs       [lindex $args $i]}
            -timeout    {incr i; set timeout    [lindex $args $i]}
            -generics   {incr i; set generics   [lindex $args $i]}
        }
    }

    # Create part-specific synthesis and implementation runs
    if {[info exists part]} {
        set synthRun [create_run "synth_${part}" -part $part -flow [get_property flow [lindex [get_runs -filter "is_synthesis==1"     ] 0]]]
        set implRun  [create_run "impl_${part}"  -part $part -flow [get_property flow [lindex [get_runs -filter "is_implementation==1"] 0]] -parent_run "synth_${part}"]
    } else {
        set synthRun [get_runs "synth_1"]
    }

    # Reset synthesis run
    current_run $synthRun
    reset_run   $synthRun

    # Set run properties
    set_property {AUTO_INCREMENTAL_CHECKPOINT} -value 0 -objects $synthRun
    set_property {strategy} -value {Vivado Synthesis Defaults} -objects $synthRun
    set_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects $synthRun

    # Drive simulation top generics
    if {[info exists generics]} {
        set_property generic -value $generics -objects [get_filesets "sources_1"]
    } else {
        # Drive top-level generics with current default values from IPI
        puts "WARNING: \[synth_package_project\] No top-level generics defined for synthesis. Run will use the current default values from the configuration GUI."
        set genericsList [list]
        set hdlParams [ipx::get_hdl_parameters]
        foreach hdlParam $hdlParams {
            set hdlParamName                [get_property name $hdlParam]
            set hdlParamType                [get_property data_type $hdlParam]
            set hdlParamBitStringLength     [get_property value_bit_string_length $hdlParam]
            set userParam                   [ipx::get_user_parameters $hdlParamName -of_objects [ipx::current_core]]
            set userParamName               [get_property name $userParam]
            set userParamValue              [get_property value $userParam]
            if {[string match "std_logic" $hdlParamType] || [string match "std_logic_vector*" $hdlParamType]} {
                if {[string match "0x*" $userParamValue]} {
                    set userParamValue [string map [list "0x" "${hdlParamBitStringLength}'h"] [ipx::evaluate_to_bitstring_value -length $hdlParamBitStringLength $userParamValue [ipx::current_core]]]
                } else {
                    set userParamValue "${hdlParamBitStringLength}'b[string trim ${userParamValue} \"]"
                }
            }
            lappend genericsList "${userParamName}=${userParamValue}"
        }
        set_property generic -value $genericsList -objects [get_filesets "sources_1"]
    }

    # Run synthesis
    launch_runs $synthRun -jobs $jobs
    if {[info exists timeout]} {
        wait_on_run $synthRun -timeout $timeout
    } else {
        wait_on_run $synthRun
    }

    # Check synthesis
    _synth_checks
}

proc ::xtools::ip_packager::impl_package_project {args} {
    # Summary: Run test implementation on package project.

    # Argument Usage:
    # [-part <arg>]:        Define specific part used for implementation.
    # [-jobs <arg> = 1]:    Define number of jobs used for implementation run.
    # [-timeout <arg>]:     Define implementation run timeout in seconds.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Define default values for procedure arguments
    set jobs 1

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -part       {incr i; set part    [lindex $args $i]}
            -jobs       {incr i; set jobs    [lindex $args $i]}
            -timeout    {incr i; set timeout [lindex $args $i]}
        }
    }

    # Load/Create part-specific synthesis and implementation runs
    if {[info exists part]} {
        set synthRun [get_runs "synth_${part}"]
        if {$synthRun == ""} {synth_package_project -jobs $jobs -part $part}
        set implRun  [get_runs "impl_${part}"]
    } else {
        set implRun [get_runs "impl_1"]
    }

    # Reset implementation run
    current_run $implRun
    reset_run   $implRun

    # Set run properties
    set_property {AUTO_INCREMENTAL_CHECKPOINT} -value 0 -objects $implRun
    set_property {strategy} -value {Vivado Implementation Defaults} -objects $implRun
    set_property {STEPS.PHYS_OPT_DESIGN.IS_ENABLED} -value false -objects $implRun

    # Run implementation
    launch_runs $implRun -jobs $jobs
    if {[info exists timeout]} {
        wait_on_run $implRun -timeout $timeout
    } else {
        wait_on_run $implRun
    }

    # Check implementation
    _impl_checks
}

proc ::xtools::ip_packager::save_package_project {args} {
    # Summary: Save package project and generate IP-core. Optionally, archive to zip.

    # Argument Usage:
    # [-archive_to <arg>]:  Define path to archive the final IPI to.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable OldXguiFile
    variable GuiSupportTcl
    variable SwDriverTclFile
    variable SwDriverTclBaseValues
    variable SwDriverTclHighValues
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -archive_to {incr i; set archive_to [lindex $args $i]}
        }
    }

    # Update XGUI file and delete default file
    ipx::create_xgui_files  [ipx::current_core]
    set xguiFileName "[get_property name [ipx::current_core]]_v[string map {. _} [get_property version [ipx::current_core]]].tcl"
    set newXguiFile [file join $RootDir "xgui" $xguiFileName]
    if {$newXguiFile != $OldXguiFile} {file delete -force $OldXguiFile}
    set OldXguiFile $newXguiFile

    # Sort IPI files according to compile order
    update_compile_order -fileset sources_1
    ipx::merge_project_changes files [ipx::current_core]

    # Convert all IPI file paths to relative (except URLs => type=unknown)
    puts "INFO: \[save_package_project\] Following files are refered by the packaged IP-core:"
    puts "      All paths relative to root directory (${RootDir})"
    foreach fileGroup [ipx::get_file_groups * -of_objects [ipx::current_core]] {
        puts "      - [get_property name $fileGroup]:"
        foreach file [ipx::get_files -of_objects $fileGroup] {
            if {[get_property type $file] != "unknown"} {
                set relative_file_path [path_relative_to_root [get_property name ${file}]]
                puts "        - ${relative_file_path}"
                set_property name $relative_file_path $file
            }
        }
    }

    # Sort Synthesis filegroup to have the top-level IPI wrapper at last position (Vivado requirement [IP_Flow 19-801] to infer library correctly)
    set fileGroup [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
    set firstFile [lindex [get_property name [ipx::get_files -of_objects $fileGroup]] 0]
    ipx::reorder_files -back $firstFile $fileGroup

    # Update XGUI File with custom GUI Support TCL
    if {[llength $GuiSupportTcl] > 0} {
        set f [open $newXguiFile "r"]
        set xguiContent [read $f]
        close $f
        set f [open $newXguiFile "w+"]
        puts $f "# Loading additional proc with user specified bodies to compute parameter values (user-specific)."
        foreach script [path_relative_to_root $GuiSupportTcl] {
            puts $f "source \[file join \[file dirname \[file dirname \[info script\]\]\] ${script}\]"
        }
        puts $f "${xguiContent}"
        close $f
    }

    # Update SW Driver TCL File with AXI Slave BASE/HIGH addresses
    if {$SwDriverTclFile != ""} {
        set baseValuesList ""
        foreach param $SwDriverTclBaseValues {
            set baseValuesList "${baseValuesList} \"${param}\""
        }
        set baseValuesList [string trim $baseValuesList]
        set highValuesList ""
        foreach param $SwDriverTclHighValues {
            set highValuesList "${highValuesList} \"${param}\""
        }
        set highValuesList [string trim $highValuesList]
        set replaceTags [dict create "<BASEADDR_LIST>" $baseValuesList "<HIGHADDR_LIST>" $highValuesList]
        replace_tags $SwDriverTclFile $replaceTags
    }

    # Save IPI core
    ipx::update_checksums   [ipx::current_core]
    ipx::save_core          [ipx::current_core]
    ipx::check_integrity    [ipx::current_core] -quiet

    # Update IP catalog to show newly packaged IP core
    update_ip_catalog -rebuild

    # Archive core if needed
    if {[info exists archive_to]} {
        set archiveName "[get_property name [ipx::current_core]]_v[string map {. _} [get_property version [ipx::current_core]]].zip"
        set archivePath [file join [file normalize [path_relative_to_pwd $archive_to]] $archiveName]
        puts "INFO: \[save_package_project\] Archive IP-core to ${archivePath}"
        ipx::archive_core $archivePath
    }
}

proc ::xtools::ip_packager::close_package_project {args} {
    # Summary: Finally close the temporary package project.

    # Argument Usage:
    # [-delete <arg> = false]:  When set to true, delete the temporary package project after closing.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Define default values for procedure arguments
    set delete  false

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -delete     {incr i; set delete [lindex $args $i]}
        }
    }

    # Close project with or without deleting it
    set projectDirectory [get_property DIRECTORY [current_project]]
    close_project
    if {$delete} {
        file delete -force $projectDirectory
        puts "INFO: \[close_package_project\] Deleted packager project (${projectDirectory})."
    }

}

###################################################################################################
# EOF
###################################################################################################
