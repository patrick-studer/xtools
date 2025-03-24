###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager - Files
###################################################################################################

namespace eval ::xtools::ip_packager {
    # Export procs that should be allowed to import into other namespaces
    namespace export    add_design_sources \
                        add_design_simulation \
                        add_design_constraints \
                        add_design_subcores \
                        add_exdes_script \
                        add_exdes_sources \
                        add_exdes_simulation \
                        add_exdes_constraints \
                        add_exdes_subcores \
                        add_logo \
                        add_readme \
                        add_product_guide \
                        add_changelog \
                        add_software_driver \
                        add_utility_scripts \
                        create_upgrade_tcl_template \
                        add_upgrade_tcl \
                        create_bd_tcl_template \
                        add_bd_tcl \
                        add_gui_support_tcl
}

###################################################################################################
# File Groups Procedures
###################################################################################################

# IP Core Design Files ----------------------------------------------------------------------------

proc ::xtools::ip_packager::add_design_sources {args} {
    # Summary: Add design sources (sources_1) to the packaged IP-core.

    # Argument Usage:
    # -files <arg>:            List of design sources file-paths to be added to the packaged IP-core.
    # [-copy_to <arg>]:        Path to folder, where to copy/import the added design sources.
    # [-library <arg>]:        VHDL library to compile the added design sources to.
    # [-file_type <arg>]:      Overwrite design source file type (e.g. "VHDL 2008").
    # [-global_include <arg>]: Boolean to mark the Verilog files as global includes.
    # [-enabled <arg>]:        Boolean to define enabled state of a source file.

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
            -library        {incr i; set library        [lindex $args $i]}
            -file_type      {incr i; set file_type      [lindex $args $i]}
            -global_include {incr i; set global_include [lindex $args $i]}
            -enabled        {incr i; set enabled        [lindex $args $i]}
        }
    }

    # Add files to project
    if {[info exists copy_to]} {
        set addedFiles [add_files -fileset "sources_1" -norecurse -force -copy_to [file normalize [path_relative_to_pwd $copy_to]] [path_relative_to_pwd $files]]
    } else {
        set addedFiles [add_files -fileset "sources_1" -norecurse -force [path_relative_to_pwd $files]]
    }
    if {[info exists library       ]} {set_property library        $library        [get_files -quiet -filter {file_type =~ "VHDL*"} $addedFiles]}
    if {[info exists file_type     ]} {set_property file_type      $file_type      $addedFiles}
    if {[info exists global_include]} {set_property global_include $global_include $addedFiles}
    if {[info exists enabled       ]} {set_property enabled        $enabled        $addedFiles}

    # Merge package project files to IPI filesets
    ipx::merge_project_changes files [ipx::current_core]
}

proc ::xtools::ip_packager::add_design_simulation {args} {
    # Summary: Add simulation sources (sim_1) to the packaged IP-core.

    # Argument Usage:
    # -files <arg>:            List of simulation sources file-paths to be added to the packaged IP-core.
    # [-copy_to <arg>]:        Path to folder, where to copy/import the added simulation sources.
    # [-library <arg>]:        VHDL library to compile the added simulation sources to.
    # [-file_type <arg>]:      Overwrite simulation source file type (e.g. "VHDL 2008").
    # [-global_include <arg>]: Boolean to mark the Verilog files as global includes.
    # [-enabled <arg>]:        Boolean to define enabled state of a source file.

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
            -library        {incr i; set library        [lindex $args $i]}
            -file_type      {incr i; set file_type      [lindex $args $i]}
            -global_include {incr i; set global_include [lindex $args $i]}
            -enabled        {incr i; set enabled        [lindex $args $i]}
        }
    }

    # Add files to project
    if {[info exists copy_to]} {
        set addedFiles [add_files -fileset "sim_1" -norecurse -force -copy_to [file normalize [path_relative_to_pwd $copy_to]] [path_relative_to_pwd $files]]
    } else {
        set addedFiles [add_files -fileset "sim_1" -norecurse -force [path_relative_to_pwd $files]]
    }
    if {[info exists library       ]} {set_property library        $library        [get_files -quiet -filter {file_type =~ "VHDL*"} $addedFiles]}
    if {[info exists file_type     ]} {set_property file_type      $file_type      $addedFiles}
    if {[info exists global_include]} {set_property global_include $global_include $addedFiles}
    if {[info exists enabled       ]} {set_property enabled        $enabled        $addedFiles}

    # Merge package project files to IPI filesets
    ipx::merge_project_changes files [ipx::current_core]
}

