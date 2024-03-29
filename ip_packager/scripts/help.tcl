###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# Show IP-Packager help overview
###################################################################################################

set this_file_path                      [file normalize [file dirname [info script]]];  # help.tcl directory.
set pkg_path                            [file join $this_file_path "../../.."];         # path to directory in which folder "xtools" is located.
lappend auto_path                       [file join $pkg_path "xtools"]
::tclapp::support::appinit::load_app    ${pkg_path} "::xtools::ip_packager" "ip_packager"
::rdi::set_help_config                  -expose_namespace "ip_packager"

puts "========================================================================================================================================================="
puts [help ip_packager]
puts "========================================================================================================================================================="
puts "Type \"ip_packager::<any-command> -help\" to see detailed description of a command."
puts "========================================================================================================================================================"

###################################################################################################
# EOF
###################################################################################################
