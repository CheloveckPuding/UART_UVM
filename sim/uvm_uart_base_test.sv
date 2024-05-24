`include "uvm_macros.svh"
import uvm_pkg::*;
class uvm_uart_base_test extends uvm_test;
	`uvm_component_utils(uvm_uart_base_test)

	function new(string name = "uvm_uart_base_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
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