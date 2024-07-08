`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)
`uvm_analysis_imp_decl(_if_u)
`uvm_analysis_imp_decl(_in_intf_u)
`uvm_analysis_imp_decl(_out_intf_u)

class uvm_uart_scoreboard #(int TDATA_BYTES = 1) extends uvm_scoreboard;
    `uvm_component_param_utils(uvm_uart_scoreboard #(TDATA_BYTES))
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    uvm_analysis_imp_in #(axis_data, uvm_uart_scoreboard #(TDATA_BYTES)) analysis_port_in;
    uvm_analysis_imp_out #(axis_data, uvm_uart_scoreboard #(TDATA_BYTES)) analysis_port_out;
    uvm_analysis_imp_if_u #(apb_transaction, uvm_uart_scoreboard #(TDATA_BYTES)) analysis_port_if_u;
    uvm_analysis_imp_out_intf_u #(uart_trans, uvm_uart_scoreboard #(TDATA_BYTES)) analysis_port_out_intf_u;
    uvm_analysis_imp_in_intf_u #(uart_trans, uvm_uart_scoreboard #(TDATA_BYTES)) analysis_port_in_intf_u;

    axis_data axis_data_q_in[$];
    axis_data axis_data_q_out[$];
    uart_trans uart_trans_q_in_intf_u[$];
    uart_trans uart_trans_q_out_intf_u[$];
    apb_transaction apb_transaction_q_if_u[$];

    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    	analysis_port_in = new("analysis_port_in", this);
		analysis_port_out = new("analysis_port_out", this);
		analysis_port_if_u = new("analysis_port_if_u", this);
		analysis_port_out_intf_u = new("analysis_port_out_intf_u", this);
		analysis_port_in_intf_u = new("analysis_port_in_intf_u", this);
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

	function void write_in_intf_u (uart_trans uart_data);
	    uart_trans_q_out_intf_u.push_back(uart_data);
	endfunction
	function void write_out_intf_u (uart_trans uart_data);
	    uart_trans_q_in_intf_u.push_back(uart_data);
	endfunction

	function void final_phase(uvm_phase phase);
    	int loop_num;
        super.final_phase(phase);
        if (!$size(axis_data_q_in)) `uvm_fatal("AXIS_Q_IN","IS EMT");
        if (!$size(axis_data_q_out))`uvm_fatal("AXIS_Q_OUT","IS EMT");
        if (!$size(apb_transaction_q_if_u)) `uvm_fatal("APB_Q","IS EMT");
    	foreach(apb_transaction_q_if_u[i]) begin
    		`uvm_info("APB_Q",apb_transaction_q_if_u[i].convert2string() ,UVM_MEDIUM);
            if (apb_transaction_q_if_u[i].addr == 32'hc) begin
                loop_num = i;
            end
    	end
        $display("apb_data is %0h",~apb_transaction_q_if_u[loop_num].data);
        if (!$size(uart_trans_q_in_intf_u) && !apb_transaction_q_if_u[loop_num].data)`uvm_fatal("UART_IN","IS EMT");
        if (!$size(uart_trans_q_out_intf_u) && !apb_transaction_q_if_u[loop_num].data) `uvm_fatal("UART_OUT","IS EMT");
    	foreach(axis_data_q_in[i]) begin
    		`uvm_info("AXIS_Q_IN",axis_data_q_in[i].convert2string() ,UVM_MEDIUM);
    	end
    	foreach(axis_data_q_out[i]) begin
    		`uvm_info("AXIS_Q_OUT",axis_data_q_out[i].convert2string() ,UVM_MEDIUM);
    	end
        if (!apb_transaction_q_if_u[loop_num].data) begin
        	foreach(uart_trans_q_in_intf_u[i]) begin
        		`uvm_info("UART_IN",uart_trans_q_in_intf_u[i].convert2string() ,UVM_MEDIUM);
        	end
        	foreach(uart_trans_q_out_intf_u[i]) begin
        		`uvm_info("UART_OUT",uart_trans_q_out_intf_u[i].convert2string() ,UVM_MEDIUM);
        	end
        end

    	if (!apb_transaction_q_if_u[loop_num].data) begin
            foreach(axis_data_q_in[i]) begin
        		if (axis_data_q_in[i].tdata != uart_trans_q_out_intf_u[i].data) begin
        			`uvm_error("AXIS_TO_UART",$sformatf("SEND is %0h GOT is %0h",axis_data_q_in[i].tdata, uart_trans_q_out_intf_u[i].data));
        		end
        	end
        	foreach(axis_data_q_out[i]) begin
        		if (axis_data_q_out[i].tdata != uart_trans_q_in_intf_u[i].data) begin
        			`uvm_error("UART_TO_AXIS",$sformatf("SEND is %0h GOT is %0h",uart_trans_q_in_intf_u[i].data, axis_data_q_out[i].tdata ));
        		end
        	end
        end
        else begin 
            foreach(axis_data_q_in[i]) begin
                if (axis_data_q_in[i].tdata != axis_data_q_out[i].tdata) begin
                    `uvm_error("AXIS_TO_AXIS",$sformatf("SEND is %0h GOT is %0h",axis_data_q_in[i].tdata, axis_data_q_out[i].tdata));
                end
            end
        end
    endfunction : final_phase
endclass