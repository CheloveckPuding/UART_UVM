class uvm_apb_uart_cfg_sequence extends uvm_sequence#(apb_transaction);
  
  `uvm_object_utils(uvm_apb_uart_cfg_sequence)
  
  rand logic [31:0] delitel;
  rand logic [2:0 ] parity_bit_mode;
  rand logic        stop_bit_num;
  rand logic        loopback;
  apb_transaction transactions [4];

  constraint cfg {
    delitel > 32'h0;
  }

  function new (string name = "");
    super.new(name);
  endfunction

  task body();
    begin
      transactions[0] = new();
      assert(transactions[0].randomize() with {
        addr==32'h0;
        data==delitel;
        pwrite==1;
      });
      $display("delitel is %0h", delitel);
      transactions[1] = new();
      assert(transactions[1].randomize() with {
        addr==32'h4;
        data==parity_bit_mode;
        pwrite==1;
      });
      transactions[2] = new();
      assert(transactions[2].randomize() with {
        addr==32'h8;
        data==stop_bit_num;
        pwrite==1;
      });
      transactions[3] = new();
      assert(transactions[3].randomize() with {
        addr==32'hc;
        data==0;
        pwrite==1;
      });
      foreach(transactions[i]) begin
        start_item(transactions[i]);
        finish_item(transactions[i]);
      end
    end
  endtask
endclass