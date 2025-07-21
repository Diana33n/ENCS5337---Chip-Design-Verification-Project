`include "spn_agent.sv"
`include "spn_scoreboard.sv"

class spn_env extends uvm_env;

  `uvm_component_utils(spn_env)

  spn_agent       agent;
  spn_scoreboard  sb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = spn_agent::type_id::create("agent", this);
    sb    = spn_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.mon.item_collected_port.connect(sb.item_collected_export);
  endfunction

endclass
