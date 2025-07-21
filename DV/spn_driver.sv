`include "spn_sequencer.sv"

class spn_driver extends uvm_driver #(spn_seq_item);
  `uvm_component_utils(spn_driver)

  virtual spn_if.DRIVER vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual spn_if.DRIVER)::get(this, "", "vif", vif)) begin
      `uvm_fatal("DRV", "Could not get virtual interface")
    end
  endfunction
task run_phase(uvm_phase phase);
  spn_seq_item req;

  forever begin
    seq_item_port.get_next_item(req);

    case (req.opcode)
      2'b01: begin
        `uvm_info("DRIVER", $sformatf("Driving ENCRYPTION: opcode=%b, in_data=%h, key=%h",
          req.opcode, req.in_data, req.key), UVM_LOW)
      end
      2'b10: begin
        `uvm_info("DRIVER", $sformatf("Driving DECRYPTION: opcode=%b, in_data=%h, key=%h",
          req.opcode, req.in_data, req.key), UVM_LOW)
      end
      2'b00: begin
        `uvm_warning("DRIVER", "Opcode = 00: No Valid output — Skipping")
      end
      2'b11: begin
        `uvm_warning("DRIVER", "Opcode = 11: Undefined operation — Skipping")
      end
      default: begin
        `uvm_warning("DRIVER", $sformatf("Unsupported opcode: %b — Skipping", req.opcode))
      end
    endcase

    // Only drive if it's a supported operation
    if (req.opcode == 2'b01 || req.opcode == 2'b10) begin
      vif.opcode   <= req.opcode;
      vif.in_data  <= req.in_data;
      vif.key      <= req.key;

      @(posedge vif.clk iff (vif.valid != 2'b00));
      @(posedge vif.clk);

      // Clear inputs
      vif.opcode   <= 2'b00;
      vif.in_data  <= '0;
      vif.key      <= '0;
    end

    seq_item_port.item_done();
  end
endtask



endclass
