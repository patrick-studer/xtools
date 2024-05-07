###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager - Project
###################################################################################################

namespace eval ::xtools::ip_packager {
    # Export procs that should be allowed to import into other namespaces
    namespace export    create_package_project \
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

proc ::xtools::ip_packager::_overwritte_msg_config {} {
    # Summary: Internal procedure to configure Vivado message severities.

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    reset_msg_config -id  *                     -default_severity -quiet
    set_msg_config   -id  {[Vivado 12-180]}     -new_severity "ERROR"
    set_msg_config   -id  {[Vivado 12-508]}     -new_severity "ERROR"
    set_msg_config   -id  {[Vivado 12-3631]}    -new_severity "INFO"
    set_msg_config   -id  {[Vivado 12-1348]}    -new_severity "INFO"
    set_msg_config   -id  {[Ipptcl 7-1550]}     -new_severity "INFO"
    set_msg_config   -id  {[IP_Flow 19-234]}    -suppress
    set_msg_config   -id  {[IP_Flow 19-377]}    -new_severity "INFO"
    set_msg_config   -id  {[IP_Flow 19-459]}    -new_severity "INFO"
    set_msg_config   -id  {[IP_Flow 19-1700]}   -suppress
    set_msg_config   -id  {[IP_Flow 19-3656]}   -suppress
    set_msg_config   -id  {[IP_Flow 19-3833]}   -new_severity "ERROR"
    set_msg_config   -id  {[IP_Flow 19-4623]}   -suppress
    set_msg_config   -id  {[IP_Flow 19-5226]}   -suppress
    set_msg_config   -id  {[IP_Flow 19-5905]}   -new_severity "INFO"
    set_msg_config   -id  {[filemgmt 20-730]}   -new_severity "INFO"
}

proc ::xtools::ip_packager::_synth_checks {} {
    # Summary: Internal procedure to verify synthesis run resuls.

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Open the synthesized design
    open_run [current_run -synthesis]

    # Check for latches
    variable latches [all_latches]
    if {$latches != ""} {
        error "ERROR: \[_synth_checks\] The synthesized design contains [llength ${latches}] latches (${latches})."
    } else {
        puts "INFO: \[_synth_checks\] No latches found."
    }

    # Export reports
    set rpt_dir "[get_property DIRECTORY [current_project]]/../reports"
    report_utilization    -file "${rpt_dir}/[current_run -synthesis]_utilization.rpt" -hierarchical

    # Close the synthesized design
    close_design
}

proc ::xtools::ip_packager::_impl_checks {} {
    # Summary: Internal procedure to verify implementation run results.

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

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

    # Check setup timing
    if {$implWns < -0.0} {
        error "ERROR: \[_impl_checks\] Design has setup-timing violation (WNS = ${implWns})."
    } else {
        puts "INFO: \[_impl_checks\] Setup-timing OK (WNS = ${implWns})."
    }

    # Check hold timing
    if {$implWhs < -0.0} {
        error "ERROR: \[_impl_checks\] Design has hold-timing violation (WHS = ${implWhs})."
    } else {
        puts "INFO: \[_impl_checks\] Hold-timing OK (WHS = ${implWhs})."
    }

    # Check unrouted nets
    if {$implFailedNets > 0} {
        error "ERROR: \[_impl_checks\] Design has unrouted nets (failed nets = ${implFailedNets})."
    } else {
        puts "INFO: \[_impl_checks\] All nets are routed."
    }

    # Export reports
    set rpt_dir "[get_property DIRECTORY [current_project]]/../reports"
    report_timing_summary -file "${rpt_dir}/[current_run -implementation]_timing_summary.rpt" -no_detailed_paths
    report_drc            -file "${rpt_dir}/[current_run -implementation]_drc.rpt"
    report_methodology    -file "${rpt_dir}/[current_run -implementation]_methodology.rpt"

    # Close the implemented design
    close_design
}

proc ::xtools::ip_packager::_find_unique_bus_abstraction {vlnv} {
    # Summary: Internal procedure to find unique bus-abstraction from vlnv-identifier.

    # Argument Usage:
    # vlnv:             VLNV identifier

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
    # vlnv:             VLNV identifier

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

proc ::xtools::ip_packager::create_package_project {args} {
    # Summary:
    # Create a new IP package project for the specified top-level HDL file.

    # Argument Usage:
    # -top_file <arg>:                      Top-level HDL file for packaging
    # [-copy_to <arg>]:                     Path to folder, where to copy/import the added Top-level HDL file
    # [-root_dir <arg> = ./..]:             IP output root directory
    # [-prj_name  <arg> = package_prj]:     Temporary package project name
    # [-part <arg> = xc7z020iclg400-1L]:    FPGA part used for the package project

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable OldXguiFile
    variable RootDir

    # Define default values for procedure arguments
    set prj_name "package_prj"
    set part     "xc7z020iclg400-1L"

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -top_file   {incr i; set top_file [lindex $args $i]}
            -copy_to    {incr i; set copy_to  [lindex $args $i]}
            -root_dir   {incr i; set root_dir [lindex $args $i]}
            -prj_name   {incr i; set prj_name [lindex $args $i]}
            -part       {incr i; set part     [lindex $args $i]}
        }
    }

