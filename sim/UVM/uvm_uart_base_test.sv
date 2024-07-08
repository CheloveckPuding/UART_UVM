class uvm_uart_base_test extends uvm_test;
	`uvm_component_utils(uvm_uart_base_test)

	uvm_uart_env env;
	axis_sequence axis_sequence_in;
	axis_sequence axis_sequence_out;
	uvm_apb_uart_cfg_sequence apb_seq;

	axis_sequence_config axis_sequence_in_config;
    axis_sequence_config axis_sequence_out_config;
    uart_agent_cfg cfg;
    uvm_uart_obj obj;
    uart_sequence uart_seq;


	function new(string name = "", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cfg = uart_agent_cfg::type_id::create("cfg");
		obj = uvm_uart_obj::type_id::create("obj");
		obj.randomize();
		assert(cfg.randomize() with{t == obj.delitel * obj.CLOCK_PERIOD;});
		apb_seq = uvm_apb_uart_cfg_sequence::type_id::create("apb_seq");
		assert(apb_seq.randomize() with {delitel == obj.delitel;});
		apb_seq.cfg = cfg;
		uvm_config_db #(uart_agent_cfg)::set(null, "*", "cfg", cfg);
		axis_sequence_in = axis_sequence::type_id::create("axis_sequence_in", this);
	    axis_sequence_out = axis_sequence::type_id::create("axis_sequence_out", this);
		env = uvm_uart_env::type_id::create("env", this);
		axis_sequence_in_config = axis_sequence_config::type_id::create("axis_sequence_in_config");
	    axis_sequence_out_config = axis_sequence_config::type_id::create("axis_sequence_out_config");

	    axis_sequence_in.axis_seqc_config = axis_sequence_in_config;
	    axis_sequence_out.axis_seqc_config = axis_sequence_out_config;
	    $display("ok",);

	endfunction : build_phase

	task main_phase(uvm_phase phase);
		uart_sequence uart_seq;
		// if( !uvm_config_db #(uart_agent_cfg)::get(this, "", "cfg", cfg) )
  //           `uvm_error("", "uvm_config_db::get failed")
      	phase.raise_objection(this);
	        fork
	            axis_sequence_in.start(env.axis_agent_master.axis_sequencer_h);
	            axis_sequence_out.start(env.axis_agent_slave.axis_sequencer_h);  
			    repeat(5) begin
					uart_seq = uart_sequence::type_id::create("uart_seq");
					assert(uart_seq.randomize());
			    	uart_seq.start(env.uart_agent_u.seqr);
			    end
	        join
	        #1000;  
	    phase.drop_objection(this);
	endtask

	task configure_phase(uvm_phase phase);
			$display("ok in conf");
		    phase.raise_objection( this, "Starting apb_base_seqin main phase" );
		    $display("%t Starting sequence apb_seq run_phase",$time);
		    apb_seq.start(env.apb_agent_u.sqr);
		    #100;
		    phase.drop_objection( this , "Finished apb_seq in main phase" );
	endtask : configure_phase

endclass : uvm_uart_base_test