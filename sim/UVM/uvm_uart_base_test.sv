`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uvm_uart_env.sv"
`include "uvm_apb_uart_cfg_sequence.sv"
`include "uvm_uart_cfg_sequence.sv"
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
		uvm_uart_cfg_sequence uart_seq;
	    phase.raise_objection(this);
	        fork
	            axis_sequence_in.start(env.axis_agent_master.axis_sequencer_h);
	            axis_sequence_out.start(env.axis_agent_slave.axis_sequencer_h);  
			    repeat(10) begin 
					uart_seq = uvm_uart_cfg_sequence::type_id::create("uart_seq");
					assert(uart_seq.randomize() with {delitel_uart == 6;});
			    	uart_seq.start(env.uart_agent_u.seqr);
			    end
	        join  
	    phase.drop_objection(this);
	endtask

	task configure_phase(uvm_phase phase);
		 	uvm_apb_uart_cfg_sequence apb_seq;
		    apb_seq = uvm_apb_uart_cfg_sequence::type_id::create("apb_seq");
		    assert(apb_seq.randomize() with {delitel < 15;});
		    phase.raise_objection( this, "Starting apb_base_seqin main phase" );
		    $display("%t Starting sequence apb_seq run_phase",$time);
		    apb_seq.start(env.apb_agent_u.sqr);
		    #100ns;
		    phase.drop_objection( this , "Finished apb_seq in main phase" );
	endtask : configure_phase

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