    # Verify if function is called by a supported Vivado version
    _check_vivado_version

    # Verify if no project is opened
    if {[current_project -quiet] != ""} {
        error "ERROR: \[create_package_project\] There is a project opened in Vivado. Please close it before packaging a new IP Core."
    }

    # Define message severities
    _overwritte_msg_config

    # Update global RootDir variable
    if {[info exists root_dir]} {set RootDir [file normalize [path_relative_to_pwd $root_dir]]}

    # Create package project
    create_project -part $part -force -quiet $prj_name $prj_name
    if {[info exists copy_to]} {
        set addedFiles [add_files -fileset "sources_1" -norecurse -force -copy_to [file normalize [path_relative_to_pwd $copy_to]] [path_relative_to_pwd $top_file]]
    } else {
        set addedFiles [add_files -fileset "sources_1" -norecurse -force [path_relative_to_pwd $top_file]]
    }
    # Create reports directory
    set rpt_dir "[get_property DIRECTORY [current_project]]/../reports"
    file delete -force $rpt_dir
    file mkdir $rpt_dir

    # Create new IPI component
    ipx::package_project -root_dir [file normalize $RootDir] -quiet

    # Disable OOC Synthesis Cache
    config_ip_cache -disable_cache

    # Add root_dir to IP location
    set_property ip_repo_paths $RootDir [current_project]
    update_ip_catalog

    # Apply default family support
    set_property auto_family_support_level "level_2" [ipx::current_core]

    # IPI init (remove auto-generate stuff)
    ipgui::remove_page -component [ipx::current_core] [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core]]
    ipx::remove_bus_interface [get_property name [ipx::get_bus_interfaces -of_objects  [ipx::current_core]]] [ipx::current_core]
    set OldXguiFile [file join $root_dir "xgui" "[get_property name [ipx::current_core]]_v[string map {. _} [get_property version [ipx::current_core]]].tcl"]
}

proc ::xtools::ip_packager::simulate_package_project {args} {
    # Summary: Launch Xilinx Simulator (xsim) on the package project.

    # Argument Usage:
    # [-generics <arg>]:    Define sim_1 top-level generics for simulation. If not defined, the current default values from the configuration GUI are used.

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
            set hdlParamName   [get_property name $hdlParam]
            set userParam      [ipx::get_user_parameters $hdlParamName -of_objects [ipx::current_core]]
            set userParamName  [get_property name $userParam]
            set userParamValue [get_property value $userParam]
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
    # [-part <arg>]:        Define specific part used for synthesis
    # [-jobs <arg> = 4]:    Define number of jobs used for synthesis run
    # [-timeout <arg>]:     Define synthesis run timeout in seconds

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Define default values for procedure arguments
    set jobs 4

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -part               {incr i; set part            [lindex $args $i]}
            -jobs               {incr i; set jobs            [lindex $args $i]}
            -timeout            {incr i; set timeout         [lindex $args $i]}
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

    # Set project into "out_of_context" mode (no IOB placement)
    set_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects $synthRun

    # Drive top-level generics with current default values from IPI
    set genericsList [list]
    set hdlParams [ipx::get_hdl_parameters]
    foreach hdlParam $hdlParams {
        set hdlParamName   [get_property name $hdlParam]
        set userParam      [ipx::get_user_parameters $hdlParamName -of_objects [ipx::current_core]]
        set userParamName  [get_property name $userParam]
        set userParamValue [get_property value $userParam]
        lappend genericsList "${userParamName}=${userParamValue}"
    }
    set_property generic -value $genericsList -objects [get_filesets "sources_1"]

    # Run synthesis
    launch_runs $synthRun -jobs    $jobs
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
    # [-part <arg>]:        Define specific part used for implementation
    # [-jobs <arg> = 4]:    Define number of jobs used for implementation run
    # [-timeout <arg>]:     Define implementation run timeout in seconds

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Define default values for procedure arguments
    set jobs 4

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
    # Summary: Save package project and generate IP-core.

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable OldXguiFile
    variable GuiSupportTcl
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
        }
    }

    # Sort IPI files according to compile order
    update_compile_order -fileset sources_1
    ipx::merge_project_changes files [ipx::current_core]

    # Convert all IPI file paths to relative (except URLs => type=unknown)
    puts "INFO: \[save_package_project\] Following files are refered by the packaged IP-core:"
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

    # Update XGUI file and delete default file
    ipx::create_xgui_files  [ipx::current_core]
    set xguiFileName "[get_property name [ipx::current_core]]_v[string map {. _} [get_property version [ipx::current_core]]].tcl"
    set newXguiFile [file join $RootDir "xgui" $xguiFileName]
    if {$newXguiFile != $OldXguiFile} {file delete -force $OldXguiFile}
    set OldXguiFile $newXguiFile

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

    # Save IPI core
    ipx::update_checksums   [ipx::current_core]
    ipx::save_core          [ipx::current_core]
    ipx::check_integrity    [ipx::current_core] -quiet

    # Update IP catalog to show newly packaged IP core
    update_ip_catalog -rebuild
}

proc ::xtools::ip_packager::close_package_project {args} {
    # Summary: Finally close the temporary package project.

    # Argument Usage:
    # [-delete <arg> = false]:  When set to true, delete the temporary package project after closing

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
