module apb_uart_regs (
	input 				clk,    // Clock 
	input 				rst_n,  // Asynchronous reset active low
	// apb signals
	input  logic        pwrite,
	input  logic        psel,
	input  logic        penable,
	input  logic [31:0] paddr,
	input  logic [31:0] pwdata,
	output  logic        pready,
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
	assign pready = 1;
	
	always @ (posedge clk or negedge rst_n) begin 
		if (!rst_n) begin
			delitel 	    <= 0;
			parity_bit_mode <= 0;
			stop_bit_num 	<= 0;
		end else begin 
			if (psel && penable && pready) begin
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
						32'hc  : prdata <= status;
					endcase
				end
			end
		end
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			status <= {4{1'b0}};
		end else begin
			if (err_rx) begin
				status[0] <= 1;
			end
			if (err_rx_dropped) begin
				status[1] <= 1;
			end
			if (err_stop) begin
				status[2] <= 1;
			end
			if (paddr == 32'hc && psel && penable && pwrite) begin
				if (pwdata[0]) begin
					status[0] <= 0;
				end
				if (pwdata[1]) begin
					status[1] <= 0;
				end
				if (pwdata[2]) begin
					status[2] <= 0;
				end
			end
		end
	end
endmodule