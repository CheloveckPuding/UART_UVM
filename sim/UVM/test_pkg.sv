package test_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "../AXIS_UVM_Agent/src/axis_intf.sv"
	`include "../UART/UVM/uart_intf.sv"
	`include "UVM/APB_AGENT/apb_if.sv"
	`include "uvm_uart_cfg_sequence.sv"
	`include "uvm_apb_uart_cfg_sequence.sv"
	`include "APB_AGENT/apb_include.sv"
	`include "../AXIS_UVM_Agent/src/axis_include.svh"
	`include "../../UART/UVM/uart_include.sv"
	`include "uvm_uart_scoreboard.sv"
	`include "uvm_uart_env.sv"
	`include "UVM/uvm_uart_base_test.sv"
	
endpackage : test_pkg