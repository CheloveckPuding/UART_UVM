class uvm_uart_cfg_sequence extends  uvm_object;
    `uvm_object_utils(uvm_uart_cfg_sequence)
    
    function new (string name = "");
        super.new(name);
    endfunction

    parameter CLOCK_PERIOD = 10;
    
    int unsigned numb_trans = $random();
    logic [31:0] delitel = $urandom_range(15,0);
    logic [2:0]  parity_bit_mode = $random();
    logic        stop_bit_num = $random();
    time         t = delitel * CLOCK_PERIOD;  

    // constraint c {delitel > 0; delitel < 15;}


endclass : uvm_uart_cfg_sequence