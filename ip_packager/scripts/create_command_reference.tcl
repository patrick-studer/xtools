###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# Create IP-Packager command reference
###################################################################################################

set this_file_path                      [file normalize [file dirname [info script]]];
set cmd_ref_path                        [file join $this_file_path "../doc/CommandReference.txt"]
set pkg_path                            [file join $this_file_path "../../.."];
lappend auto_path                       [file join $pkg_path "xtools"]
::tclapp::support::appinit::load_app    $pkg_path "::xtools::ip_packager" "ip_packager"
::rdi::set_help_config                  -expose_namespace "ip_packager"

set f [open $cmd_ref_path "w"]

puts $f "==================================================================================================="
puts $f "= Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)"
puts $f "==================================================================================================="
puts $f ""
puts $f "==================================================================================================="
puts $f "= Overview"
puts $f "==================================================================================================="
puts $f [help ip_packager]
puts $f "NOTE: Type \"ip_packager::<any-command> -help\" to see detailed description of a command."
puts $f ""
puts $f "==================================================================================================="
puts $f ""
puts $f "==================================================================================================="
puts $f "= Detailed Command Reference"
puts $f "==================================================================================================="
puts $f ""
foreach command [lsort -dictionary [info commands ip_packager::*]] {
    puts $f [help $command]
    puts $f "==================================================================================================="
    puts $f ""
}

close $f

###################################################################################################
# EOF
###################################################################################################
