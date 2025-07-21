interface spn_if(input logic clk, input logic reset);

  logic [1:0] opcode;
  logic [15:0] in_data;
  logic [31:0] key;
  logic [15:0] out_data;
  logic [1:0] valid;

  // Driver and Monitor modports
  modport DRIVER (
    output opcode, 
    output in_data, 
    output key, 
    input out_data,   
    input valid,     
    input clk, 
    input reset
  );

  modport MONITOR (
    input opcode, 
    input in_data, 
    input key, 
    input out_data, 
    input valid, 
    input clk
  );

endinterface
