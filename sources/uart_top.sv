module uart_top (
	input  logic        clk,
	input  logic        rst_n,
	// apb signals
	input  logic        pwrite,
	input  logic        psel,
	input  logic        penable,
	input  logic [31:0] paddr,
	input  logic [31:0] pwdata,
	output logic [31:0] prdata,
	// AXIS signals
	// master
	input  logic        maxis_tready_i,
	output logic        maxis_tvalid_o,
	output logic [7:0]  maxis_data_o,
	// slave
	input  logic        saxis_tvalid_i,
	input  logic [7:0]  saxis_data_i,
	output logic 	    saxis_tready_o,
	// uart signals
	input  logic 		uart_rx,
	output logic        uart_tx
);
	
	logic [31:0] delitel;
	logic [3:0 ] parity_bit_mode;
	logic [3:0 ] stop_bit_num;
	logic [3:0 ] err_rx;
	logic [3:0 ] err_tx;

	axis_uart_tx tx 
	(
		.clk(clk),
		.rst_n(rst_n),
		.uart_tx(uart_tx),
		.saxis_data_i(saxis_data_i),
		.saxis_tvalid_i(saxis_tvalid_i),
		.saxis_tready_o(saxis_tready_o),
		.delitel(delitel),
		.stop_bit_num(stop_bit_num),
		.parity_bit_mode(parity_bit_mode)
	);

	axis_uart_rx rx 
	(
		.clk(clk),
		.rst_n(rst_n),
		.uart_rx(uart_rx),
		.maxis_tready_i(maxis_tready_i),
		.maxis_data_o(maxis_data_o),
		.maxis_tvalid_o(maxis_tvalid_o),
		.delitel(delitel),
		.stop_bit_num(stop_bit_num),
		.parity_bit_mode(parity_bit_mode)
	);

	apb_uart_regs regs
	(
		.pwrite(pwrite),
		.psel(psel),
		.penable(penable),
		.paddr(paddr),
		.pwdata(pwdata),
		.tready(tready),
		.prdata(prdata),
		.uart_tx(uart_tx),
		.err_tx(err_tx),
		.err_rx(err_rx),
		.delitel(delitel),
		.parity_bit_mode(parity_bit_mode),
		.stop_bit_num(stop_bit_num)
	);
	

endmodule