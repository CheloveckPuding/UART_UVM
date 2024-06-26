package uart_test_pkg;
	`include "uvm_macros.svh"
	import uvm_pkg::*;
	`include "../UART/UVM/uart_include.sv"
	`include "UVM/APB_AGENT/apb_include.sv"
	`include "UVM/uvm_apb_uart_cfg_sequence.sv"
	`include "../AXIS_UVM_Agent/src/axis_include.svh"
	`include "UVM/uvm_uart_scoreboard.sv"
	`include "UVM/uvm_uart_env.sv"
	`include "UVM/uvm_uart_base_test.sv"
endpackage : uart_test_pkg