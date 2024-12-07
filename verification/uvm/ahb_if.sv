`ifndef AHB_IF__SV
`define AHB_IF__SV

interface ahb_if(input hclk, input hresetn);

    logic                       din_vld_i;
    logic                       din_rdy_o;
    logic                       wr_en_i;
    logic                       rd_en_i;
    logic [2:0]                 data_size_i;
    logic [31:0]                addr_i;
    logic [31:0]                wdata_i;
    logic [2:0]                 burst_i;// 0: single, 1: incr, 2: wrap4, 3: incr4, 4: wrap8, 5: incr8, 6: wrap16, 7: incr16

    logic                       dout_vld_o;
    logic [31:0]                rdata_o;
    logic                       dout_rdy_i;

endinterface

`endif
