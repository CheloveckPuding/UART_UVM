module axis_uart_tx (
	input  logic         clk,
	input  logic         rst_n,
	// uart
	output logic         uart_tx,
	// axis from master
	input  logic  [7:0 ] saxis_data_i,
	input  logic         saxis_tvalid_i,
	output logic         saxis_tready_o,
	// apb regs
	input  logic  [31:0] delitel, 
	input  logic  		 stop_bit_num, 
	input  logic  [2:0 ] parity_bit_mode
);

	typedef enum {NO_TRANCIVE, TRANCIVE} state_set; // change place
    state_set state, next_state;
    // counters
    logic [3:0 ]  bit_ct; // ideal counter mean for bits
    logic [32:0]  div_ct; // ideal counter mean for inner divider
    logic [32:0]  counter; // counter to count for divider
    logic [3:0 ]  data_ct; // counter for trancieving data
    // uart inside signals
    logic         uart_ce;  // uart signal from sample counter 
    logic [7:0 ]  uart_data; // uart data from trancieving
    logic 		  reg_1;
    logic  		  reg_2;
    // from apb regs
    logic [2:0 ]  parity_bit; // uart signal for case of parity check
    logic 		  parity_result;

    // making uart_ce to enable data trancieving
    always @(posedge clk or negedge rst_n) begin
    	if (!rst_n) begin
    		counter <= 0;
    		uart_ce <= 0;
    	end else begin 
			if (state == TRANCIVE) begin
				if (counter == (div_ct-1)) begin
					counter <= 0;
					uart_ce <= 1;
				end else begin 
					counter <= counter + 1;
					uart_ce <= 0;
				end
			end else begin 
				counter <= 0;
			end
    	end
	end

	// trancieve data
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			data_ct <= 0;
			uart_data <= 0;
		end else begin
			if (uart_ce && state == TRANCIVE) begin
				if (data_ct == 4'h0) begin
					reg_2 <= 0;
					data_ct <= data_ct + 1;
				end
				else if (data_ct >= 4'h1 && data_ct <= 4'h8) begin
					uart_data <= {1'b0, uart_data[7:1]};
					reg_2 <= uart_data[0];
					data_ct <= data_ct + 1;
				end
				else if (data_ct == 4'h9) begin
					reg_2 <= parity_result;
					data_ct <= data_ct + 1;
				end
				else if (data_ct >= 4'ha && data_ct <= bit_ct) begin
					reg_2 <= 1;
					data_ct <= data_ct + 1;
					if (data_ct == bit_ct) begin
						uart_data <= 0;
						data_ct <= 0;
					end
				end
			end
		end
	end

	// get via AXIS
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
    		saxis_tready_o <= 1;
    	end else if (state == NO_TRANCIVE) begin
			uart_data <= saxis_data_i;
			saxis_tready_o <= 1;
		end
		else if (next_state == TRANCIVE) begin
			saxis_tready_o <= 0;
		end
	end

	// Is it ok?
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			reg_2   <= 1;
			reg_1   <= 1;
			uart_tx <= 1;
		end else begin
			reg_1   <= reg_2;
			uart_tx <= reg_1;
		end
	end

    // always for setup regs
    always @(posedge clk or negedge rst_n) begin
    	if (!rst_n) begin
    		div_ct     <= 0;
    		bit_ct     <= 0;
    		parity_bit <= 0;
    	end else begin 
	    	if (state == NO_TRANCIVE) begin
	    		div_ct <= delitel;
	    		if (stop_bit_num) begin
	    			bit_ct <= 4'hb;
	    		end
	    		else begin 
	    			bit_ct <= 4'ha;
	    		end
	    		case (parity_bit_mode)
					3'h0: parity_result <= 0;
					3'h1: parity_result <= 1;
					3'h2: parity_result <= ~(^saxis_data_i);
					3'h3: parity_result <= ^saxis_data_i;
					default : parity_result <= 0;
				endcase
	    	end
    	end
    end

    // state machine to find start signal and start new trancieve
    always @(posedge clk, negedge rst_n)
        if(~rst_n)
            state <= NO_TRANCIVE;
        else 
            state <= next_state;

    always@(*) begin
        next_state = state;
        case (state)
            NO_TRANCIVE:
                if (saxis_tready_o && saxis_tvalid_i) begin
                    next_state = TRANCIVE;
                end
            TRANCIVE:
                if (uart_ce && data_ct == bit_ct ) begin
                    next_state = NO_TRANCIVE;
                end
            default : next_state = state;
        endcase
    end

endmodule