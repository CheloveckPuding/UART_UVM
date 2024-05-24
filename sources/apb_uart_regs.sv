module apb_uart_regs (
	input 				clk,    // Clock 
	input 				rst_n,  // Asynchronous reset active low
	// apb signals
	input  logic        pwrite,
	input  logic        psel,
	input  logic        penable,
	input  logic [31:0] paddr,
	input  logic [31:0] pwdata,
	input  logic        tready,
	output logic [31:0] prdata,
	// output signals to uart_rx/uart_tx
	input  logic  		err_rx_dropped,
	input  logic  		err_rx,
	input  logic  		err_stop,
	output logic [31:0] delitel,
	output logic [2:0 ] parity_bit_mode,
	output logic  		stop_bit_num
);
	

	logic [3:0] status;
	
	always @ (posedge clk or negedge rst_n) begin 
		if (!rst_n) begin
			delitel 	    <= 0;
			parity_bit_mode <= 0;
			stop_bit_num 	<= 0;
		end else begin 
			if (psel && penable && tready) begin
				if (pwrite) begin
					case (paddr)
						32'h0 : delitel 	    <= pwdata;
						32'h4 : parity_bit_mode <= pwdata;
						32'h8 : stop_bit_num 	<= pwdata;
					endcase
				end
				else begin 
					case (paddr)
						32'h0  : prdata <= delitel;
						32'h4  : prdata <= parity_bit_mode;
						32'h8  : prdata <= stop_bit_num;
						32'hc  : prdata <= status[0]; // err_rx
						32'h10 : prdata <= status[1]; // err_dropped
						32'h14 : prdata <= status[2]; // err_stop
					endcase
				end
			end
		end
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			status <= {4{1'b0}};
		end else begin
			status[0] <= err_rx;
			status[1] <= err_rx_dropped;
			status[2] <= err_stop;
			if (pwdata == 1) begin
				if (paddr == 32'hc && status[0]) begin
					status[0] <= 0;
				end
				if (paddr == 32'h10 && status[1]) begin
					status[1] <= 0;
				end
				if (paddr == 32'h14 && status[2]) begin
					status[2] <= 0;
				end
			end
		end
	end
endmodule