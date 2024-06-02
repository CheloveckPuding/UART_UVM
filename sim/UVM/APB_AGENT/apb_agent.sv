class apb_agent extends uvm_agent;

   //Agent will have the sequencer, driver and monitor components for the APB interface
   apb_sequencer sqr;
   apb_driver drv;
   apb_monitor mon;

   virtual apb_if  apb_if_u;

   `uvm_component_utils_begin(apb_agent)
      `uvm_field_object(sqr, UVM_ALL_ON)
      `uvm_field_object(drv, UVM_ALL_ON)
      `uvm_field_object(mon, UVM_ALL_ON)
   `uvm_component_utils_end
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   //Build phase of agent - construct sequencer, driver and monitor
   //get handle to virtual interface from env (parent) config_db
   //and pass handle down to srq/driver/monitor
   virtual function void build_phase(uvm_phase phase);
      sqr = apb_sequencer::type_id::create("sqr", this);
      drv = apb_driver::type_id::create("drv", this);
      mon = apb_monitor::type_id::create("mon", this);
      
     if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_if_u", apb_if_u)) begin
       `uvm_fatal("build phase", "No virtual interface specified for this agent instance")
      end
     uvm_config_db#(virtual apb_if)::set( this, "sqr", "apb_if_u", apb_if_u);
     uvm_config_db#(virtual apb_if)::set( this, "drv", "apb_if_u", apb_if_u);
     uvm_config_db#(virtual apb_if)::set( this, "mon", "apb_if_u", apb_if_u);
   endfunction

   //Connect - driver and sequencer port to export
   virtual function void connect_phase(uvm_phase phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
     uvm_report_info("APB_AGENT", "connect_phase, Connected driver to sequencer");
   endfunction
endclass