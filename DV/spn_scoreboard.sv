`ifndef SPN_SCOREBOARD_SV
`define SPN_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class spn_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(spn_scoreboard)

  spn_seq_item trans_q[$];
  uvm_analysis_imp #(spn_seq_item, spn_scoreboard) item_collected_export;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_export = new("item_collected_export", this);
  endfunction

  virtual function void write(spn_seq_item trans);
    trans_q.push_back(trans);
  endfunction

  function logic [3:0] sbox(input logic [3:0] in);
    case (in)
      4'h0: sbox = 4'hA; 4'h1: sbox = 4'h5; 4'h2: sbox = 4'h8; 4'h3: sbox = 4'h2;
      4'h4: sbox = 4'h6; 4'h5: sbox = 4'hC; 4'h6: sbox = 4'h4; 4'h7: sbox = 4'h3;
      4'h8: sbox = 4'h1; 4'h9: sbox = 4'h0; 4'hA: sbox = 4'hB; 4'hB: sbox = 4'h9;
      4'hC: sbox = 4'hF; 4'hD: sbox = 4'hD; 4'hE: sbox = 4'h7; 4'hF: sbox = 4'hE;
    endcase
  endfunction

  function logic [3:0] inv_sbox(input logic [3:0] in);
    case (in)
      4'hA: inv_sbox = 4'h0; 4'h5: inv_sbox = 4'h1; 4'h8: inv_sbox = 4'h2; 4'h2: inv_sbox = 4'h3;
      4'h6: inv_sbox = 4'h4; 4'hC: inv_sbox = 4'h5; 4'h4: inv_sbox = 4'h6; 4'h3: inv_sbox = 4'h7;
      4'h1: inv_sbox = 4'h8; 4'h0: inv_sbox = 4'h9; 4'hB: inv_sbox = 4'hA; 4'h9: inv_sbox = 4'hB;
      4'hF: inv_sbox = 4'hC; 4'hD: inv_sbox = 4'hD; 4'h7: inv_sbox = 4'hE; 4'hE: inv_sbox = 4'hF;
    endcase
  endfunction

  function logic [15:0] substitute(input logic [15:0] in);
    return {
      sbox(in[15:12]), sbox(in[11:8]),
      sbox(in[7:4]),   sbox(in[3:0])
    };
  endfunction

  function logic [15:0] inv_substitute(input logic [15:0] in);
    return {
      inv_sbox(in[15:12]), inv_sbox(in[11:8]),
      inv_sbox(in[7:4]),   inv_sbox(in[3:0])
    };
  endfunction

  function logic [15:0] permute(input logic [15:0] in);
    return {in[7:0], in[15:8]};
  endfunction

  function logic [15:0] inv_permute(input logic [15:0] in);
    return {in[7:0], in[15:8]};
  endfunction

  function logic [15:0] ref_encrypt(input logic [15:0] data, input logic [31:0] key);
    logic [15:0] temp;
    logic [15:0] round_key[2:0];

    round_key[0] = {key[7:0], key[23:16]};
    round_key[1] = key[15:0];
    round_key[2] = {key[7:0], key[31:24]};

    temp = data ^ round_key[0];
    temp = substitute(temp);
    temp = permute(temp);

    temp = temp ^ round_key[1];
    temp = substitute(temp);
    temp = permute(temp);

    temp = temp ^ round_key[2];
    temp = substitute(temp);

    return temp;
  endfunction

  function logic [15:0] ref_decrypt(input logic [15:0] data, input logic [31:0] key);
    logic [15:0] temp;
    logic [15:0] round_key[2:0];

    round_key[0] = {key[7:0], key[23:16]};
    round_key[1] = key[15:0];
    round_key[2] = {key[7:0], key[31:24]};

    temp = inv_substitute(data);
    temp = temp ^ round_key[2];

    temp = inv_permute(temp);
    temp = inv_substitute(temp);
    temp = temp ^ round_key[1];

    temp = inv_permute(temp);
    temp = inv_substitute(temp);
    temp = temp ^ round_key[0];

    return temp;
  endfunction

  task run_phase(uvm_phase phase);
  spn_seq_item trx;
  logic [15:0] expected;

  forever begin
    wait (trans_q.size() > 0);
    trx = trans_q.pop_front();

    if (trx.valid == 2'b00)
      continue;

    if (trx.valid == 2'b11) begin
      `uvm_warning("SPN_SB", $sformatf("Received undefined/invalid operation: opcode=%b", trx.opcode))
      continue;
    end

    `uvm_info("SPN_SB", $sformatf(
      "\nReceived:\nOpcode: %b\nIn : %h\nKey: %h\nOut: %h\nValid: %b",
      trx.opcode, trx.in_data, trx.key, trx.out_data, trx.valid), UVM_LOW)

    case (trx.opcode)
      2'b01: begin
        expected = ref_encrypt(trx.in_data, trx.key);
        if (expected !== trx.out_data)
          `uvm_error("SPN_SB", $sformatf("ENCRYPT MISMATCH! Expected = %h, Got = %h", expected, trx.out_data))
        else
          `uvm_info("SPN_SB", $sformatf("ENCRYPT MATCH! Output = %h", trx.out_data), UVM_MEDIUM);
      end
      2'b10: begin
        expected = ref_decrypt(trx.in_data, trx.key);
        if (expected !== trx.out_data)
          `uvm_error("SPN_SB", $sformatf("DECRYPT MISMATCH! Expected = %h, Got = %h", expected, trx.out_data))
        else
          `uvm_info("SPN_SB", $sformatf("DECRYPT MATCH! Output = %h", trx.out_data), UVM_MEDIUM);
      end
      default: begin
        `uvm_info("SPN_SB", "Opcode not relevant for scoreboard checking.", UVM_LOW);
      end
    endcase
  end
endtask

endclass

`endif
