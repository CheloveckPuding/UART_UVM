`include "uvm_macros.svh"
`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)
`uvm_analysis_imp_decl(_if_u)
`uvm_analysis_imp_decl(_intf_u)

class uvm_uart_scoreboard #(int TDATA_BYTES = 1) extends uvm_scoreboard;
    `uvm_component_param_utils(uvm_uart_scoreboard #(TDATA_BYTES))
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    uvm_analysis_imp_in #(axis_data, uvm_uart_scoreboard #(TDATA_BYTES)) analysis_port_in;
    uvm_analysis_imp_out #(axis_data, uvm_uart_scoreboard #(TDATA_BYTES)) analysis_port_out;
    uvm_analysis_imp_if_u #(apb_transaction, uvm_uart_scoreboard #(TDATA_BYTES)) analysis_port_if_u;
    uvm_analysis_imp_intf_u #(uart_trans, uvm_uart_scoreboard #(TDATA_BYTES)) analysis_port_intf_u;

    axis_data axis_data_q_in[$];
    axis_data axis_data_q_out[$];
    uart_trans uart_trans_q_intf_u[$];
    apb_transaction apb_transaction_q_if_u[$];

    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    	analysis_port_in = new("analysis_port_in", this);
		analysis_port_out = new("analysis_port_out", this);
		analysis_port_if_u = new("analysis_port_if_u", this);
		analysis_port_intf_u = new("analysis_port_intf_u", this);
    endfunction : build_phase
    function void write_in (axis_data axis_data_h);
	    axis_data_q_in.push_back(axis_data_h);
	endfunction

	function void write_out (axis_data axis_data_h);
	    axis_data_q_out.push_back(axis_data_h);
	endfunction

	function void write_if_u (apb_transaction apb_data);
	    apb_transaction_q_if_u.push_back(apb_data);
	endfunction

	function void write_intf_u (uart_trans uart_data);
	    uart_trans_q_intf_u.push_back(uart_data);
	endfunction

	function void final_phase(uvm_phase phase);
    	super.final_phase(phase);
    	// phase.raise_objection(this);
    	foreach(axis_data_q_in[i]) begin
    		`uvm_info("AXIS_Q_IN",axis_data_q_in[i].convert2string() ,UVM_MEDIUM);
    	end
    	foreach(axis_data_q_out[i]) begin
    		`uvm_info("AXIS_Q_OUT",axis_data_q_out[i].convert2string() ,UVM_MEDIUM);
    	end
    	foreach(apb_transaction_q_if_u[i]) begin
    		`uvm_info("APB_Q",apb_transaction_q_if_u[i].convert2string() ,UVM_MEDIUM);
    	end
    	foreach(uart_trans_q_intf_u[i]) begin
    		`uvm_info("AXIS_Q",uart_trans_q_intf_u[i].sprint() ,UVM_MEDIUM);
    	end
    	// phase.drop_objection(this);
    endfunction : final_phase
	// function void write_if_u (axis_data axis_data_h);
	//     axis_data_q_in_2.push_back(axis_data_h.tdata);
	// endfunction
endclass