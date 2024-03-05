# PsiIpPackage Migration Guide

This document shows for every PsiIpPackage function how it may be translated into ip_packager functions.

**Note:** The ip_packager arguments/options are not position-sensitive. You may alternate the order and also combine/split single commands which are applied on the same target.

Check first [Relations Overview](./PsiIpPackage_RelationsOverview.md) to get an overview of related functions from PsiIpPackage and ip_packager.

## Project Control

* `remove_autodetected_interface "ALL"`
  * Automatically applied.
* `set_target_language LANGUAGE`
  * Not supported.
* `set_top_entity TOP_FILE`
* `package_ip ROOT_DIR EDIT SYNTH PART`
  * `create_package_project -top_file TOP_FILE -root_dir ROOT_DIR -part PART`
  * if SYNTH == true:
    * `synth_package_project`
  * if EDIT == false:
    * `save_package_project`
    * `close_package_project`
    
### New ip_packager features

  * `simulate_package_project`
  * `impl_package_project`
  
## Identification

### PsiIpPackage

* `init DISPLAY_NAME VERSION CORE_REVISION LIBRARY`
* `set_description DESCRIPTION`
* `set_vendor VENDOR`
* `set_vendor_short DISPLAY_VENDOR`
* `set_vendor_url COMPANY_URL`
* `set_taxonomy TAXONOMY`
  * `set_identification -vendor VENDOR -library LIBRARY -name [string map {\  _} DISPLAY_NAME] -version VERSION -core_revision CORE_REVISION -display_name DISPLAY_NAME -description DESCRIPTION -display_vendor DISPLAY_VENDOR -company_url COMPANY_URL -taxonomy TAXONOMY`
  
## Compatibility

### New ip_packager features

  * `set_auto_family_support`
  * `set_supported_families`
  * `set_unsupported_simulators`
  
## File Groups

* `set_constrs_settings NAMES USED_IN PROCESSING_ORDER SCOPED_TO_CELLS`
* `add_sources_relative FILES LIBRARY FILE_TYPE FILESET`
  * if FILESET == "sources_1":
    * `add_design_sources -files FILES -library LIBRARY -file_type FILE_TYPE`
  * if FILESET == "constrs_1":
    * `add_design_constraints -files FILES -used_in USED_IN -processing_order PROCESSING_ORDER -scoped_to_cells SCOPED_TO_CELLS`
  * if FILESET == "sim_1":
    * `add_design_simulation -files FILES -library LIBRARY -file_type FILE_TYPE`
    
* `add_lib_relative PATH FILES LIBRARY FILE_TYPE FILESET`
  * if FILESET == "sources_1":
    * `add_design_sources -files PATH/FILES -library LIBRARY -file_type FILE_TYPE`
  * if FILESET == "constrs_1":
    * `add_design_constraints -files PATH/FILES -used_in USED_IN -processing_order PROCESSING_ORDER -scoped_to_cells SCOPED_TO_CELLS`
  * if FILESET == "sim_1":
    * `add_design_simulation -files PATH/FILES -library LIBRARY -file_type FILE_TYPE`
* `add_lib_copied COPY_TO PATH FILES LIBRARY FILE_TYPE FILESET`
  * if FILESET == "sources_1":
    * `add_design_sources -files PATH/FILES -copy_to COPY_TO -library LIBRARY -file_type FILE_TYPE`
  * if FILESET == "constrs_1":
    * `add_design_constraints -files PATH/FILES -copy_to COPY_TO -used_in USED_IN -processing_order PROCESSING_ORDER -scoped_to_cells SCOPED_TO_CELLS`
  * if FILESET == "sim_1":
    * `add_design_simulation -files PATH/FILES -copy_to COPY_TO -library LIBRARY -file_type FILE_TYPE`
* `add_sub_core_reference VLNV`
  * `add_design_subcores -vlnv VLNV`
* `set_logo_relative LOGO`
  * `add_logo LOGO`
* `set_datasheet_relative <datasheet>`
  * Deprecated. Use `add_product_guide`, `add_changelog`, or `add_readme`
* `add_ttcl_vhd UTILITY_SCRIPT LIBRARY`
  * `add_utility_scripts UTILITY_SCRIPT` (**Note:** LIBRARY is not supported anymore. It must be defined in the TTCL code)
* `add_gui_support_tcl TCL_SCRIPTS`
  * `add_gui_support_tcl TCL_SCRIPTS`
* `add_drivers_relative DRIVER_DIR FILES`
* `add_xparameters_entry PARAMETERS`
  * `add_software_driver -driver_dir DRIVER_DIR -parameters PARAMETERS` (**Note:** FILES must not be defined anymore. All sources in src folder are added automatically.)
* `remove_file_from_ip FILE`
  * Not supported.
  
### New ip_packager features

  * `add_exdes_sources`
  * `add_exdes_constraints`
  * `add_exdes_simulation`
  * `add_exdes_subcores`
  * `add_exdes_script`
  * `add_product_guide`
  * `add_changelog`
  * `add_readme`
  * `add_bd_tcl`
  * `add_upgrade_tcl`
  
## Customization Paramenters

