`include "UVM/uvm_uart_base_test.sv" 
`include "../AXIS_UVM_Agent/src/axis_intf.sv"
`include "UVM/APB_AGENT/apb_if.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"
module testbench_UVM ();

	localparam TDATA_BYTES_IN = 4;
    localparam TDATA_BYTES_OUT = 10;

    bit aclk = 0;
    axis_if #(TDATA_BYTES_IN)  axis_in  (aclk);
    axis_if #(TDATA_BYTES_OUT) axis_out (aclk);
    apb_if 					   apb_if_u ();
    
    always 
        #2 aclk = ~aclk;
	
	initial begin
		uvm_config_db #(virtual axis_if #(TDATA_BYTES_IN ))::set(null, "*", "axis_in", axis_in);
        uvm_config_db #(virtual axis_if #(TDATA_BYTES_OUT))::set(null, "*", "axis_out", axis_out);
        uvm_config_db #(virtual apb_if 					  )::set(null, "*", "apb_if_u", apb_if_u);
		run_test("uvm_uart_base_test");
	end

endmodule : testbench_UVM