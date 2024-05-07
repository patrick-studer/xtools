###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# IP Packager - GUI
###################################################################################################

namespace eval ::xtools::ip_packager {
    # Export procs that should be allowed to import into other namespaces
    namespace export    gui_add_page \
                        gui_add_group \
                        gui_add_param \
                        gui_add_text \
                        gui_set_parent
}

###################################################################################################
# GUI Procedures
###################################################################################################

proc ::xtools::ip_packager::gui_add_page {args} {
    # Summary: Add new page to configuration GUI.

    # Argument Usage:
    # -page_name <arg>:             GUI page identifier/name
    # -display_name <arg>:          Display name
    # [-tooltip <arg>]:             Tooltip (on hoover)
    # [-layout <arg> = vertical]:   Page layout (e.g. horizontal or vertical)
    # [-parent <arg>]:              New GUI page's parent (default = current GUI page or group). Define name of GUI page or group to change current element's parent.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable CurrentGuiParent

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -page_name      {incr i; set page_name    [lindex $args $i]}
            -display_name   {incr i; set display_name [lindex $args $i]}
            -tooltip        {incr i; set tooltip      [lindex $args $i]}
            -layout         {incr i; set layout       [lindex $args $i]}
            -parent         {incr i; set parent       [lindex $args $i]}
        }
    }

    # Add new page to IP GUI
    if {[info exists parent]} {
        set CurrentGuiParent [gui_set_parent $parent]
    }
    set CurrentGuiPage [ipgui::add_page -name $page_name -component [ipx::current_core] -parent $CurrentGuiParent]
    if {[info exists display_name]} {set_property display_name $display_name $CurrentGuiPage}
    if {[info exists tooltip]}      {set_property tooltip $tooltip $CurrentGuiPage}
    if {[info exists layout ]}      {set_property layout  $layout  $CurrentGuiPage}
    set CurrentGuiParent $CurrentGuiPage
}

proc ::xtools::ip_packager::gui_add_group {args} {
    # Summary: Add new group to configuration GUI.

    # Argument Usage:
    # -group_name <arg>:            GUI group identifier/name
    # -display_name <arg>:          Display name
    # [-parent <arg>]:              New GUI group's parent (default = current GUI page or group). Define name of GUI page or group to change current element's parent.
    # [-tooltip <arg>]:             Tooltip (on hoover)
    # [-layout <arg> = vertical]:   Group layout (e.g. horizontal or vertical)

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable CurrentGuiParent

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -group_name     {incr i; set group_name   [lindex $args $i]}
            -display_name   {incr i; set display_name [lindex $args $i]}
            -parent         {incr i; set parent       [lindex $args $i]}
            -tooltip        {incr i; set tooltip      [lindex $args $i]}
            -layout         {incr i; set layout       [lindex $args $i]}
        }
    }

    # Add new group to IP GUI
    if {[info exists parent]} {
        set CurrentGuiParent [gui_set_parent $parent]
    }
    set CurrentGuiGroup [ipgui::add_group -name $group_name -component [ipx::current_core] -parent $CurrentGuiParent]
    if {[info exists display_name]} {set_property display_name $display_name $CurrentGuiGroup}
    if {[info exists tooltip     ]} {set_property tooltip      $tooltip      $CurrentGuiGroup}
    if {[info exists layout      ]} {set_property layout       $layout       $CurrentGuiGroup}
    set CurrentGuiParent $CurrentGuiGroup
}

