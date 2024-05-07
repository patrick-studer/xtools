###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

proc generate {drv_handle} {
    ::hsi::utils::define_include_file    $drv_handle "xparameters.h"
        IpPackager_2020_1
        "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR"

    ::hsi::utils::define_config_file     $drv_handle "IpPackager_2020_1_g.c"
        IpPackager_2020_1
        "DEVICE_ID" "C_BASEADDR"

    ::hsi::utils::define_canonical_xpars $drv_handle "xparameters.h"
        IpPackager_2020_1
        "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR"

}

###################################################################################################
# EOF
###################################################################################################
