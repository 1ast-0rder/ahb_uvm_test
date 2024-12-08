`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "typedef.sv"
`include "ahb_if.sv"
`include "ahb_transaction.sv"
`include "ahb_transaction_out.sv"
`include "ahb_sequencer.sv"
`include "ahb_driver.sv"
`include "ahb_monitor_in.sv"
`include "ahb_monitor_out.sv"
`include "ahb_agent_in.sv"
`include "ahb_agent_out.sv"
`include "ahb_model.sv"
`include "ahb_scoreboard.sv"
`include "ahb_sequence.sv"
`include "ahb_env.sv"
`include "base_test.sv"
`include "testcase.sv"

module tb_ahb_bus;

logic                           hclk;
logic                           hresetn;

ahb_if  ahb_vif(hclk, hresetn);

ahb_bus u_ahb_bus
(
    .hclk                       (hclk                   ),
    .hresetn                    (hresetn                ),

    .din_vld_i                  (ahb_vif.din_vld_i      ),
    .din_rdy_o                  (ahb_vif.din_rdy_o      ),
    .wr_en_i                    (ahb_vif.wr_en_i        ),
    .rd_en_i                    (ahb_vif.rd_en_i        ),
    .data_size_i                (ahb_vif.data_size_i    ),
    .addr_i                     (ahb_vif.addr_i         ),
    .wdata_i                    (ahb_vif.wdata_i        ),
    .burst_i                    (ahb_vif.burst_i        ),
    .dout_vld_o                 (ahb_vif.dout_vld_o     ),
    .rdata_o                    (ahb_vif.rdata_o        ),
    .dout_rdy_i                 (ahb_vif.dout_rdy_i     )
);

// hclk, hresetn
int half_cycle = 1;
initial begin
    hclk = 0;
    forever begin
        #half_cycle hclk = ~hclk;
    end
end
initial begin
    hresetn = 1'b0;
    #25 hresetn = 1'b1;
end
// initial mem
initial begin
    for(int i=0;i<=14'h3fff;i=i+1) begin
        u_ahb_bus.u_ahb_slave0.mem[i] = 32'hffffffff;
        u_ahb_bus.u_ahb_slave1.mem[i] = 32'hffffffff;
        u_ahb_bus.u_ahb_slave2.mem[i] = 32'hffffffff;
        u_ahb_bus.u_ahb_slave3.mem[i] = 32'hffffffff;
    end
end

// run uvm
initial begin
    uvm_root::get().set_timeout(300, 1);  // 设置仿真超时为 10us，1 表示强制终止
    run_test();
end

initial begin
  uvm_config_db#(virtual ahb_if)::set(null,"uvm_test_top.env.i_agt.drv","ahb_vif",ahb_vif);
  uvm_config_db#(virtual ahb_if)::set(null,"uvm_test_top.env.i_agt.mon_in","ahb_vif",ahb_vif);
  uvm_config_db#(virtual ahb_if)::set(null,"uvm_test_top.env.o_agt.mon_out","ahb_vif",ahb_vif);
  uvm_config_db#(virtual ahb_if)::set(null,"uvm_test_top.env.o_agt.mon_out","ahb_vif",ahb_vif);
end

initial begin
`ifdef FSDB
    //$fsdbDumpfile("test.fsdb");
    $fsdbAutoSwitchDumpfile(10000,"test.fsdb",100);
    $fsdbDumpvars(0, `TB_TOP,"+all");
`ifdef DUMP_MDA
    $fsdbDumpMDA();
`endif
`endif
    #10s;
    $finish;
end


endmodule


