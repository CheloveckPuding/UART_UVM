`include "./UVM/uvm_uart_base_test.sv" 
import uvm_pkg::*;
`include "uvm_macros.svh"
module testbench_UVM ();
	initial begin
		run_test("uvm_uart_base_test");
	end

endmodule : testbench_UVM