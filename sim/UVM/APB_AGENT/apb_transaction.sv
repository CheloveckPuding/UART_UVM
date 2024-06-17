class apb_transaction extends uvm_sequence_item;
  
  `uvm_object_utils(apb_transaction)
  
  //typedef for READ/Write transaction type
  typedef enum {READ, WRITE} kind_e;
  rand bit   [31:0] addr;      //Address
  rand bit [31:0] data;     //Data - For write or read response
  rand kind_e  pwrite;       //command type
  
  constraint c1{soft addr[31:0]>=32'd0; soft addr[31:0] <=32'd12;};
  constraint c2{soft data[31:0]>=32'd0; soft data[31:0] <32'd256;};
  
  function new (string name = "apb_transaction");
    super.new(name);
  endfunction
  
  function string convert2string();
    return $sformatf("pwrite=%s paddr=%0h data=%0h",pwrite,addr,data);
  endfunction
  
endclass