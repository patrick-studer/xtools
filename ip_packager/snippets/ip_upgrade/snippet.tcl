namespace eval <IP_NAME>_<IP_VERSION>_utils {
    proc warning_for_upgrade_from_<IP_NAME>_<OLD_IP_VERSION> {} {

        return "### procedure warning_for_upgrade_from_<IP_NAME>_<OLD_IP_VERSION> called ###"
    }

    proc upgrade_from_IpPackage_<IP_NAME>_<OLD_IP_VERSION> {xciValues} {

        namespace import ::xcoUpgradeLib::*
        upvar $xciValues valueArray

        puts "### procedure upgrade_from_<IP_NAME>_<OLD_IP_VERSION> called ###"

        return
    }
}