proc ::xtools::ip_packager::add_design_constraints {args} {
    # Summary: Add constraint sources (constrs_1) to the packaged IP-core.

    # Argument Usage:
    # -files <arg>:              List of constraints file-paths to be added to the packaged IP-core.
    # [-copy_to <arg>]:          Path to folder, where to copy/import the added constraints sources.
    # [-used_in <arg>]:          List with design-step identifiers (useful for constraints).
    # [-processing_order <arg>]: Processing-order identifier (e.g. "EARLY", "NORMAL", "LATE").
    # [-scoped_to_cells <arg>]:  Scope constraints to specific cells relative to the IP-core top-level.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -files            {incr i; set files            [lindex $args $i]}
            -copy_to          {incr i; set copy_to          [lindex $args $i]}
            -used_in          {incr i; set used_in          [lindex $args $i]}
            -processing_order {incr i; set processing_order [lindex $args $i]}
            -scoped_to_cells  {incr i; set scoped_to_cells  [lindex $args $i]}
        }
    }

    # Ensure OOC files are used in package project synthesis/implementation
    if {$used_in == "out_of_context"} { set used_in "synthesis implementation out_of_context"}

    # Add files to package project
    if {[info exists copy_to]} {
        set addedFiles [add_files -fileset "constrs_1" -norecurse -force -copy_to [file normalize [path_relative_to_pwd $copy_to]] [path_relative_to_pwd $files]]
    } else {
        set addedFiles [add_files -fileset "constrs_1" -norecurse -force [path_relative_to_pwd $files]]
    }


    if {[info exists used_in         ]} {set_property used_in           $used_in            $addedFiles}
    if {[info exists processing_order]} {set_property processing_order  $processing_order   $addedFiles}
    if {[info exists scoped_to_cells ]} {set_property scoped_to_cells   $scoped_to_cells    $addedFiles}

    # Merge package project files to IPI filesets
    ipx::merge_project_changes files [ipx::current_core]
}

proc ::xtools::ip_packager::add_design_subcores {args} {
    # Summary: Add IP subcore-reference to the packaged IP-core.

    # Argument Usage:
    # -vlnv <arg>:      List of subcore-reference VLNV identifiers to be added to the packaged IP-core (synthesis and simulation).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -vlnv       {incr i; set vlnv [lindex $args $i]}
        }
    }

    foreach subcore $vlnv {
        # Find unique IP Core from Name or VLNV
        set subCore [_find_unique_ip_core $subcore]

        # Add new subcore references to IPI file sets
        foreach {fgType fgName} {"synthesis" "xilinx_anylanguagesynthesis" "simulation xilinx_anylanguagebehavioralsimulation"} {
            set fileGroup [ipx::add_file_group -type $fgType $fgName [ipx::current_core]]
            foreach core [get_property vlnv $subCore] {
                set addedCore [ipx::add_subcore $core $fileGroup]
            }
        }
    }
}

# Example Design Files ----------------------------------------------------------------------------

proc ::xtools::ip_packager::add_exdes_script {args} {
    # Summary: Add Example Design creation script to the packaged IP-core.

    # Argument Usage:
    # -files <arg>:         List of example-design creation scripts to be added to the packaged IP-core (synthesis and simulation).
    # [-copy_to <arg>]:     Path to folder, where to copy/import the added example-design creation scripts.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -files      {incr i; set files     [lindex $args $i]}
            -copy_to    {incr i; set copy_to   [lindex $args $i]}
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

    # Add files to IPI file sets
    foreach {fgType fgName} {"examples_script" "xilinx_examplesscript"} {
        set fileGroup [ipx::add_file_group -type $fgType $fgName [ipx::current_core]]
        foreach file $files {
            set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
        }
    }
}

