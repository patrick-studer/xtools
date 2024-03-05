# PsiIpPackage Relations Overview

This document shows what PsiIpPackage functions are related to which ip_packager functions.

Also check [Migration Guide](./PsiIpPackage_MigrationGuide.md) for 1:1 mapping of PsiIpPackage functions to ip_packager functions.

### Argument Notation
- `<arg>`: Required argument
- `[<arg>=<default>]`: Optional argument with default value
- `-<option> <arg>`: Required option-flag and parameter pair
- `[-<option> <arg>]`: Optional option-flag and parameter pair

**Note:** option-flag and parameter must always occur in pairs. Their position in the function call is variable, since all options are parsed. Only provided options have impact and are applied, others are ignored or a default value is assumed.

## Project Control

### PsiIpPackage

* `set_top_entity <name>`
* `remove_autodetected_interface [<name>="ALL"]`
* `set_target_language <lang>`
* `package_ip <tgtDir> [<edit>=false] [<synth>=false] [<part>=""]`

### ip_packager

* `create_package_project -top_file <arg> [-root_dir <arg>] [-prj_name <arg>] [-part <arg>]`
* `simulate_package_project [-generics <arg>] [-timeout <arg>]`
* `synth_package_project [-part <arg>] [-jobs <arg>]`
* `impl_package_project [-part <arg>] [-jobs <arg>] [-timeout <arg>]`
* `save_package_project`
* `close_package_project [-delete <arg>]`

## Identification

### PsiIpPackage

* `init <name> <version> <revision> <library>`
* `set_description <desc>`
* `set_vendor <vendor>`
* `set_vendor_short <vendor>`
* `set_vendor_url <url>`
* `set_taxonomy <taxonomy>`

### ip_packager

* `set_identification [-vendor <arg>] [-library <arg>] [-name <arg>] [-version <arg>] [-core_revision <arg>] [-display_name <arg>] [-description <arg>] [-display_vendor <arg>] [-company_url <arg>] [-taxonomy <arg>]`

## Compatibility

### PsiIpPackage

Not available.

### ip_packager

* `set_auto_family_support <level_str>`
* `set_supported_families <families_lifecycle_pairs>`
* `set_unsupported_simulators <simulators>`

## File Groups

### PsiIpPackage

* `add_sources_relative <srcs> [<lib>="NONE"] [<type>="NONE"] [<fileset>="sources_1"]`
* `add_lib_relative <libPath> <files> [<lib>="NONE"] [<type>="NONE"] [<fileset>="sources_1"]`
* `add_lib_copied <tgtPath> <libPath> <files> [<lib>="NONE"] [<type>="NONE"] [<fileset>="sources_1"]`
* `set_constrs_settings <names> <used_in> [<processing_order>="NORMAL"] [<scoped_to_cells>=""]`
* `add_sub_core_reference <cores>`
* `set_logo_relative <logo>`
* `set_datasheet_relative <datasheet>`
* `add_ttcl_vhd <files> [<lib>="NONE"]`
* `add_gui_support_tcl <script>`
* `add_drivers_relative <dir> <files>`
* `add_xparameters_entry <parameter>`
* `remove_file_from_ip <path>`

### ip_packager

* `add_design_sources -files <arg> [-copy_to <arg>] [-library <arg>] [-file_type <arg>] [-global_include <arg>] [-enabled <arg>]`
* `add_design_constraints -files <arg> [-copy_to <arg>] [-used_in <arg>] [-processing_order <arg>] [-scoped_to_cells <arg>] [-quiet] [-verbose]`
* `add_design_simulation -files <arg> [-copy_to <arg>] [-library <arg>] [-file_type <arg>] [-global_include <arg>] [-enabled <arg>]`
* `add_design_subcores -vlnv <arg>`
* `add_exdes_sources -files <arg> [-library <arg>] [-file_type <arg>]`
* `add_exdes_constraints -files <arg>`
* `add_exdes_simulation -files <arg> [-library <arg>] [-file_type <arg>]`
* `add_exdes_subcores -vlnv <arg>`
* `add_exdes_script -files <arg>`
* `add_logo <logo>`
* `add_product_guide <guide>`
* `add_changelog <changelog>`
* `add_readme <readme>`
* `add_gui_support_tcl <tcl_scripts>`
* `add_bd_tcl <bd_script>`
* `add_upgrade_tcl <upgrade_script>`
* `add_utility_scripts <utility_script>`
* `add_software_driver -driver_dir <arg> [-parameters <arg>] [-driver_name <arg>] [-driver_version <arg>] [-driver_description <arg>] [-quiet] [-verbose]`

