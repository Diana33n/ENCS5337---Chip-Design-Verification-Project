`ifndef SPN_SEQ_ITEM_SV
`define SPN_SEQ_ITEM_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class spn_seq_item extends uvm_sequence_item;

  rand logic [1:0] opcode;
  rand logic [15:0] in_data;
  rand logic [31:0] key;
       logic [15:0] out_data;
       logic [1:0] valid;
//   constraint valid_opcode { opcode inside {2'b00, 2'b01, 2'b10, 2'b11}; }
//   constraint in_data_range { in_data inside {[16'h0000:16'hFFFF]}; }
//   constraint key_range { key inside {[32'h00000000:32'hFFFFFFFF]}; }

  `uvm_object_utils_begin(spn_seq_item)
    `uvm_field_int(opcode,   UVM_ALL_ON)
    `uvm_field_int(in_data,  UVM_ALL_ON)
    `uvm_field_int(key,      UVM_ALL_ON)
    `uvm_field_int(out_data, UVM_ALL_ON)
    `uvm_field_int(valid,    UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "spn_seq_item");
    super.new(name);
  endfunction

endclass

`endif
