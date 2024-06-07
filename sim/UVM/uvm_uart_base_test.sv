`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uvm_uart_env.sv"
class uvm_uart_base_test extends uvm_test;
	`uvm_component_utils(uvm_uart_base_test)

	uvm_uart_env env;
	axis_sequence axis_sequence_in;
	axis_sequence axis_sequence_out;

	axis_sequence_config axis_sequence_in_config;
    axis_sequence_config axis_sequence_out_config;



	function new(string name = "uvm_uart_base_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		axis_sequence_in = axis_sequence::type_id::create("axis_sequence_in", this);
	    axis_sequence_out = axis_sequence::type_id::create("axis_sequence_out", this);
		env = uvm_uart_env::type_id::create("env", this);
		axis_sequence_in_config = axis_sequence_config::type_id::create("axis_sequence_in_config");
	    axis_sequence_out_config = axis_sequence_config::type_id::create("axis_sequence_out_config");

	    axis_sequence_in.axis_seqc_config = axis_sequence_in_config;
	    axis_sequence_out.axis_seqc_config = axis_sequence_out_config;

	endfunction : build_phase

	task main_phase(uvm_phase phase);
	    phase.raise_objection(this);
	        fork
	            axis_sequence_in.start(env.axis_agent_master.axis_sequencer_h);
	            axis_sequence_out.start(env.axis_agent_slave.axis_sequencer_h);  
	        join  
	    phase.drop_objection(this);
	endtask

	// task run_phase(uvm_phase phase);
	// 	phase.raise_objection(this);
	// 	uvm_top.print_topology();
	// 	`uvm_info("Test","Test is running %0d", $time)
	// 	#10;
	// 	`uvm_info("Test","Test is still running %0d", $time)
	// 	#20;
	// 	`uvm_info("Test","Test is ending %0d",$time)
	// 	phase.drop_objection(this);
	// endtask : run_phase
endclass : uvm_uart_base_test