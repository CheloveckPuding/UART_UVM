`include "uvm_macros.svh"
`include "uvm_uart_scoreboard.sv"
`include "../../AXIS_UVM_Agent/src/axis_include.svh"
`include "APB_AGENT/apb_transaction.sv"
`include "APB_AGENT/apb_sequence.sv"
`include "APB_AGENT/apb_sequencer.sv"
`include "APB_AGENT/apb_driver.sv"
`include "APB_AGENT/apb_monitor.sv"
`include "APB_AGENT/apb_agent.sv"
import uvm_pkg::*;
class uvm_uart_env extends uvm_env;
	
	`uvm_component_utils(uvm_uart_env)


    localparam TDATA_BYTES_IN = 4;
    localparam TDATA_BYTES_OUT = 10;

    virtual axis_if #(TDATA_BYTES_IN) axis_in;
    virtual axis_if #(TDATA_BYTES_OUT) axis_out;
    virtual apb_if 					   apb_if_u;

	uvm_uart_scoreboard sbd;
	axis_agent axis_agent_master;
	axis_agent axis_agent_slave;
	apb_agent apb_agent_u;

	// constructor
	function new(string name = "uvm_uart_env", uvm_component parent);
		super.new(name, parent);
	endfunction : new

	//build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db #(virtual axis_if #(TDATA_BYTES_IN))::get(this, "", "axis_in", axis_in))
        	`uvm_fatal("GET_DB", "Can not get axis_in_1")

	    if (!uvm_config_db #(virtual axis_if #(TDATA_BYTES_OUT))::get(this, "", "axis_out", axis_out))
	        `uvm_fatal("GET_DB", "Can not get axis_out")        

	    if (!uvm_config_db #(virtual apb_if 				   )::get(this, "", "apb_if_u", apb_if_u))
	        `uvm_fatal("GET_DB", "Can not get axis_out")        

		sbd = uvm_uart_scoreboard::type_id::create("sbd", this);
		axis_agent_master = axis_agent::type_id::create("axis_agent_master", this);
		axis_agent_slave = axis_agent::type_id::create("axis_agent_slave", this);
		apb_agent_u = apb_agent::type_id::create("apb_agent_u", this);
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