proc ::xtools::ip_packager::add_exdes_sources {args} {
    # Summary: Add Example Design sources to the packaged IP-core.

    # Argument Usage:
    # -files <arg>:            List of source file-paths to be added as example-design to the packaged IP-core.
    # [-copy_to <arg>]:        Path to folder, where to copy/import the added example-design sources.
    # [-library <arg>]:        VHDL library to compile the added design sources to.
    # [-file_type <arg>]:      Overwrite design source file type (e.g. "VHDL 2008").

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -files      {incr i; set files     [lindex $args $i]}
            -copy_to    {incr i; set copy_to   [lindex $args $i]}
            -library    {incr i; set library   [lindex $args $i]}
            -file_type  {incr i; set file_type [lindex $args $i]}
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

    # Add files to IPI file sets
    foreach {fgType fgName} {"examples_synthesis" "xilinx_examplessynthesis" "examples_simulation" "xilinx_examplessimulation"} {
        set fileGroup [ipx::add_file_group -type $fgType $fgName [ipx::current_core]]
        foreach file $files {
            set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
            if {[info exists library  ]} {set_property library_name $library   [get_files -quiet -filter {file_type =~ "VHDL*"} $addedFiles]}
            if {[info exists file_type]} {set_property type         $file_type $addedFile}
        }
    }
}

proc ::xtools::ip_packager::add_exdes_simulation {args} {
    # Summary: Add Example Design simulation sources to the packaged IP-core.

    # Argument Usage:
    # -files <arg>:            List of source file-paths to be added as example-design to the packaged IP-core.
    # [-copy_to <arg>]:        Path to folder, where to copy/import the added example-design simulation sources.
    # [-library <arg>]:        VHDL library to compile the added simulation sources to.
    # [-file_type <arg>]:      Overwrite simulation source file type (e.g. "VHDL 2008").

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -files      {incr i; set files     [lindex $args $i]}
            -copy_to    {incr i; set copy_to   [lindex $args $i]}
            -library    {incr i; set library   [lindex $args $i]}
            -file_type  {incr i; set file_type [lindex $args $i]}
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

    # Add files to IPI file sets
    foreach {fgType fgName} {"examples_simulation" "xilinx_examplessimulation"} {
        set fileGroup [ipx::add_file_group -type $fgType $fgName [ipx::current_core]]
        foreach file $files {
            set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
            if {[info exists library  ]} {set_property library_name $library   [get_files -quiet -filter {file_type =~ "VHDL*"} $addedFiles]}
            if {[info exists file_type]} {set_property type         $file_type $addedFile}
        }
    }
}

proc ::xtools::ip_packager::add_exdes_constraints {args} {
    # Summary: Add Example Design constraints sources to the packaged IP-core.

    # Argument Usage:
    # -files <arg>:     List of constraints file-paths to be added as example-design to the packaged IP-core.
    # [-copy_to <arg>]: Path to folder, where to copy/import the added example-design constraints.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -files      {incr i; set files     [lindex $args $i]}
            -copy_to    {incr i; set copy_to   [lindex $args $i]}
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

    # Add files to IPI file sets
    foreach {fgType fgName} {"examples_synthesis" "xilinx_examplessynthesis" "examples_implementation" "xilinx_implementation"} {
        set fileGroup  [ipx::add_file_group -type $fgType $fgName [ipx::current_core]]
        foreach file $files {
            set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
        }
    }
}

