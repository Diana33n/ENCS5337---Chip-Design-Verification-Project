`timescale 1ns/1ps
`include "spn_if.sv"
`include "spn_test.sv"

module testbench;

  logic clk = 0;
  logic reset;

  always #5 clk = ~clk;

  spn_if intf(clk, reset);

  spn_cu dut (
    .clk      (intf.clk),
    .reset    (intf.reset),
    .opcode   (intf.opcode),
    .in_data  (intf.in_data),
    .key      (intf.key),
    .out_data (intf.out_data),
    .valid    (intf.valid)
  );

  initial begin
    uvm_config_db#(virtual spn_if.DRIVER)::set(null, "uvm_test_top.env.agent.drv", "vif", intf);
    uvm_config_db#(virtual spn_if.MONITOR)::set(null, "uvm_test_top.env.agent.mon", "vif", intf);
    run_test("spn_test");
  end

  initial begin
    reset = 1;
    repeat (2) @(posedge clk);
    reset = 0;
  end

endmodule