proc ::xtools::ip_packager::gui_add_param {args} {
    # Summary: Add existing MODELPARAM (generic) or user parameter to configuration GUI.

    # Argument Usage:
    # -param_name <arg>:            GUI parameter identifier/name
    # -display_name <arg>:          Display name
    # [-parent <arg>]:              New GUI group's parent (default = current GUI page or group). Define name of GUI page or group to change current element's parent.
    # [-tooltip <arg>]:             Tooltip (on hoover)
    # [-layout <arg> = vertical]:   Group layout (e.g. horizontal or vertical)
    # [-widget <arg>]:              Parameter widget (e.g. radioGroup, textEdit, checkBox or comboBox)
    # [-show_label <arg> = true]:   Boolean to hide -display_name string
    # [-show_range <arg> = true]:   Boolean to hide -validation_range

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable CurrentGuiParent

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -param_name     {incr i; set param_name   [lindex $args $i]}
            -display_name   {incr i; set display_name [lindex $args $i]}
            -parent         {incr i; set parent       [lindex $args $i]}
            -tooltip        {incr i; set tooltip      [lindex $args $i]}
            -layout         {incr i; set layout       [lindex $args $i]}
            -widget         {incr i; set widget       [lindex $args $i]}
            -show_label     {incr i; set show_label   [lindex $args $i]}
            -show_range     {incr i; set show_range   [lindex $args $i]}
        }
    }

    # Add existing IP parameter to IP GUI
    if {[info exists parent]} {
        set CurrentGuiParent [gui_set_parent $parent]
    }
    set CurrentGuiParam [ipgui::add_param -name $param_name -component [ipx::current_core] -parent $CurrentGuiParent]
    if {[info exists display_name]} {set_property display_name $display_name $CurrentGuiParam}
    if {[info exists tooltip     ]} {set_property tooltip      $tooltip      $CurrentGuiParam}
    if {[info exists layout      ]} {set_property layout       $layout       $CurrentGuiParam}
    if {[info exists widget      ]} {set_property widget       $widget       $CurrentGuiParam}
    if {[info exists show_label  ]} {set_property show_label   $show_label   $CurrentGuiParam}
    if {[info exists show_range  ]} {set_property show_range   $show_range   $CurrentGuiParam}
}

proc ::xtools::ip_packager::gui_add_text {args} {
    # Summary: Add static text below to configuration GUI.

    # Argument Usage:
    # -text_name <arg>:     GUI text identifier/name
    # -text <arg>:          Static text string
    # [-parent <arg>]:      New GUI group's parent (default = current GUI page or group). Define name of GUI page or group to change current element's parent.
    # [-tooltip <arg>]:     Tooltip (on hoover)

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable CurrentGuiParent

    # Parse optional arguments
    set num [llength $args]
    for {set i 0} {$i < $num} {incr i} {
        switch -exact -- [set option [string trim [lindex $args $i]]] {
            -text_name  {incr i; set text_name [lindex $args $i]}
            -text       {incr i; set text      [lindex $args $i]}
            -parent     {incr i; set parent    [lindex $args $i]}
            -tooltip    {incr i; set tooltip   [lindex $args $i]}
        }
    }

    # Add new text to IP GUI
    if {[info exists parent]} {
        set CurrentGuiParent [gui_set_parent $parent]
    }
    set CurrentGuiText [ipgui::add_static_text -name $text_name -component [ipx::current_core] -parent $CurrentGuiParent -text $text]
    if {[info exists tooltip]} {set_property tooltip $tooltip $CurrentGuiText}
}

proc ::xtools::ip_packager::gui_set_parent {{parent_name "root"}} {
    # Summary: Change current GUI parent. This will define the canvas to which the next parameter/group/page/text will be added.

    # Argument Usage:
    # [parent_name = root]:     GUI parent identifier/name. Use "root" to define the main window.

    # Return Value: TCL_OK

    # Categories: xilinxtclstore, ip_packager

    # Load global variables
    variable CurrentGuiParent

    # Define new parent container to place new components on the IP GUI
    if {[string match -nocase "root" $parent_name]} {
        set CurrentGuiParent nullptr
    } else {
        set CurrentGuiParent [ipgui::get_groupspec -name $parent_name -component [ipx::current_core] -quiet]
        if {$CurrentGuiParent == ""} {
            set CurrentGuiParent [ipgui::get_pagespec -name $parent_name -component [ipx::current_core] -quiet]
        }
    }
    if {$CurrentGuiParent == ""} {
        error "ERROR: \[gui_set_parent\] does not find a group/page named ${parent_name}."
    }
}

###################################################################################################
# EOF
###################################################################################################
