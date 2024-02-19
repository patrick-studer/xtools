set currentNamespace [namespace current]
puts "gui_support2.tcl sourced now into namespace ${currentNamespace}" 

proc test_gui_support2 {value} {
    puts "DEBUG: test_gui_support2()"
    return [expr 3*$value]
}
