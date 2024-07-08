class uvm_uart_obj extends  uvm_object;
    `uvm_object_utils(uvm_uart_obj)
    
    function new (string name = "");
        super.new(name);
    endfunction
    parameter CLOCK_PERIOD = 10;
    rand int unsigned numb_trans;
    rand logic [31:0] delitel;

    constraint del {delitel >= 4; delitel < 15;}


endclass : uvm_uart_obj