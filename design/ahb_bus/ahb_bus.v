// 添加burst操作，添加brust仿真
// 多主，仲裁
module ahb_bus
(
    input                       hclk,
    input                       hresetn,

    input                       din_vld_i,
    output                      din_rdy_o,
    input                       wr_en_i,
    input                       rd_en_i,
    input  [2:0]                data_size_i,
    input  [31:0]               addr_i,
    input  [31:0]               wdata_i,
    output                      dout_vld_o,
    output [31:0]               rdata_o,
    input                       dout_rdy_i
);

wire  [3:0]                     hprot_w;
wire  [2:0]                     hburst_w;
wire                            hmastlock_w;
wire  [1:0]                     htrans_w;
wire  [2:0]                     hsize_w;
wire  [31:0]                    haddr_w;
wire                            hwrite_w;
wire  [31:0]                    hwdata_w;
wire                            hreadyout_w;
wire  [31:0]                    hrdata_w;
wire  [1:0]                     hresp_w;

wire                            hready_in_w;
wire                            slave0_sel_w;
wire                            slave0_hreadyout_w;
wire  [31:0]                    slave0_hrdata_w;
wire  [1:0]                     slave0_hresp_w;
wire                            slave1_sel_w;
wire                            slave1_hreadyout_w;
wire  [31:0]                    slave1_hrdata_w;
wire  [1:0]                     slave1_hresp_w;
wire                            slave2_sel_w;
wire                            slave2_hreadyout_w;
wire  [31:0]                    slave2_hrdata_w;
wire  [1:0]                     slave2_hresp_w;
wire                            slave3_sel_w;
wire                            slave3_hreadyout_w;
wire  [31:0]                    slave3_hrdata_w;
wire  [1:0]                     slave3_hresp_w;

ahb_master #
(
    .AHB_ADDR_WIDTH             (32                     )
)u_ahb_master
(
    .hclk                       (hclk                   ),
    .hresetn                    (hresetn                ),

    .din_vld_i                  (din_vld_i              ),
    .din_rdy_o                  (din_rdy_o              ),
    .wr_en_i                    (wr_en_i                ),
    .rd_en_i                    (rd_en_i                ),
    .data_size_i                (data_size_i            ),
    .addr_i                     (addr_i                 ),
    .wdata_i                    (wdata_i                ),
    .dout_vld_o                 (dout_vld_o             ),
    .rdata_o                    (rdata_o                ),
    .dout_rdy_i                 (dout_rdy_i             ),

    .hprot_o                    (hprot_w                ),
    .hburst_o                   (hburst_w               ),
    .hmastlock_o                (hmastlock_w            ),
    .htrans_o                   (htrans_w               ),
    .hsize_o                    (hsize_w                ),
    .haddr_o                    (haddr_w                ),
    .hwrite_o                   (hwrite_w               ),
    .hwdata_o                   (hwdata_w               ),

    .hreadyout_i                (hreadyout_w            ),
    .hrdata_i                   (hrdata_w               ),
    .hresp_i                    (hresp_w                )
);

