###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

proc generate {drv_handle} {
    set ip [get_cells -hier $drv_handle]
    set vendor    [get_property VLNV_VENDOR  $ip]
    set ip_name   [get_property IP_NAME      $ip]
    set version   [get_property VLNV_VERSION $ip]
    set inst_name [get_property NAME         $ip]

    set comp_string "$vendor,$ip_name-$version"
    hsi::utils::add_new_property $drv_handle "compatible" "stringlist" [list $comp_string "generic-uio"]
    hsi::utils::add_new_property $drv_handle "linux,uio-name" "string" $inst_name

    set params [list <PARAM_LIST>]
    foreach param $params {
        set config_name "CONFIG.$param"
        set val [get_property $config_name $ip]
        if { $val != "" } {
            set dt_name [format_dt_name $param]
            if { [string is integer -strict $val] } {
                hsi::utils::add_new_property $drv_handle $dt_name "int" $val
            } else {
                hsi::utils::add_new_property $drv_handle $dt_name "string" $val
            }
        }
    }
}

proc format_dt_name {name} {
    set result [string tolower [regsub -all {([A-Z])} $name {-\1}]]
    set result [string trimleft $result "-"]
    return [regsub -all {_} $result "-"]
}

###################################################################################################
# EOF
###################################################################################################