proc ::xtools::ip_packager::add_exdes_subcores {args} {
    # Summary: Add Example Design IP subcore-references to the packaged IP-core.

    # Argument Usage:
    # -vlnv <arg>:      List of subcore-reference VLNV identifiers to be added to the packaged IP-core example-design (synthesis and simulation).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -vlnv       {incr i; set vlnv [lindex $args $i]}
        }
    }

    foreach subcore $vlnv {
        # Find unique IP Core from Name or VLNV
        set subCore [_find_unique_ip_core $subcore]

        # Add new subcore references to IPI file sets
        foreach {fgType fgName} {"examples_synthesis" "xilinx_examplessynthesis" "examples_simulation" "xilinx_examplessimulation"} {
            set fileGroup [ipx::add_file_group -type $fgType $fgName [ipx::current_core]]
            foreach core [get_property vlnv $subCore] {
                set addedCore ipx::add_subcore $core $fileGroup
            }
        }
    }
}

# Documentation Files -----------------------------------------------------------------------------

proc ::xtools::ip_packager::add_logo {args} {
    # Summary: Add custom logo to the packaged IP-core.

    # Argument Usage:
    # -file <arg>:      File-path to logo file.
    # [-copy_to <arg>]: Path to folder, where to copy/import the added logo. Supported file extension is png.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -file       {incr i; set file       [lindex $args $i]}
            -copy_to    {incr i; set copy_to    [lindex $args $i]}
        }
    }
    # Verify that only a single file is provided
    if {[llength $file] != 1} {error "ERROR: \[add_logo\] Option -file must define a single file path."}

    # Copy files if needed
    if {[info exists copy_to]} {
        file mkdir [set copyToDir [file normalize [path_relative_to_pwd $copy_to]]]
        file copy -force [path_relative_to_pwd $file] $copyToDir
        set file [file join $copyToDir [file tail $file]]
    }

    # Verify file type support
    switch -glob -- $file {
        *.png                   {set type "LOGO"}
        default                 {error "ERROR: \[add_logo\] File type not allowed. Supported file extensions are png."}
    }

    # Add file to IPI file sets
    set fileGroup [ipx::add_file_group -type "utility" "xilinx_utilityxitfiles" [ipx::current_core]]
    set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
    set_property type $type $addedFile
}

proc ::xtools::ip_packager::add_readme {args} {
    # Summary: Add readme file to the packaged IP-core.

    # Argument Usage:
    # -file <arg>:      File-path to readme file.
    # [-copy_to <arg>]: Path to folder, where to copy/import the added readme. Supported file extensions are pdf, txt, md, htm(l) and http(s).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -file       {incr i; set file       [lindex $args $i]}
            -copy_to    {incr i; set copy_to    [lindex $args $i]}
        }
    }
    # Verify that only a single file is provided
    if {[llength $file] != 1} {error "ERROR: \[add_readme\] Option -file must define a single file path."}

    # Copy files if needed
    if {[info exists copy_to]} {
        file mkdir [set copyToDir [file normalize [path_relative_to_pwd $copy_to]]]
        file copy -force [path_relative_to_pwd $file] $copyToDir
        set file [file join $copyToDir [file tail $file]]
    }

    # Verify file type support
    switch -glob -- $file {
        https://*   - http://*  {set type "unknown"}
        *.pdf                   {set type "pdf"}
        *.txt       - *.md      {set type "text"}
        *.html      - *.htm     {set type "html"}
        default                 {error "ERROR: \[add_readme\] File type not allowed. Supported file extensions are pdf, txt, md, htm(l) and http(s)."}
    }

    # Add file to IPI file sets
    set fileGroup [ipx::add_file_group -type "readme" "xilinx_readme" [ipx::current_core]]
    set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
    set_property type $type $addedFile
}

proc ::xtools::ip_packager::add_product_guide {args} {
    # Summary: Add product-guide file to the packaged IP-core.

    # Argument Usage:
    # -file <arg>:      File-path to product guide file.
    # [-copy_to <arg>]: Path to folder, where to copy/import the added product guide. Supported file extensions are pdf, txt, md, htm(l) and http(s).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -file       {incr i; set file       [lindex $args $i]}
            -copy_to    {incr i; set copy_to    [lindex $args $i]}
        }
    }
    # Verify that only a single file is provided
    if {[llength $file] != 1} {error "ERROR: \[add_product_guide\] Option -file must define a single file path."}

    # Copy files if needed
    if {[info exists copy_to]} {
        file mkdir [set copyToDir [file normalize [path_relative_to_pwd $copy_to]]]
        file copy -force [path_relative_to_pwd $file] $copyToDir
        set file [file join $copyToDir [file tail $file]]
    }

    # Verify file type support
    switch -glob -- $file {
        https://*   - http://*  {set type "unknown"}
        *.pdf                   {set type "pdf"}
        *.txt       - *.md      {set type "text"}
        *.html      - *.htm     {set type "html"}
        default                 {error "ERROR: \[add_product_guide\] File type not allowed. Supported file extensions are pdf, txt, md, htm(l) and http(s)."}
    }

    # Add file to IPI file sets
    set fileGroup [ipx::add_file_group -type "product_guide" "xilinx_productguide" [ipx::current_core]]
    set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
    set_property type $type $addedFile
}

proc ::xtools::ip_packager::add_changelog {args} {
    # Summary: Add changelog file to the packaged IP-core.

    # Argument Usage:
    # -file <arg>:      File-path to changelog file.
    # [-copy_to <arg>]: Path to folder, where to copy/import the added changelog. Supported file extensions are txt and md.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -file       {incr i; set file       [lindex $args $i]}
            -copy_to    {incr i; set copy_to    [lindex $args $i]}
        }
    }
    # Verify that only a single file is provided
    if {[llength $file] != 1} {error "ERROR: \[add_changelog\] Option -file must define a single file path."}

    # Copy files if needed
    if {[info exists copy_to]} {
        file mkdir [set copyToDir [file normalize [path_relative_to_pwd $copy_to]]]
        file copy -force [path_relative_to_pwd $file] $copyToDir
        set file [file join $copyToDir [file tail $file]]
    }

    # Verify file type support
    switch -glob -- $file {
        *.txt       - *.md      {set type "text"}
        default                 {error "ERROR: \[add_changelog\] File type not allowed. Supported file extensions are txt and md."}
    }

    # Add file to IPI file sets
    set fileGroup [ipx::add_file_group -type "version_info" "xilinx_versioninformation" [ipx::current_core]]
    set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
    set_property type $type $addedFile
}

# Software Driver Files ---------------------------------------------------------------------------

proc ::xtools::ip_packager::add_software_driver {args} {
    # Summary: Add software driver template and custom src-files to the packaged IP-core.

    # Argument Usage:
    # -driver_dir <arg>:            Output directory path for software-driver. Existing src-files (e.g. *.h or *.c) needs to be locaded inside the "src" subfolder and are added automatically.
    # [-copy_to <arg>]:             Path to folder, where to copy/import the added softwar driver sources.
    # [-parameters <arg>]:          Add a list of IP parameters which values are exported to the xparameters.h file.
    # [-driver_name <arg>]:         Optionally, overwrite default driver name (default = <IP-Name>).
    # [-driver_version <arg>]:      Optionally, overwrite default driver version (default = 1.0).
    # [-driver_description <arg>]:  Optionally, overwrite default driver description (default = "<IP-Name> specific driver").

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable Home
    variable RootDir
    variable SwDriverTclFile

    # Define default values for procedure arguments
    set ipName              [get_property name [ipx::current_core]]
    set parameters          ""
    set driver_name         $ipName
    set driver_version      1.0
    set driver_description  "\"${ipName} specific driver.\""

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -driver_dir             {incr i; set driver_dir         [lindex $args $i]}
            -copy_to                {incr i; set copy_to            [lindex $args $i]}
            -parameters             {incr i; set parameters         [lindex $args $i]}
            -driver_name            {incr i; set driver_name        [lindex $args $i]}
            -driver_version         {incr i; set driver_version     [lindex $args $i]}
            -driver_description     {incr i; set driver_description [lindex $args $i]}
        }
    }

    # Verify that only a single directory is provided
    if {[llength $driver_dir] != 1 || ![string match [file type [path_relative_to_pwd $driver_dir]] "directory"]} {error "ERROR: \[add_bd_tcl\] Option -driver_dir must define a single directory path."}

    # Copy files if needed
    if {[info exists copy_to]} {
        file mkdir [set copyToDir [file normalize [path_relative_to_pwd $copy_to]]]
        set driverDirPaths [glob -directory [path_relative_to_pwd $driver_dir] *]
        file copy -force {*}$driverDirPaths $copyToDir
        set driver_dir $copyToDir
    }
    # Create required driver folder structure
    set driver_dir [path_relative_to_pwd $driver_dir]
    file mkdir [file join $driver_dir $driver_name "data"]
    file mkdir [file join $driver_dir $driver_name "src"]
    file mkdir [file join $driver_dir $driver_name "doc"]
    file mkdir [file join $driver_dir $driver_name "examples"]

    # Makefile Snipped
    set replaceTags [dict create "<IP_NAME>" $ipName]
    copy_and_replace_tags [file join $Home "snippets" "driver" "Makefile"] [file join $driver_dir $driver_name "src" "Makefile"] $replaceTags

    # .MDD File Snipped
    set replaceTags [dict create "<IP_NAME>" $ipName "<DRIVER_NAME>" $driver_name "<DRIVER_VERSION>" $driver_version "<DRIVER_DESCRIPTION>" $driver_description]
    copy_and_replace_tags [file join $Home "snippets" "driver" "snippet.mdd"] [file join $driver_dir $driver_name "data" "${driver_name}.mdd"] $replaceTags

    # .TCL File Snipped
    set paramList ""
    foreach param $parameters {
        set paramList "${paramList} \"${param}\""
    }
    set paramList [string trim $paramList]
    set replaceTags [dict create "<DRIVER_NAME>" $driver_name "<PARAM_LIST>" $paramList]
    copy_and_replace_tags [file join $Home "snippets" "driver" "snippet.tcl"] [file join $driver_dir $driver_name "data" "${driver_name}.tcl"] $replaceTags
    # Store current SwDriverTclFile globally to later be able to add information
    set SwDriverTclFile [file join $driver_dir $driver_name "data" "${driver_name}.tcl"]
    
    # Add files to IPI file sets
    set fileGroup  [ipx::add_file_group -type "software_driver" "xilinx_softwaredriver" [ipx::current_core]]
    set driverSrcFilePaths     [glob -directory [file join $driver_dir $driver_name "src"]  -type f *]
    set driverDataFilePaths    [glob -directory [file join $driver_dir $driver_name "data"] -type f *]
    foreach file [list {*}$driverSrcFilePaths {*}$driverDataFilePaths] {
        set addedFile [ipx::add_file [path_relative_to_root [file normalize $file]] $fileGroup]
    }
}

# Advanced Scripting Files ------------------------------------------------------------------------

proc ::xtools::ip_packager::add_utility_scripts {args} {
    # Summary: Add utility scripts to the packaged IP-core.

    # Argument Usage:
    # -files <arg>:     List of utility script file-paths to be added to the packaged IP-core.
    # [-copy_to <arg>]: Path to folder, where to copy/import the added utility scripts. Supported file extensions are xit, gtcl, tcl and ttcl.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -files      {incr i; set files     [lindex $args $i]}
            -copy_to    {incr i; set copy_to   [lindex $args $i]}
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

    # Verify file type support
    foreach file $files {
        switch -glob -- $file {
            *.xit   {set type "xit"}
            *.gtcl  {set type "GTCL"}
            *.tcl   {set type "tclSource"}
            *.ttcl  {set type "ttcl"}
            default {error "ERROR: \[add_utility_scripts\] File type not allowed (${file}). Supported file extensions are xit, gtcl, tcl and ttcl."}
        }
    }

    # Add file to IPI file sets
    set fileGroup [ipx::add_file_group -type "utility" "xilinx_utilityxitfiles" [ipx::current_core]]
    foreach file $files {
        set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
        set_property type $type $addedFile
    }
}

proc ::xtools::ip_packager::create_upgrade_tcl_template {} {
    # Summary: Not implemented!

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    #TODO: create_upgrade_tcl_template
    error "ERROR: \[create_upgrade_tcl_template\] This function is not implemented yet."
}

proc ::xtools::ip_packager::add_upgrade_tcl {args} {
    # Summary: Add IP upgrade TCL scripts to the packaged IP-core.

    # Argument Usage:
    # -files <arg>:         List of IP upgrade TCL script file-paths.
    # [-copy_to <arg>]:     Path to folder, where to copy/import the added upgrade scripts.
    # [-versions <arg>]:    List of handled/upgradable IP-core versions.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -files      {incr i; set files      [lindex $args $i]}
            -copy_to    {incr i; set copy_to    [lindex $args $i]}
            -versions   {incr i; set versions   [lindex $args $i]}
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

    # Verify file type support
    foreach file $files {
        switch -glob -- $file {
            *.tcl   {set type "tclSource"}
            default {error "ERROR: \[add_upgrade_tcl\] File type not allowed (${file}). Supported file extention is tcl."}
        }
    }

    # Add file to IPI file sets
    set fileGroup  [ipx::add_file_group -type "upgrade_script" "xilinx_upgradescripts" [ipx::current_core]]
    foreach file $files {
        set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
        set_property type $type $addedFile
    }
    set_property PREVIOUS_VERSION_FOR_UPGRADE $versions [ipx::current_core]
}

proc ::xtools::ip_packager::create_bd_tcl_template {} {
    # Summary: Not implemented!

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    #TODO: create_bd_tcl_template
    error "ERROR: \[create_bd_tcl_template\] This function is not implemented yet."
}

proc ::xtools::ip_packager::add_bd_tcl {args} {
    # Summary: Add IP BD-TCL scripts to the packaged IP-core.

    # Argument Usage:
    # -file <arg>:          BD-TCL script file-path.
    # [-copy_to <arg>]:     Path to folder, where to copy/import the added BD-TCL script.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -file       {incr i; set file       [lindex $args $i]}
            -copy_to    {incr i; set copy_to    [lindex $args $i]}
        }
    }

    # Verify that only a single file is provided
    if {[llength $file] != 1} {error "ERROR: \[add_bd_tcl\] Option -file must define a single file path."}

    # Copy files if needed
    if {[info exists copy_to]} {
        file mkdir [set copyToDir [file normalize [path_relative_to_pwd $copy_to]]]
        file copy -force [path_relative_to_pwd $file] $copyToDir
        set file [file join $copyToDir [file tail $file]]
    }

    # Verify file type support
    switch -glob -- $file {
        *.tcl   {set type "tclSource"}
        default {error "ERROR: \[add_bd_tcl\] File type not allowed. Supported file extention is tcl."}
    }

    # Add file to IPI file sets
    set fileGroup [ipx::add_file_group -type "blockdiagram" "xilinx_blockdiagram" [ipx::current_core]]
    set addedFile [ipx::add_file [path_relative_to_root $file] $fileGroup]
    set_property type $type $addedFile
}

proc ::xtools::ip_packager::add_gui_support_tcl {args} {
    # Summary:  Add GUI Support TCL scripts to the packaged IP-core. They might provide implemented procedures to calculate complex value dependencies for parameters.

    # Argument Usage:
    # -files <arg>:         List of file paths to GUI support TCLs.
    # [-copy_to <arg>]:     Path to folder, where to copy/import the added GUI support TCL scripts.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable GuiSupportTcl
    variable RootDir

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -files      {incr i; set files      [lindex $args $i]}
            -copy_to    {incr i; set copy_to    [lindex $args $i]}
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

    # Add files to XIT/Utility fileset
    add_utility_scripts -files $files

    # Make GUI support procedures available to current Vivado instance.
	foreach file $files {
		set ::gui_support_tcl [file join $RootDir $file]
		namespace eval "::" {
			source $gui_support_tcl
		}
	}

    # Store paths for later processing (see save_package_project)
    lappend GuiSupportTcl {*}$files

}

###################################################################################################
# EOF
###################################################################################################
