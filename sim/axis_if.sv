interface axis_if # (
    parameter DATA_WIDTH = 10
)(
    input clk
    );
	
    logic tlast = 0;
    logic tvalid = 0;
    logic [DATA_WIDTH - 1 : 0] data = 0;
    logic tready = 0;


    task automatic axis_send
        (
            input logic [DATA_WIDTH-1:0] frame []
        );
        begin
            int ct_frame = 0;
            int start_frame = 1;
            logic tvalid_next = $random;
            while (start_frame) begin 
            	tvalid_next = $random();
            	if (tvalid_next) begin
            		tvalid <= 1;
            		if (ct_frame == $size(frame)) begin
            			tlast <= 1;
            			start_frame = 0;
            		end
            		else begin
            			data <= frame[ct_frame];
            			ct_frame = ct_frame + 1;
            			tlast <= 0;
            		end
            		@ (posedge clk);
            		while (~tready) begin 
            			@(posedge clk);
            		end
            	end
            	else begin
            		tvalid <= 0;
            		@(posedge clk);
            	end
            end
            tvalid <= 0;
        end
    endtask : axis_send

    task automatic axis_get
        (
            output int taken_data []
        );
        begin
            int ct_taken_data = 0;
            int start_frame = 1;

            while(start_frame) begin
            	tready <= $random();
              	@ (posedge clk);
        		if (tvalid && tready) begin
        			taken_data = new[taken_data.size()+1](taken_data);
                    taken_data[ct_taken_data] = data;
                    ct_taken_data = ct_taken_data + 1;
                    if (tlast) begin
            			start_frame = 0;
            		end
        		end
            end
        end
    endtask : axis_get

endinterface