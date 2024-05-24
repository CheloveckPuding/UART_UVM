module axis_uart_rx (
	input  logic         clk,
	input  logic         rst_n,
	// uart
	input  logic         uart_rx,
	// axis to master
	input  logic         maxis_tready_i,
	output logic  [7:0]  maxis_data_o,
	output logic         maxis_tvalid_o,
	// apb regs
	input  logic  [31:0] delitel, 
	input  logic  		 stop_bit_num, 
	input  logic  [2:0 ] parity_bit_mode,
	//err
	output logic  		 err_rx_dropped,
	output logic  		 err_rx,
	output logic  		 err_stop
);

	typedef enum {NOT_RECIVE, RECIVE} state_set; // change Place
    state_set state, next_state;
    // counters
    logic [3:0 ]  bit_ct;   // ideal counter mean for bits
    logic [31:0]  div_ct;   // ideal counter mean for inner divider
    logic [31:0]  counter;  // counter to count for divider
    logic [3:0 ]  data_ct;  // counter for recieving data
    // uart inside signals
    logic         uart_ce;   // uart signal from sample counter 
    logic [7:0 ]  uart_data; // uart data from recieving
    logic		  reg_1;
    logic 		  reg_2;
    // from apb regs
    logic [2:0 ]  parity_bit; // uart signal for case of perity check

    // making uart_ce to enable data recieving
    always @(posedge clk or negedge rst_n) begin
    	if (!rst_n) begin
    		counter <= 0;
    	end else begin
    		if (state == RECIVE) begin
				if (counter == div_ct) begin
					counter <= 0;
				end else begin 
					counter <= counter + 1;
				end
       		end
       		else begin
       			counter <= 0;
       		end
		end
	end

	// metastability
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			reg_1 <= 0;
			reg_2 <= 0;
		end else begin
			reg_1 <= uart_rx;
			reg_2 <= reg_1;
		end
	end

	// uart_ce to take data
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			uart_ce <= 0;
		end else if (counter == (div_ct>>1)) begin
			uart_ce <= 1;
		end
		else begin
			uart_ce <= 0;
		end
	end

	// counter to count taken bits
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			data_ct <= 0;
		end 
		else if (uart_ce && state == RECIVE) begin
			if (data_ct == bit_ct) begin
				data_ct <= 0;
			end else begin
				data_ct <= data_ct + 1;
			end
		end
	end


	// recieve data
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			uart_data <= 0;
			err_rx <= 0;
			err_stop <= 0;
		end else begin
			if (uart_ce && state == RECIVE) begin
				if (data_ct > 4'h0 && data_ct < 4'h9) begin
					uart_data <= {reg_2, uart_data[7:1]};
				end
				if (data_ct == 4'h9) begin
					case (parity_bit)
						3'h0: begin
							if (reg_2 != 0) begin
								err_rx <= 1;
							end
						end
						3'h1: begin
							if (reg_2 != 1) begin
								err_rx <= 1;
							end
						end
						3'h2: begin
							if (reg_2 != ~(^uart_data)) begin
								err_rx <= 1;
							end
						end
						3'h3: begin
							if (reg_2 != ^uart_data) begin
								err_rx <= 1;
							end
						end
					endcase
				end
				if (data_ct >= 4'ha && data_ct) begin
					if (reg_2 != 1) begin
						err_stop <= 1;
					end
				end
			end
			if (state == NOT_RECIVE || err_rx_dropped) begin
				uart_data <= 0;
			end
		end
	end

	// send via AXIS
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			maxis_tvalid_o <= 0;
		end
		else begin
			if (data_ct == bit_ct && uart_ce && ~err_rx_dropped) begin
				maxis_tvalid_o <= 1;
				maxis_data_o <= uart_data;
			end
			else if (maxis_tready_i) begin
				maxis_tvalid_o <= 0;
			end
			if (err_rx_dropped) begin
				maxis_tvalid_o <= 0;
				maxis_data_o <= 0;
			end
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			err_rx_dropped <= 0;
		end else begin
			if (maxis_tvalid_o && data_ct == bit_ct && state == RECIVE) begin
				err_rx_dropped <= 1;
			end
			else if(state == NOT_RECIVE) begin
				err_rx_dropped <= 0;
			end
		end
	end

    // always for setup regs
    always @(posedge clk or negedge rst_n) begin
    	if (!rst_n) begin
    		div_ct <= 0;
    		bit_ct <= 0;
    		parity_bit <= 0;
    	end else begin 
	    	if (state == NOT_RECIVE) begin
	    		div_ct <= delitel;
	    		if (stop_bit_num) begin
	    			bit_ct <= 4'hb;
	    		end
	    		else begin 
	    			bit_ct <= 4'ha;
	    		end
	    		parity_bit <= parity_bit_mode;
	    	end
    	end
    end

    // state machine to find start signal and start new recieve
    always @(posedge clk, negedge rst_n)
        if(~rst_n)
            state <= NOT_RECIVE;
        else 
            state <= next_state;

    always@(*) begin
        next_state = state;
        case (state)
            NOT_RECIVE:
                if (~uart_rx) begin
                    next_state = RECIVE;
                end
            RECIVE:
                if (data_ct == bit_ct && uart_ce) begin
                    next_state = NOT_RECIVE;
                end
            default : next_state = state;
        endcase
    end

endmodule