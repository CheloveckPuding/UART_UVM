interface apb_if
	(
		input clk,
		input rst_n
	);	

	logic pwrite = 0;
	logic psel = 0;
	logic penable = 0;
	logic pready;
	logic [31:0] prdata;
	logic [31:0] pwdata = 0;
	logic [31:0] paddr = 0;

	task automatic write_apb
	(	
		input logic [31:0] addr,
		input logic [31:0] data
	);
		begin
			psel <= 1;
			paddr <= addr;
			pwrite <= 1;
			pwdata <= data;
			@(posedge clk);
			penable <= 1;
			do begin 
				@(posedge clk);
			end
			while(~pready);
			psel <= 0;
			penable <= 0;
			pwrite <= 0;
		end
	endtask : write_apb

	task automatic read_apb
	(
		input logic [31:0] addr,
		output logic [31:0] data
	);
		begin
			psel <= 1;
			pwrite <= 0;
			paddr <= addr;
			@ (posedge clk);
			penable <= 1;
			@(posedge clk);
			while(~pready) begin 
				@(posedge clk);
			end
			data = prdata;
			psel <= 0;
			penable <= 0;
			pwrite <= 0;
		end
	endtask : read_apb

endinterface
