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
	input  logic [3:0 ] err_rx_dropped,
	input  logic [3:0 ] err_rx,
	input  logic [3:0 ] err_stop,
	output logic [31:0] delitel,
	output logic [3:0 ] parity_bit_mode,
	output logic [3:0 ] stop_bit_num
);
	

	logic [31:0] status;
	
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
						32'hc  : prdata <= status[3:0]; // err_rx
						32'h10 : prdata <= status[7:4]; // err_dropped
						32'h14 : prdata <= status[11:8]; // err_stop
					endcase
				end
			end
		end
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			status <= {8{1'b1}};
		end else begin
			if (err_rx) begin
				status[3:0] <= 0;
			end else begin
				status[3:0] <= {4{1'b1}}; 
			end
			if (err_rx_dropped) begin
				status[7:4] <= 0;			
			end
			else begin
				status[7:4] <= {4{1'b1}};
			end
			if (err_stop) begin
				status[11:8] <= 0;			
			end
			else begin
				status[11:8] <= {4{1'b1}};
			end
		end
	end
endmodule