## Customization Paramenters

### PsiIpPackage

* `gui_create_user_parameter <paramName> <type> <initialValue> [<displayName>="None"]`
* `gui_create_parameter <vhdlName> <displayName>`
* `gui_parameter_set_range <min> <max>`
* `gui_parameter_set_widget_dropdown_list <values>`
* `gui_parameter_set_widget_dropdown <values>`
* `gui_parameter_set_widget_dropdown_pairs <pairs>`
* `gui_parameter_set_widget_checkbox`
* `gui_parameter_set_expression <expression>`
* `gui_parameter_set_enablement <expression> <default>`

### ip_packager

* `create_user_param -param_name <arg> [-format <arg>] [-bit_string_length <arg>] [-value <arg>] [-value_tcl_expr <arg>] [-validation_range <arg>] [-validation_list <arg>] [-validation_pairs <arg>] [-enablement_tcl_expr <arg>] [-quiet] [-verbose]`
* `set_param_config -param_name <arg> [-value <arg>] [-value_tcl_expr <arg>] [-validation_range <arg>] [-validation_list <arg>] [-validation_pairs <arg>] [-enablement_tcl_expr <arg>]`

## Ports and Interfaces

### PsiIpPackage

* `import_interface_definition <srcPath> <defNames>`
* `add_bus_interface <definition> <name> <mode> <description> <port_maps>`
* `set_interface_mode <interface> <mode>`
* `add_clock_in_interface <portname> [<freq_hz>="None"]`
* `add_reset_in_interface <portname> [<polarity>="positive"]`
* `add_clock_out_interface <portname> [<freq_hz>="None"]`
* `add_reset_out_interface <portname> [<polarity>="positive"]`
* `add_interrupt_out_interface <portname> [<sensitivity>="LEVEL_HIGH"]`
* `set_interface_clock <interfaces> <clock>`
* `add_interface_enablement_condition <interface> <condition>`
* `add_port_enablement_condition <port> <condition>`

### ip_packager

* `import_bus_definition <definition>`
* `add_bus_interface -interface_name <arg> -vlnv <arg> -interface_mode <arg> -port_map <arg> [-bus_params <arg>] [-clock <arg>] [-reset <arg>]`
* `auto_infer_interface -interface_name <arg> -vlnv <arg> [-port_pattern <arg>] [-bus_params <arg>]`
* `add_axi_interface -interface_name <arg> [-port_pattern <arg>] [-bus_params <arg>]`
* `add_axis_interface -interface_name <arg> [-port_pattern <arg>] [-bus_params <arg>]`
* `add_clock_interface -interface_name <arg> [-freq_hz <arg>] [-bus_params <arg>]`
* `add_clockenable_interface -interface_name <arg>  [-bus_params <arg>]`
* `add_data_interface -interface_name <arg> [-bus_params <arg>]`
* `add_interrupt_interface -interface_name <arg> [-sensitivity <arg>] [-bus_params <arg>]`
* `add_reset_interface -interface_name <arg> [-polarity <arg>] [-bus_params <arg>]`
* `associate_interface_clock -interface_name <arg> -clock <arg>`
* `associate_clock_reset -interface_name <arg> -reset <arg> [-quiet] [-verbose]`
* `set_interface_enablement -interface_name <arg> -dependency <arg>`
* `set_port_enablement -port_name <arg> -dependency <arg> [-driver_value <arg>]`

## Adressing and Memory

### PsiIpPackage

Not available.

### ip_packager

Not available.

## Customization GUI

### PsiIpPackage

* `gui_add_page <name>`
* `gui_add_group <name>`
* `gui_exit_group`
* `gui_add_parameter`
* `gui_parameter_set_tooltip <tooltip>`
* `gui_parameter_text_below <text>`

### ip_packager

* `gui_set_parent [<parent_name>]`
* `gui_add_page -page_name <arg> -display_name <arg> [-tooltip <arg>] [-layout <arg>] [-parent <arg>]`
* `gui_add_group -group_name <arg> -display_name <arg> [-parent <arg>] [-tooltip <arg>] [-layout <arg>]`
* `gui_add_param -param_name <arg> -display_name <arg> [-parent <arg>] [-tooltip <arg>] [-layout <arg>] [-widget <arg>] [-show_label <arg>] [-show_range <arg>]`
* `gui_add_text -text_name <arg> -text <arg> [-parent <arg>] [-tooltip <arg>]`
