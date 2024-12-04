module ahb_decoder
(
    input                           hclk,
    input                           hresetn,

    input  [3:0]                    hprot_i,
    input  [2:0]                    hburst_i,
    input  [2:0]                    hsize_i,
    input  [1:0]                    htrans_i,
    input                           hmastlock_i,
    input  [31:0]                   haddr_i,
    input                           hwrite_i,
    input  [31:0]                   hwdata_i,

    output                          hreadyout_o,
    output [31:0]                   hrdata_o,
    output [1:0]                    hresp_o,

    output                          hready_in_o,

    output                          slave0_sel_o,
    input                           slave0_hreadyout_i,
    input  [31:0]                   slave0_hrdata_i,
    input  [1:0]                    slave0_hresp_i,

    output                          slave1_sel_o,
    input                           slave1_hreadyout_i,
    input  [31:0]                   slave1_hrdata_i,
    input  [1:0]                    slave1_hresp_i,

    output                          slave2_sel_o,
    input                           slave2_hreadyout_i,
    input  [31:0]                   slave2_hrdata_i,
    input  [1:0]                    slave2_hresp_i,

    output                          slave3_sel_o,
    input                           slave3_hreadyout_i,
    input  [31:0]                   slave3_hrdata_i,
    input  [1:0]                    slave3_hresp_i    
);

localparam  SLAVE0_START_ADDR      = 32'h0000_0000;
localparam  SLAVE0_END_ADDR        = 32'h0000_ffff;
localparam  SLAVE1_START_ADDR      = 32'h0001_0000;
localparam  SLAVE1_END_ADDR        = 32'h0001_ffff;
localparam  SLAVE2_START_ADDR      = 32'h0002_0000;
localparam  SLAVE2_END_ADDR        = 32'h0002_ffff;
localparam  SLAVE3_START_ADDR      = 32'h0003_0000;
localparam  SLAVE3_END_ADDR        = 32'h0003_ffff;

wire                slave0_sel_w;
wire                slave1_sel_w;
wire                slave2_sel_w;
wire                slave3_sel_w;

reg  [3:0]          hsel_mux_r;
reg                 hreadyout_w;
reg  [1:0]          hresp_w;
reg  [31:0]         hrdata_w;

assign slave0_sel_w = ((SLAVE0_START_ADDR <= haddr_i) && (haddr_i <= SLAVE0_END_ADDR));
assign slave1_sel_w = ((SLAVE1_START_ADDR <= haddr_i) && (haddr_i <= SLAVE1_END_ADDR));
assign slave2_sel_w = ((SLAVE2_START_ADDR <= haddr_i) && (haddr_i <= SLAVE2_END_ADDR));
assign slave3_sel_w = ((SLAVE3_START_ADDR <= haddr_i) && (haddr_i <= SLAVE3_END_ADDR));

always @(posedge hclk or negedge hresetn)
if(~hresetn)
    hsel_mux_r <= 4'b0;
else if(hreadyout_w)
    hsel_mux_r <= {slave3_sel_w,slave2_sel_w,slave1_sel_w,slave0_sel_w};

always @(*) begin
    case(hsel_mux_r)
        4'b0001: begin
            hreadyout_w = slave0_hreadyout_i;
            hresp_w     = slave0_hresp_i;
            hrdata_w    = slave0_hrdata_i;
        end
        4'b0010: begin
            hreadyout_w = slave1_hreadyout_i;
            hresp_w     = slave1_hresp_i;
            hrdata_w    = slave1_hrdata_i;
        end
        4'b0100: begin
            hreadyout_w = slave2_hreadyout_i;
            hresp_w     = slave2_hresp_i;
            hrdata_w    = slave2_hrdata_i;
        end
        4'b1000: begin
            hreadyout_w = slave3_hreadyout_i;
            hresp_w     = slave3_hresp_i;
            hrdata_w    = slave3_hrdata_i;
        end
        default: begin
            hreadyout_w = 1'b1;
            hresp_w     = 2'b0;
            hrdata_w    = 32'hDEAD_BEEF;
        end
    endcase
end

assign hreadyout_o  = hreadyout_w;
assign hrdata_o     = hrdata_w;
assign hresp_o      = hresp_w;

assign hready_in_o  = hreadyout_w;

assign slave0_sel_o = slave0_sel_w;
assign slave1_sel_o = slave1_sel_w;
assign slave2_sel_o = slave2_sel_w;
assign slave3_sel_o = slave3_sel_w;

endmodule

