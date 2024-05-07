###################################################################################################
# Copyright (c) 2024, XTools by Patrick Studer, Switzerland (https://github.com/patrick-studer)
###################################################################################################

###################################################################################################
# Review Package (linting and mkIndex)
###################################################################################################

set file_dir [file dirname [info script]]
cd [file join $file_dir ..]

lint_files [glob ip_packager.tcl]
lint_files [glob addressing.tcl]
lint_files [glob compatibility.tcl]
lint_files [glob files.tcl]
lint_files [glob gui.tcl]
lint_files [glob identification.tcl]
lint_files [glob interfaces.tcl]
lint_files [glob parameters.tcl]
lint_files [glob project.tcl]
lint_files [glob utils.tcl]

pkg_mkIndex "."
auto_mkindex "."

###################################################################################################
# Publish APP (into Xilinx TCL Store)
# Currently, the APP is not released in the TCL Store. Therefore, nothing will be excecuted below.
###################################################################################################

set NAME                {ip_packager}
set DISPLAY             {IP Packager}
set COMPANY             {xtools}
set COMPANY_DISPLAY     {XTools}
set SUMMARY             {Summary}
set AUTHOR              {Patrick Studer}
set REVISION            2020.1
set REVISION_HISTORY    {"Release supports Vivado 2020.1 and higher."}
set VIVADO_VERSION      [version -short]

if {0} {
  # Update the app's XML (app.xml)
  # Prerequisite: the app.xml file must already exist
  tclapp::update_app_catalog -update_main_catalog -release ${REVISION} ${COMPANY}::${NAME} ${REVISION_HISTORY}
}

if {0} {
  # Create the inital app's XML (app.xml)
  # Prerequisite: the app.xml does not exist
  # Load the app catalog (app.xml)
  tclapp::open_app_catalog ${COMPANY}::${NAME}
  # Add some properties to the app
  tclapp::add_app_property {name} $NAME
  tclapp::add_app_property {display} $DISPLAY
  tclapp::add_app_property {company} $COMPANY
  tclapp::add_app_property {company_display} $COMPANY_DISPLAY
  tclapp::add_app_property {summary} $SUMMARY
  tclapp::add_app_property {author} $AUTHOR
  tclapp::add_app_property {pkg_require} "Vivado 1.${VIVADO_VERSION}"
  tclapp::add_app_property {revision} $REVISION
  tclapp::add_app_property {revision_history} $REVISION_HISTORY
  # Save the app catalog
  tclapp::save_app_catalog
}

###################################################################################################
# EOF
###################################################################################################
