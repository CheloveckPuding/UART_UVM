`include "uvm_macros.svh"
import uvm_pkg::*;
class uvm_uart_scoreboard extends  uvm_scoreboard;

/*-------------------------------------------------------------------------------
-- Interface, port, fields
-------------------------------------------------------------------------------*/
	

/*-------------------------------------------------------------------------------
-- UVM Factory register
-------------------------------------------------------------------------------*/
	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(uvm_uart_scoreboard)

/*-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------*/
	// Constructor
	function new(string name = "uvm_uart_scoreboard", uvm_component parent=null);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		`uvm_info("Scoreboard","Scoreboard is running", $time())
	endtask : run_phase

endclass : uvm_uart_scoreboard