ahb_decoder u_ahb_decoder
(
    .hclk                       (hclk                   ),
    .hresetn                    (hresetn                ),

    .hprot_i                    (hprot_w                ),
    .hburst_i                   (hburst_w               ),
    .hmastlock_i                (hmastlock_w            ),
    .htrans_i                   (htrans_w               ),
    .hsize_i                    (hsize_w                ),
    .haddr_i                    (haddr_w                ),
    .hwrite_i                   (hwrite_w               ),
    .hwdata_i                   (hwdata_w               ),

    .hreadyout_o                (hreadyout_w            ),
    .hrdata_o                   (hrdata_w               ),
    .hresp_o                    (hresp_w                ),

    .hready_in_o                (hready_in_w            ),
    .slave0_sel_o               (slave0_sel_w           ),
    .slave0_hreadyout_i         (slave0_hreadyout_w     ),
    .slave0_hrdata_i            (slave0_hrdata_w        ),
    .slave0_hresp_i             (slave0_hresp_w         ),
    .slave1_sel_o               (slave1_sel_w           ),
    .slave1_hreadyout_i         (slave1_hreadyout_w     ),
    .slave1_hrdata_i            (slave1_hrdata_w        ),
    .slave1_hresp_i             (slave1_hresp_w         ),
    .slave2_sel_o               (slave2_sel_w           ),
    .slave2_hreadyout_i         (slave2_hreadyout_w     ),
    .slave2_hrdata_i            (slave2_hrdata_w        ),
    .slave2_hresp_i             (slave2_hresp_w         ),
    .slave3_sel_o               (slave3_sel_w           ),
    .slave3_hreadyout_i         (slave3_hreadyout_w     ),
    .slave3_hrdata_i            (slave3_hrdata_w        ),
    .slave3_hresp_i             (slave3_hresp_w         )
);

ahb_slave0 #
(
    .ADDR_WIDTH                 (16                     )
)u_ahb_slave0
(
    .hclk                       (hclk                   ),
    .hresetn                    (hresetn                ),
    .hsel_i                     (slave0_sel_w           ),
    .hready_i                   (hready_in_w            ),
    .htrans_i                   (htrans_w               ),
    .hsize_i                    (hsize_w                ),
    .hwrite_i                   (hwrite_w               ),
    .haddr_i                    (haddr_w[15:0]          ),
    .hwdata_i                   (hwdata_w               ),
    .hready_o                   (slave0_hreadyout_w     ),
    .hresp_o                    (slave0_hresp_w         ),
    .hrdata_o                   (slave0_hrdata_w        )
);

ahb_slave1 #
(
    .ADDR_WIDTH                 (16                     )
)u_ahb_slave1
(
    .hclk                       (hclk                   ),
    .hresetn                    (hresetn                ),
    .hsel_i                     (slave1_sel_w           ),
    .hready_i                   (hready_in_w            ),
    .htrans_i                   (htrans_w               ),
    .hsize_i                    (hsize_w                ),
    .hwrite_i                   (hwrite_w               ),
    .haddr_i                    (haddr_w[15:0]          ),
    .hwdata_i                   (hwdata_w               ),
    .hready_o                   (slave1_hreadyout_w     ),
    .hresp_o                    (slave1_hresp_w         ),
    .hrdata_o                   (slave1_hrdata_w        )
);

ahb_slave2 #
(
    .ADDR_WIDTH                 (16                     )
)u_ahb_slave2
(
    .hclk                       (hclk                   ),
    .hresetn                    (hresetn                ),
    .hsel_i                     (slave2_sel_w           ),
    .hready_i                   (hready_in_w            ),
    .htrans_i                   (htrans_w               ),
    .hsize_i                    (hsize_w                ),
    .hwrite_i                   (hwrite_w               ),
    .haddr_i                    (haddr_w[15:0]          ),
    .hwdata_i                   (hwdata_w               ),
    .hready_o                   (slave2_hreadyout_w     ),
    .hresp_o                    (slave2_hresp_w         ),
    .hrdata_o                   (slave2_hrdata_w        )
);

ahb_slave3 #
(
    .ADDR_WIDTH                 (16                     )
)u_ahb_slave3
(
    .hclk                       (hclk                   ),
    .hresetn                    (hresetn                ),
    .hsel_i                     (slave3_sel_w           ),
    .hready_i                   (hready_in_w            ),
    .htrans_i                   (htrans_w               ),
    .hsize_i                    (hsize_w                ),
    .hwrite_i                   (hwrite_w               ),
    .haddr_i                    (haddr_w[15:0]          ),
    .hwdata_i                   (hwdata_w               ),
    .hready_o                   (slave3_hreadyout_w     ),
    .hresp_o                    (slave3_hresp_w         ),
    .hrdata_o                   (slave3_hrdata_w        )
);

endmodule

