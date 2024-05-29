`include "uvm_macros.svh"
`include "uvm_uart_scoreboard.sv"
import uvm_pkg::*;
class uvm_uart_env extends uvm_env;
	
	`uvm_component_utils(uvm_uart_env)

	uvm_uart_scoreboard sbd;

	// constructor
	function new(string name = "uvm_uart_env", uvm_component parent);
		super.new(name, parent);
	endfunction : new

	//build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sbd = uvm_uart_scoreboard::type_id::create("sbd", this);
	endfunction : build_phase

	//run_phase
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		`uvm_info("Env",$sformatf("ENV is running"), $time)
		#10;
		`uvm_info("Env",$sformatf("ENV is still running"), $time)
		#20;
		`uvm_info("Env",$sformatf("ENV is ending"),$time)
		phase.drop_objection(this);
	endtask : run_phase
endclass : uvm_uart_env