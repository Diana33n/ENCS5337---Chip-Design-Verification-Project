`include "spn_sequencer.sv"
`include "spn_driver.sv"
`include "spn_monitor.sv"

class spn_agent extends uvm_agent;

  `uvm_component_utils(spn_agent)

  spn_driver    drv;
  spn_monitor   mon;
  spn_sequencer seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    drv  = spn_driver::type_id::create("drv", this);
    mon  = spn_monitor::type_id::create("mon", this);
    seqr = spn_sequencer::type_id::create("seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass
