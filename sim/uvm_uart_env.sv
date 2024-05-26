`include "uvm_macros.svh"
import uvm_pkg::*;
class uvm_uart_env extends uvm_env;
	
	`uvm_component_utils(uvm_uart_env)

	// constructor
	function new(string name = "uvm_uart_env", uvm_component parent);
		super.new(name, parent);
	endfunction : new

	//build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	//run_phase
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		`uvm_info("Env",$sformatf("ENV is running %0d"), $time)
		#10;
		`uvm_info("Env",$sformatf("ENV is still running %0d"), $time)
		#20;
		`uvm_info("Env",$sformatf("ENV is ending %0d"),$time)
		phase.drop_objection(this);
	endtask : run_phase
endclass : uvm_uart_env