namespace eval IpPackager_2020_1_tb_v1_0_utils {
    proc warning_for_upgrade_from_IpPackager_2020_1_tb_v0_1 {} {

        return "### procedure warning_for_upgrade_from_IpPackager_2020_1_tb called ###\nUser need to make sure about the updates in the parameters while upgrading to the new version."
    }

    proc upgrade_from_IpPackager_2020_1_tb_v0_1 {xciValues} {

        namespace import ::xcoUpgradeLib::*
        upvar $xciValues valueArray

        puts "### procedure upgrade_from_IpPackager_2020_1_tb called ###"

        return
    }
}

set currentNamespace [namespace current]
puts "DEBUG: ip_upgrade.tcl sourced now  into namespace ${currentNamespace}"