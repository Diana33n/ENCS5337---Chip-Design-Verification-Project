`ifndef SPN_TEST_SV
`define SPN_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "spn_env.sv"

class spn_test extends uvm_test;
  `uvm_component_utils(spn_test)

  spn_env env;

  function new(string name = "spn_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = spn_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    spn_sequence seq;
    phase.raise_objection(this);

    `uvm_info(get_type_name(), "Test started...", UVM_MEDIUM)

    seq = spn_sequence::type_id::create("seq");
    seq.start(env.agent.seqr);

    `uvm_info(get_type_name(), "Test completed.", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif
