class uvm_uart_cfg_sequence extends uvm_sequence#(uart_trans);
  
  `uvm_object_utils(uvm_uart_cfg_sequence)
  
  rand logic [31:0] delitel_uart;
  // rand logic [2:0 ] parity_bit_mode;
  // rand logic        stop_bit_num;
  // apb_transaction transactions [3];
  constraint cfg {
    delitel_uart > 32'h0;
  }

  uvm_apb_uart_cfg_sequence apb_cfg;
  uart_trans transaction;

  function new (string name = "");
    super.new(name);
  endfunction

  task body();
    begin
      transaction = new();
      start_item(transaction);
      assert(transaction.randomize() with {delitel == delitel_uart;});
      finish_item(transaction);
    end
  endtask
endclass