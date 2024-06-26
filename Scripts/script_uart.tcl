set project_name "UART_UVM_PROJECT"

set project_found [ llength [get_projects $project_name] ]
if {$project_found > 0} close_project

set origin_dir [file dirname [info script]]
cd "$origin_dir/../../"

create_project $project_name "$project_name" -force -part xc7a100tcsg324-1

set path "$origin_dir/../../$project_name/$project_name"

file mkdir "$path.srcs/UART_design"
file mkdir "$path.sim/UART_test"


create_fileset -simset "Test_UART"
create_fileset -simset "Test_UVM"
current_fileset -simset [get_filesets Test_UVM]
delete_fileset sim_1

add_files -fileset "sources_1" -norecurse "UART_UVM/sources/"
add_files -fileset "Test_UART" -norecurse "UART_UVM/sim/tb_UART.sv"
add_files -fileset "Test_UVM" -norecurse "UART_UVM/sim/test_pkg.sv"
# add_files -fileset "Test_UVM" -norecurse "UART_UVM/sim/UVM/"
add_files -fileset "Test_UVM" -norecurse "UART_UVM/sim/testbench_UVM.sv"



set_property top TB [get_filesets Test_UART]
set_property top testbench_UVM [get_filesets Test_UVM]

launch_simulation

start_gui
