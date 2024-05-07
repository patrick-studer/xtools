set currentNamespace [namespace current]
puts "gui_support.tcl sourced now into namespace ${currentNamespace}"

proc test_gui_support {value} {
    puts "DEBUG: test_gui_support()"
    return [expr 2*$value]
}