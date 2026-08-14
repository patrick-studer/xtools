###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager - Utils
###################################################################################################

namespace eval ::xtools::ip_packager {
    # namespace export ""
}

###################################################################################################
# Utility Procedures
###################################################################################################

proc ::xtools::ip_packager::path_relative_to {from_dir to_files {to_files_prefix ""}} {
    # Summary: Get relative to "fromDir" paths pointing to "toFiles".

    # Argument Usage:
    # from_dir: 			    Directory the path should be relative to.
    # to_files:			        List of files the relative paths point to.
    # [to_files_prefix = ""]:   Path prefix to add to every to_files.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    variable returnFilesParts [list]
    foreach toFile $to_files {
        if {[file pathtype $toFile] == "relative"} {
            set toFile [file join $to_files_prefix $toFile]
        }
        set fromDirParts [file split [file normalize $from_dir]]
        set toFileParts  [file split [file normalize $toFile]]
        if {![string equal [lindex $fromDirParts 0] [lindex $toFileParts 0]]} {
          # not on *n*x then
          send_msg_id {XTOOLS 1-900} "ERROR" "\[path_relative_to\] ${toFile} not on same volume as ${fromDir}!"
        }
        while {[string equal [lindex $fromDirParts 0] [lindex $toFileParts 0]] && [llength $fromDirParts] > 0} {
          # discard matching components from the front
          set fromDirParts [lreplace $fromDirParts 0 0]
          set toFileParts  [lreplace $toFileParts  0 0]
        }
        # step up the tree
        set prefix ""
        for {set i 0} {$i < [llength $fromDirParts]} {incr i} {
          append prefix " .."
        }
        # stick it all together
        lappend returnFilesParts [eval file join $prefix $toFileParts]
    }
    return $returnFilesParts
}

proc ::xtools::ip_packager::path_relative_to_pwd {to_files} {
    # Summary: Get relative paths from current working directory pointing to "toFiles".

    # Argument Usage:
    # to_files:			List of files the relative paths point to.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    variable RootDir
    return [path_relative_to [pwd] $to_files $RootDir]
}

proc ::xtools::ip_packager::path_relative_to_root {to_files} {
    # Summary: Get relative paths from IP root directory pointing to "toFiles".

    # Argument Usage:
    # to_files:			List of files the relative paths point to.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    variable RootDir
    return [path_relative_to $RootDir $to_files $RootDir]
}

proc ::xtools::ip_packager::copy_and_replace_tags {from_path to_path tags} {
    # Summary: Copy a template file and replace one or more tags within this file.

    # Argument Usage:
    # from_path:		Source path of the file (template).
    # to_path:	        Destination path to write the modified file to.
    # tags:			    A dictonary containing tags as keys and their replacements as values.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # read file
    set fp [open $from_path "r"]
    set content [read $fp]
    close $fp

    # replace tags
    send_msg_id {XTOOLS 1-901} "INFO" "\[copy_and_replace_tags\] Replace following tags in file ${to_path}:"
    foreach item [dict keys $tags] {
        set val [dict get $tags $item]
        set content [regsub -all $item $content $val]
        puts "      - ${item} <= ${val}"
    }

    # write file
    set fp [open $to_path "w"]
    puts -nonewline $fp $content
    close $fp
}

proc ::xtools::ip_packager::replace_tags {path tags} {
    # Summary: Replace one or more tags within a file.

    # Argument Usage:
    # path:	            Path to original file.
    # tags:			    A dictonary containing tags as keys and their replacements as values.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # read file
    set fp [open $path "r"]
    set content [read $fp]
    close $fp

    # replace tags
    send_msg_id {XTOOLS 1-902} "INFO" "\[replace_tags\] Replace following tags in file ${path}:"
    foreach item [dict keys $tags] {
        set val [dict get $tags $item]
        set content [regsub -all $item $content $val]
        puts "      - ${item} <= ${val}"
    }
    
    # write file
    set fp [open $path "w"]
    puts -nonewline $fp $content
    close $fp
}

proc ::xtools::ip_packager::_reorder_ipx_file_group {} {
    # Summary: Reorder ipx-files according to compile-order.

    # Argument Usage:

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager
    

    # Sorting constraints/sources used for Synthesis
    set fileGroup [ipx::get_file_groups "xilinx_anylanguagesynthesis" -of_objects [ipx::current_core]]
    set compileOrderConstraints [path_relative_to_root [get_files -compile_order "constraints" -used_in "synthesis"]]
    set compileOrderSources     [path_relative_to_root [get_files -compile_order "sources"     -used_in "synthesis"]]
    ipx::reorder_files -back $compileOrderConstraints $fileGroup -quiet
    ipx::reorder_files -back $compileOrderSources     $fileGroup -quiet

    # Sorting sources used for Simulation
    set fileGroup [ipx::get_file_groups "xilinx_anylanguagebehavioralsimulation" -of_objects [ipx::current_core]]
    set compileOrderSources     [path_relative_to_root [get_files -compile_order "sources"     -used_in "simulation"]]
    ipx::reorder_files -back $compileOrderSources     $fileGroup -quiet

    # Sorting constraints/sources used for Implementation
    set fileGroup [ipx::get_file_groups "xilinx_implementation" -of_objects [ipx::current_core]]
    set compileOrderConstraints [path_relative_to_root [get_files -compile_order "constraints" -used_in "implementation"]]
    ipx::reorder_files -back $compileOrderConstraints $fileGroup -quiet
}

proc ::xtools::ip_packager::_print_ipx_files {msg_lines} {
    # Summary: Create printable IPX FileGroup/Files string.

    # Argument Usage:
    # msg_lines:        Initial Message lines (header).

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager
    
    # Convert all IPI file paths to relative (except URLs => type=unknown)
    foreach fileGroup [ipx::get_file_groups * -of_objects [ipx::current_core]] {
        append msg_lines "\n- [get_property name ${fileGroup}]:"
        foreach file [ipx::get_files -of_objects $fileGroup] {
            append msg_lines "\n  - [get_property name ${file}]"
        }
    }
    return $msg_lines
}

proc ::xtools::ip_packager::find_files_recursive {directory {extension "*"}} {
    # Summary: Finde files with recursive globbing.

    # Argument Usage:
    # directory:      Origin directory from where the search starts.
    # [extension=*]:  File extension for filtering.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager
    set result {}

    foreach path [glob -nocomplain -directory $directory *] {
        if {[file isdirectory $path]} {
            lappend result {*}[find_files_recursive $path $extension]
        } elseif {[file isfile $path] && [string match $extension [file tail $path]]} {
            lappend result $path
        }
    }

    return $result
}

###################################################################################################
# EOF
###################################################################################################
