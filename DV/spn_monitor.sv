`ifndef SPN_MONITOR_SV
`define SPN_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class spn_monitor extends uvm_monitor;

  virtual spn_if.MONITOR vif;
  uvm_analysis_port #(spn_seq_item) item_collected_port;

  `uvm_component_utils(spn_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spn_if.MONITOR)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON", "Could not get virtual interface")
    end
  endfunction

task run_phase(uvm_phase phase);
  integer wait_count;
  forever begin
    @(posedge vif.clk);
    
    if (vif.valid != 2'b00) begin
      spn_seq_item trans = spn_seq_item::type_id::create("trans");
      trans.opcode   = vif.opcode;
      trans.in_data  = vif.in_data;
      trans.key      = vif.key;
      trans.out_data = vif.out_data;
      trans.valid    = vif.valid;

      case (vif.valid)
        2'b01: `uvm_info("MON", "VALID = 01 : Successful ENCRYPTION", UVM_LOW)
        2'b10: `uvm_info("MON", "VALID = 10 : Successful DECRYPTION", UVM_LOW)
        2'b11: `uvm_warning("MON", $sformatf("VALID = 11 : Undefined or unsupported opcode = %b", vif.opcode))
        default: `uvm_info("MON", "VALID = 00 : No valid output", UVM_LOW)
      endcase

      item_collected_port.write(trans);

      // Wait for valid to go low again
      wait_count = 0;
      do begin
        @(posedge vif.clk);
        wait_count++;
        if (wait_count > 100) begin
          `uvm_warning("MON", "Timeout waiting for valid to return to 2'b00")
          break;
        end
      end while (vif.valid != 2'b00);
    end
  end
endtask



endclass

`endif
