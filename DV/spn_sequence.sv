`ifndef SPN_SEQUENCE_SV
`define SPN_SEQUENCE_SV

`include "spn_seq_item.sv"

class spn_sequence extends uvm_sequence #(spn_seq_item);
  `uvm_object_utils(spn_sequence)

  function new(string name = "spn_sequence");
    super.new(name);
  endfunction

  task body();
    spn_seq_item req;
    `uvm_info(get_type_name(), "Starting mixed corner & normal sequence", UVM_LOW)

    // --- Corner Cases ---
    // 1: Encrypt all-zeros
    req = spn_seq_item::type_id::create("corner_zero_encrypt");
    req.opcode  = 2'b01;
    req.in_data = 16'h0000;
    req.key     = 32'h0000_0000;
    start_item(req); finish_item(req);

    // 2: Encrypt all-ones
    req = spn_seq_item::type_id::create("corner_ones_encrypt");
    req.opcode  = 2'b01;
    req.in_data = 16'hFFFF;
    req.key     = 32'hFFFF_FFFF;
    start_item(req); finish_item(req);

    // 3: Illegal opcode → should produce valid==2'b11
    req = spn_seq_item::type_id::create("corner_illegal_opcode");
    req.opcode  = 2'b11;
    req.in_data = 16'h1234;
    req.key     = 32'hDEAD_BEEF;
    start_item(req); finish_item(req);

    // --- Normal Random Cases ---
    // Generate 5 random legal transactions
    repeat (5) begin
      req = spn_seq_item::type_id::create("normal_rand");
      assert(req.randomize() with {
        opcode inside {2'b01, 2'b10};       // only encrypt or decrypt
        // in_data and key will randomize over full range
      });
      start_item(req); finish_item(req);
    end
  endtask
endclass

`endif  // SPN_SEQUENCE_SV