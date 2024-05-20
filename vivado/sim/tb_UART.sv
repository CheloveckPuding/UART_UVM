module TB ();
	parameter CLOCK_PERIOD  = 10;
	parameter BAUD_RATE     = 100_000_000/115200;
	parameter DATA_WIDTH    = 8;
	parameter MESSAGES      = 10;
	parameter DEL_ADDR      = 0;
	parameter PARITY_ADDR   = 4;
	parameter STOP_ADDR     = 8;
	parameter ERR_PAR_ADDR  = 32'hc;
	parameter ERR_DROP_ADDR = 32'h10;
	
	logic 		    	   			clk;
	logic 		    	   			rst_n;
	logic 		    	   			uart_tx;
	logic [31:0]    	   			delitel;
	logic [31:0]    	   			stop_bit_num;
	logic [31:0]    	   			parity_bit_mode;
	logic [31:0]    	   			err_rx_dropped;
	logic [31:0]    	   			err_rx;
	logic 		    	   			tready;
	logic [DATA_WIDTH-1:0] 			data [];	
	int 				 			taken_data [];
	logic [3:0]			   			error;
	logic [$clog2(MESSAGES)-1:0]	correct_ct;
	logic [3:0]						status_parity;
	logic [3:0]						status_dropped;

	initial begin
		clk = 0;
		correct_ct = 0;
		slave.tlast = 1;
		tready = 1;
		rst_n <= 1;
		#CLOCK_PERIOD;
		rst_n <= 0;
		#CLOCK_PERIOD;
		rst_n <= 1;
		#CLOCK_PERIOD;
		repeat(MESSAGES) begin
			data = new[1];
			error = 4;
			data[0] = $random();
			@(posedge clk);
			apb_if.write_apb(DEL_ADDR, BAUD_RATE);
			apb_if.write_apb(PARITY_ADDR, $urandom_range(3,0));
			apb_if.write_apb(STOP_ADDR, $urandom_range(2,1));
			@(posedge clk);
			fork
				master.axis_send(data);
				slave.axis_get(taken_data);
			join
			u_apb_if.read_apb(ERR_PAR_ADDR, status_parity);
			u_apb_if.read_apb(ERR_DROP_ADDR, status_dropped);

			if (status_parity == 4'h0) begin
				$display("Error in parity");
			end else begin
				error = error - 1;
			end

			if (status_dropped == 4'h0) begin
				$display("Error in accessing by AXIS");
			end else begin
				error = error - 1;
			end

			if (taken_data.size() == data.size()) begin
				error = error - 1;
			end
			else begin
				$display("Error in size taken_data");
			end

			for (int i = 0; i < taken_data.size(); i++) begin
				if (data[i] == taken_data[i]) begin
					error = error - 1;
				end
				else begin
					$display("Error in bit number %0d it has to be %0d while it is %0d",i, data[i], taken_data[i]);
				end
			end

			if (error == 0) begin
				correct_ct = correct_ct + 1;
				$display("correct_ct",);
			end
			else begin
				$display("Error in trancieve");
			end
		end
		if (correct_ct == MESSAGES) begin
			$display("Test is ok");
		end
		else begin
			$display("Test is not ok");
		end
	end

	always #(CLOCK_PERIOD/2) clk <= ~clk;

	//apb_if
	apb_if u_apb_if
	(
		.clk(clk),
		.rst_n(rst_n)
	);

	axis_if #(DATA_WIDTH) master(.clk(clk));
	axis_if #(DATA_WIDTH) slave(.clk(clk));
	//rx
	axis_uart_rx rx
	(
		.clk(clk),
		.rst_n(rst_n),
		.uart_rx(uart_tx),
		.maxis_tready_i(slave.tready),
		.maxis_data_o(slave.data),
		.maxis_tvalid_o(slave.tvalid),
		.delitel(delitel),
		.stop_bit_num(stop_bit_num),
		.parity_bit_mode(parity_bit_mode),
		.err_rx_dropped(err_rx_dropped),
		.err_rx(err_rx)
	);

	//tx
	axis_uart_tx tx
	(
		.clk(clk),
		.rst_n(rst_n),
		.uart_tx(uart_tx),
		.saxis_data_i(master.data),
		.saxis_tvalid_i(master.tvalid),
		.saxis_tready_o(master.tready),
		.delitel(delitel),
		.stop_bit_num(stop_bit_num),
		.parity_bit_mode(parity_bit_mode)
	);

	//apb
	apb_regs regs
	(
		.clk(clk),
		.rst_n(rst_n),
		.pwrite(u_apb_if.pwrite),
		.psel(u_apb_if.psel),
		.penable(u_apb_if.penable),
		.paddr(u_apb_if.paddr),
		.pwdata(u_apb_if.pwdata),
		.tready(tready),
		.prdata(u_apb_if.prdata),
		.err_rx_dropped(err_rx_dropped),
		.err_rx(err_rx),
		.delitel(delitel),
		.parity_bit_mode(parity_bit_mode),
		.stop_bit_num(stop_bit_num)
	);



endmodule : TB