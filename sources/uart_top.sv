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
	output logic        pready,
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
	logic [2:0 ] parity_bit_mode;
	logic 		 stop_bit_num;
	logic 		 err_rx;
	logic		 err_rx_dropped;
	logic		 err_stop;
	logic		 loopback;
	logic		 tx;
	logic		 rx;

	always_comb begin
		if (loopback) begin
			tx = rx;
		end
		else begin
			uart_tx = tx;
			rx = uart_rx;
		end
	end


	axis_uart_tx tx 
	(
		.clk(clk),
		.rst_n(rst_n),
		.uart_tx(tx),
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
		.uart_rx(rx),
		.maxis_tready_i(maxis_tready_i),
		.maxis_data_o(maxis_data_o),
		.maxis_tvalid_o(maxis_tvalid_o),
		.delitel(delitel),
		.stop_bit_num(stop_bit_num),
		.parity_bit_mode(parity_bit_mode),
		.err_rx_dropped(err_rx_dropped),
		.err_rx(err_rx),
		.err_stop(err_stop)
	);

	apb_uart_regs regs
	(
		.clk(clk),
		.rst_n(rst_n),
		.pwrite(pwrite),
		.psel(psel),
		.penable(penable),
		.paddr(paddr),
		.pwdata(pwdata),
		.pready(pready),
		.prdata(prdata),
		.err_rx(err_rx),
		.err_rx_dropped(err_rx_dropped),
		.err_stop(err_stop),
		.delitel(delitel),
		.parity_bit_mode(parity_bit_mode),
		.stop_bit_num(stop_bit_num),
		.loopback(loopback)
	);
	

endmodule