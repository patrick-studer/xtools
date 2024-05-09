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
          error "ERROR: \[path_relative_to\] ${toFile} not on same volume as ${fromDir}!"
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
    puts "INFO: \[copy_and_replace_tags\] Replace following tags in file ${to_path}:"
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

###################################################################################################
# EOF
###################################################################################################
