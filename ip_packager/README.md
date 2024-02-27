# IP-Packager

## General Informaion

This directory is the top-level directory the IP-Packager, which provides a TCL package to automate Xilinx/AMD Vivado's IP packaging process.

### Owner
* Patrick Studer [studer.patrick92@gmail.com] ([github.com/patrick-studer](https://github.com/patrick-studer))

### Legal Notice
* [legal.txt](./doc/legal.txt)

### Motivation
Since IP packaging is a recurring process in daily work of an VHDL/SoC Firmware engineer, it is good to have this flow automated.
Not only time saving, but reproduction consistency may be reached.
This idea is not new! Oliver Bründler [oli.bruendler@gmx.ch], Jonas Purtschert [jonas.purtschert@psi.ch], and Reto Meier [reto.meier@dectris.com] developed the [PsiIpPackage](https://github.com/patrick-studer/PsiIpPackage) tool back in 2019.
This tool did a great job in the past but its structure is not made for scalability and maintainability.
Since procedure definitions relied on positional arguments and all information was pre-fetched and applied in one batch, it was not easy to debug configuration errors.
Furthermore, it was not easy to add new functionality, which is only for a specific Vivado tool version.

This points were addressed in the re-implementation and are provided in this repository. The new IP-Packager key figures are:
- parsing of named arguments/options
- every procedure call is immediately transfered in the corresponding Vivado TCL commands (i.e. easier debugging)
- many common errors are handled and produce readable error messages
- functionality is provided through a TCL package (separate namespace) which reduced the possibility of name-clashes for procedures/variables in the TCL interpreter
- documentation (i.e. help) directly provided in TCL and thus always at hand
- automated procedure code completion and arguments checking inside TCL console
- IPI based simulation, out-of-context synthesis/implementation

### Outlook
The repository organisation may look strange in some places. This is due to preparation for releasing the IP-Packager as [Xilinx TCL Store](https://github.com/Xilinx/XilinxTclStore) application.
This requires a specific organisation of files and their naming.
The only required change, to be ready for the TCL Store, is renaming the package namespace from `::xtools::ip_packager` to `::tclapp::xtools::ip_packager`, and it may be published in the [Xilinx TCL Store](https://github.com/Xilinx/XilinxTclStore).

This would distribute the IP-Packager directly within Vivado and allow to access in with only minor steps (after installing the application).

## Compatibility
The basis implementation was made with **Vivado 2020.1**. It is required to use a Vivado version equal or higher than 2020.1.

## Installation
Clone this repository (XTools) and access it directly from your design projects.

```TCL
set pkg_path                            <path (absolute or relative to package.tcl file) to directory in which folder "xtools" is located>
```

## Usage
The process of packaging an IP-core is described in the so-called `package.tcl` (or any other name given by the user).
It is recommended to create a IPI-wrapper (see [here](./test/test_ipi/hdl/IpPackager_2020_1_ipi.vhd)) file around the top-entity to overcome some limitations like removing external function calls (from HDL packages)
or provide additional generics which support a nice IP-GUI design.

The IP-Packager provides a TCL package (`::xtools::ip_packager`), which may be loaded directly in Vivado.
To use the Vivado-internal documentation/help mechanism and auto-completion of commands, it is necessary to load the IP-Packager as application and enable the help infrastructure.

```TCL
lappend auto_path                       [file join $pkg_path "xtools"]
::tclapp::support::appinit::load_app    ${pkg_path} "::xtools::ip_packager" "ip_packager"
::rdi::set_help_config                  -expose_namespace "ip_packager"
```

After loading the TCL package into the running Vivado application, the packaging may start with `ip_packager::create_package_project`.

### Best Practise
This section will follow soon and highlight some important aspects when packagin an IP-core...

## Documentation (doc)
The documentation of procedures is embedded in the source code and can be directly accessed through Vivado's help system.

To get an overview of all available commands just type `help ip_packager` in Vivado TCL console after loading the application and enabling help (see above).

Alternatively, you may run [help.tcl](scripts/help.tcl):

```TCL
cd $pkg_dir
source -notrace ./xtools/ip_packager/scripts/help.tcl
```

Help to a specific command can be accessed by tipping `ip_packager::<any-command> -help` in the Vivado TCL console.

## Example/Testbench (test)
Every tagged release of the IP-Packager is verified with a simple dummy IP-core (see [package.tcl](./test/test_ipi/scripts/package.tcl).
This is also a good starting point for newbies of the IP-Packager, since it displays a wide range of features.

To package the test IP-core run the following script in your Vivado TCL console:

```TCL
cd $pkg_dir
source ./xtools/ip_packager/test/test.tcl
```
**NOTE:** The temporary created `package_prj` will be deleted after successful packaging.
To evaluate the packaged test IPI, comment out the `ip_packager::close_package_project` command at the end of [package.tcl](./test/test_ipi/scripts/package.tcl).
## Templates
The IP-Packager provides some useful templates for basic and advanced usage:
- [package.tcl](./templates/package/package.tcl)
  - Minimalistic IP-Packager package.tcl example. Can be used as starting point for new projects.
- [bd.tcl](./templates/bd/bd.tcl)
  - Allows automatic parameter propagation from block design (BD) parameters into the IP configuration and finally to HDL parameters (generics).
- [TTCL](./templates/ttcl/template.ttcl)
  - Creating files (HDL, XDC, ...) on-the-fly with generic, design dependent content.
  
## Snippets
Snippets are used by the IP-Packager itself to create specific files efficiently. They include tags, which are automatically replaced by package project specific content.

## Feature Requests and Error Reporting
To request new features or report bugs, please use the [XTools issue board](https://github.com/patrick-studer/xtools/issues) and add a meaningful title (prefix like "BUG:", "IMPROVEMENT":, ...).
**It is mendatory to provide the Vivado version and steps to reproduce (if possible with the example/testbench).**

Contributions are possible. Please open first an issue and a related pull-request to a feature branch (`feature/my-issue-title`).

**NOTE:** New features should be whenever possible compartible with **Vivado 2020.1**.

## Revision History
See [revision_history.txt](./revision_history.txt).