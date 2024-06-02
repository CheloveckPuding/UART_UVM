`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uvm_uart_env.sv"
`include "../../AXIS_UVM_Agent/src/axis_intf.sv"
class uvm_uart_base_test extends uvm_test;
	`uvm_component_utils(uvm_uart_base_test)

	uvm_uart_env env;

	function new(string name = "uvm_uart_base_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = uvm_uart_env::type_id::create("env", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		`uvm_info("Test","Test is running %0d", $time)
		#10;
		`uvm_info("Test","Test is still running %0d", $time)
		#20;
		`uvm_info("Test","Test is ending %0d",$time)
		phase.drop_objection(this);
	endtask : run_phase
endclass : uvm_uart_base_test