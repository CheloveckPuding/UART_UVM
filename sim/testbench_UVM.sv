`include "UVM/uvm_uart_base_test.sv" 
`include "../AXIS_UVM_Agent/src/axis_intf.sv"
`include "UVM/APB_AGENT/apb_if.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"
module testbench_UVM ();
    parameter CLOCK_PERIOD = 10;

    bit clk = 0;
    bit rst_n = 1;
    axis_if  axis_in  (clk);
    axis_if  axis_out (clk);
    apb_if   apb_if_u (clk);
    
    always #(CLOCK_PERIOD/2) clk = ~clk;
	
	initial begin
		uvm_config_db #(virtual axis_if)::set(null, "*", "axis_in",  axis_in);
        uvm_config_db #(virtual axis_if)::set(null, "*", "axis_out", axis_out);
        uvm_config_db #(virtual apb_if )::set(null, "*", "apb_if_u", apb_if_u);
		run_test("uvm_uart_base_test");
	end

    initial begin
        apb_if_u.rst_n = rst_n;
        apb_if_u.pready = 1;
        @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
    end

    // instance DUT

    uart_top DUT 
    (
        .clk(clk),
        .rst_n(rst_n),
        .pwrite(apb_if_u.pwrite),
        .psel(apb_if_u.psel),
        .penable(apb_if_u.penable),
        .paddr(apb_if_u.paddr),
        .pwdata(apb_if_u.pwdata),
        .prdata(apb_if_u.prdata),
        .maxis_tready_i(axis_out.tready),
        .maxis_tvalid_o(axis_out.tvalid),
        .maxis_data_o(axis_out.tdata),
        .saxis_tvalid_i(axis_in.tvalid),
        .saxis_data_i(axis_in.tdata),
        .saxis_tready_o(axis_in.tready),
        .uart_rx(uart_tx),
        .uart_tx(uart_tx)
    );

endmodule : testbench_UVM