* `gui_create_user_parameter PARAM_NAME FORMAT VALUE DISPLAY_NAME`
  * `create_user_param -param_name PARAM_NAME -format FORMAT -value VALUE` (**Note:** To set DISPLAY_NAME use `gui_add_param -param_name PARAM_NAME -display_name DISPLAY_NAME`)
* `gui_create_parameter PARAM_NAME DISPLAY_NAME`
  * Not needed for existing HDL generics. (**Note:** To set DISPLAY_NAME use `gui_add_param -param_name PARAM_NAME -display_name DISPLAY_NAME`)
* `gui_parameter_set_range MIN MAX`
  * `set_param_config -param_name PARAM_NAME -validation_range [list MIN MAX]`
* `gui_parameter_set_widget_dropdown VALIDATION_LIST`
* `gui_parameter_set_widget_dropdown_list VALIDATION_LIST`
  * `set_param_config -param_name PARAM_NAME -validation_list VALIDATION_LIST`
* `gui_parameter_set_widget_dropdown_pairs VALIDATION_PAIRS`
  * `set_param_config -param_name PARAM_NAME -validation_pairs VALIDATION_PAIRS`
* `gui_parameter_set_widget_checkbox`
  * Not needed anymore. Use `gui_add_parameter -widget WIDGET` to define the widget.
* `gui_parameter_set_expression VALUE_TCL_EXPR`
  * `set_param_config -param_name PARAM_NAME -value_tcl_expr VALUE_TCL_EXPR`
* `gui_parameter_set_enablement ENABLEMENT_TCL_EXPR VALUE`
  * `set_param_config -param_name PARAM_NAME -value VALUE -enablement_tcl_expr ENABLEMENT_TCL_EXPR`
  
## Ports and Interfaces

### PsiIpPackage

* `import_interface_definition DEFINITION DEF_NAMES`
  * `import_bus_definition DEFINITION` (**Note:** DEF_NAMES is not needed anymore.)
* `add_bus_interface VLNV INTERFACE_NAME INTERFACE_MODE DESCRIPTION PORT_MAP`
  * `add_bus_interface -interface_name INTERFACE_NAME -vlnv VLNV -interface_mode INTERFACE_MODE -port_map PORT_MAP` (**Note:** DESCRIPTION is not supported anymore. It is not visible anyways...)
* `set_interface_mode INTERFACE_NAME INTERFACE_MODE`
  * Not supported. Add INTERFACE_MODE together with `add_bus_interface`.
* `add_clock_in_interface <portname> FREQ_HZ`
* `add_clock_out_interface INTERFACE_NAME FREQ_HZ`
  * `add_clock_interface -interface_name INTERFACE_NAME -freq_hz FREQ_HZ` (**Note:** Ports must contain INTERFACE_NAME as prefix_. Direction in/out is automatically recognized.)
* `add_reset_in_interface INTERFACE_NAME POLARITY`
* `add_reset_out_interface INTERFACE_NAME "POLARITY`
  * `add_reset_interface -interface_name INTERFACE_NAME -polarity POLARITY` (**Note:** Ports must contain INTERFACE_NAME as prefix_. Direction in/out is automatically recognized.)
* `add_interrupt_out_interface INTERFACE_NAME SENSITIVITY`
  * `add_interrupt_interface -interface_name INTERFACE_NAME -sensitivity SENSITIVITY` (**Note:** Ports must contain INTERFACE_NAME as prefix_. Direction in/out is automatically recognized.)
* `set_interface_clock INTERFACE_NAME CLOCK`
  * `associate_interface_clock -interface_name INTERFACE_NAME -clock CLOCK`
* `add_interface_enablement_condition INTERFACE_NAME DEPENDENCY`
  * `set_interface_enablement -interface_name INTERFACE_NAME -dependency DEPENDENCY`
* `add_port_enablement_condition PORT_NAME DEPENDENCY`
  * `set_port_enablement -port_name PORT_NAME -dependency DEPENDENCY -driver_value DRIVER_VALUE` (**Note:** DRIVER_VALUE defines the default driver value of an optional port and must be defined.)
  
### New ip_packager features

  * `auto_infer_interface`
  * `add_axi_interface`
  * `add_axis_interface`
  * `add_clockenable_interface`
  * `add_data_interface`
  * `associate_clock_reset`
  
## Adressing and Memory

No functions available.

## Customization GUI

### PsiIpPackage

* `gui_add_page DISPLAY_NAME`
  * `gui_add_page -page_name PAGE_NAME -display_name DISPLAY_NAME`
* `gui_add_group DISPLAY_NAME`
  * `gui_add_group -group_name GROUP_NAME -display_name DISPLAY_NAME`
* `gui_exit_group`
  * Not needed anymore. Use `gui_set_parent` to change current parent level.
* `gui_add_parameter`
  * `gui_add_param -param_name PARAM_NAME -display_name DISPLAY_NAME`
* `gui_parameter_set_tooltip <tooltip>`
  * Not supported. Use -tooltip option of `gui_add_page`, `gui_add_group`, `gui_add_param`, and `gui_add_text`.
* `gui_parameter_text_below TEXT`
  * `gui_add_text -text_name TEXT_NAME -text TEXT`
  
### ip_packager

  * `gui_set_parent`
  