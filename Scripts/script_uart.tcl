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

add_files -fileset "sources_1" -norecurse "$origin_dir/../sources/axis_uart_rx.sv"
add_files -fileset "sources_1" -norecurse "$origin_dir/../sources/axis_uart_tx.sv"
add_files -fileset "sources_1" -norecurse "$origin_dir/../sources/uart_top.sv"
add_files -fileset "sources_1" -norecurse "$origin_dir/../sources/apb_uart_regs.sv"
add_files -fileset "Test_UART" -norecurse "$origin_dir/../sim/axis_if.sv"
add_files -fileset "Test_UART" -norecurse "$origin_dir/../sim/apb_if.sv"
add_files -fileset "Test_UART" -norecurse "$origin_dir/../sim/tb_UART.sv"
add_files -fileset "Test_UVM" -norecurse "$origin_dir/../sim/uvm_uart_base_test.sv"
add_files -fileset "Test_UVM" -norecurse "$origin_dir/../sim/testbench_UVM.sv"



set_property top TB [get_filesets Test_UART]
set_property top testbench_UVM [get_filesets Test_UVM]

launch_simulation

start_gui
