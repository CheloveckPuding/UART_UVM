class uvm_uart_random_loopback_test extends uvm_uart_base_test;
	`uvm_component_utils(uvm_uart_random_loopback_test)
	
	function new(string name = "", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		apb_seq.loopback = $random();
	endfunction : build_phase

endclass : uvm_uart_loopback_test