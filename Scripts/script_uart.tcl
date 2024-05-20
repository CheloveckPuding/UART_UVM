set project_name "UART"

set project_found [ llength [get_projects $project_name] ]
if {$project_found > 0} close_project

set origin_dir [file dirname [info script]]
cd $origin_dir

create_project $project_name "$project_name" -force -part xc7a100tcsg324-1

set path "$origin_dir/$project_name/$project_name"

file mkdir "$path.srcs/UART_design"
file mkdir "$path.sim/UART_test"


create_fileset -simset "Test_UART"
current_fileset -simset [get_filesets Test_UART]
delete_fileset sim_1

add_files -fileset "sources_1" -norecurse "../sources/axis_uart_rx.sv"
add_files -fileset "sources_1" -norecurse "../sources/axis_uart_tx.sv"
add_files -fileset "sources_1" -norecurse "../sources/uart_top.sv"
add_files -fileset "sources_1" -norecurse "../sources/apb_regs.sv"
add_files -fileset "Test_UART" -norecurse "../sim/axis_if.sv"
add_files -fileset "Test_UART" -norecurse "../sim/apb_if.sv"
add_files -fileset "Test_UART" -norecurse "../sim/tb_UART.sv"

set_property top TB [get_filesets Test_UART]

launch_simulation

start_gui