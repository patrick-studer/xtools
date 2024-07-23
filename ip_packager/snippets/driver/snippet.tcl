###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

proc generate {drv_handle} {

    ::hsi::utils::define_include_file    $drv_handle "xparameters.h" \
        <DRIVER_NAME> \
        "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" \
        <PARAM_LIST>

    ::hsi::utils::define_config_file     $drv_handle "<DRIVER_NAME>_g.c" \
        <DRIVER_NAME> \
        "DEVICE_ID" "C_BASEADDR" \
        <PARAM_LIST>

    ::hsi::utils::define_canonical_xpars $drv_handle "xparameters.h" \
        <DRIVER_NAME> \
        "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" \
        <PARAM_LIST>

}

###################################################################################################
# EOF
###################################################################################################
