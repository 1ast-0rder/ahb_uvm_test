module ahb_master # (
    parameter AHB_ADDR_WIDTH        = 32
)
(
    input                           hclk,
    input                           hresetn,

    input                           din_vld_i,
    output                          din_rdy_o,
    input                           wr_en_i,
    input                           rd_en_i,
    input  [2:0]                    data_size_i,
    input  [31:0]                   addr_i,
    input  [31:0]                   wdata_i,
    output                          dout_vld_o,
    output [31:0]                   rdata_o,
    input                           dout_rdy_i,

    output reg [3:0]                hprot_o,
    output reg [2:0]                hburst_o,
    output reg                      hmastlock_o,
    output reg [1:0]                htrans_o,
    output reg [2:0]                hsize_o,
    output reg [31:0]               haddr_o,
    output reg                      hwrite_o,
    output reg [31:0]               hwdata_o,

    input                           hreadyout_i,
    input  [31:0]                   hrdata_i,
    input  [1:0]                    hresp_i
);

wire            write_cmd_w;
wire            read_cmd_w;
reg  [31:0]     wdata_w;
reg  [31:0]     wdata_r;
reg             read_cmd_r;
reg  [31:0]     read_addr_r;
reg  [31:0]     hrdata_r;
wire [31:0]     hrdata_w;
reg  [31:0]     rdata_w;
reg  [31:0]     rdata_r;
reg             read_vld_r;
wire            read_vld_w;
wire [31:0]     rdataout_w;

assign write_cmd_w  = din_vld_i & din_rdy_o & wr_en_i;
assign read_cmd_w   = din_vld_i & din_rdy_o & rd_en_i;

always @(posedge hclk or negedge hresetn)
if(~hresetn) begin
    wdata_r <= 32'b0;
end else if(write_cmd_w) begin
    wdata_r <= wdata_w;
end else if(hreadyout_i & (hresp_i == 2'b00)) begin
    wdata_r <= 32'b0;
end

always @(*) begin
    if(write_cmd_w) begin
        case(addr_i[1:0])
            2'b00: begin
                wdata_w = wdata_i;
            end
            2'b01: begin
                wdata_w = wdata_i<<8;
            end
            2'b10: begin
                wdata_w = wdata_i<<16;
            end
            2'b11: begin
                wdata_w = wdata_i<<24;
            end
            default: begin
                wdata_w = wdata_i;
            end
        endcase
    end else begin
        wdata_w = wdata_i;
    end
end

always @(posedge hclk or negedge hresetn)
if(~hresetn) begin
    read_cmd_r  <= 1'b0;
    read_addr_r <= 32'b0;
end else if(read_cmd_w) begin
    read_cmd_r  <= 1'b1;
    read_addr_r <= addr_i;
end else if(hreadyout_i & (hresp_i == 2'b00) & read_cmd_r) begin
    read_cmd_r  <= 1'b0;
    read_addr_r <= 32'b0;
end

always @(posedge hclk or negedge hresetn)
if(~hresetn) begin
    hrdata_r    <= 32'b0;
end else if(dout_vld_o & (~dout_rdy_i)) begin
    hrdata_r    <= hrdata_i;
end else if(dout_vld_o & dout_rdy_i) begin
    hrdata_r    <= 32'b0;
end
assign hrdata_w = dout_vld_o ? hrdata_i : hrdata_r;

always @(*) begin
    if(hreadyout_i & (hresp_i == 2'b00) & read_cmd_r) begin
        case(read_addr_r[1:0])
            2'b00 : begin
                rdata_w = hrdata_i;
            end
            2'b01 : begin
                rdata_w = hrdata_i>>8;
            end
            2'b10 : begin
                rdata_w = hrdata_i>>16;
            end
            2'b11 : begin
                rdata_w = hrdata_i>>24;
            end
            default : begin
                rdata_w = hrdata_i;
            end
        endcase
    end else begin
        rdata_w = 32'b0;
    end
end

always @(posedge hclk or negedge hresetn)
if(~hresetn) begin
    read_vld_r  <= 1'b0;
    rdata_r     <= 32'b0;
end else if(dout_vld_o && dout_rdy_i) begin
    read_vld_r  <= 1'b0;
    rdata_r     <= 32'b0;
end else if(hreadyout_i & (hresp_i == 2'b00) & read_cmd_r) begin
    read_vld_r  <= 1'b1;
    rdata_r     <= rdata_w;
end
assign read_vld_w   = ((hreadyout_i & (hresp_i == 2'b00) & read_cmd_r) || read_vld_r);
assign rdataout_w   = read_vld_w ? (read_vld_r ? rdata_r : rdata_w) : 32'b0;

assign din_rdy_o    = (hreadyout_i & (hresp_i == 2'b00));
assign dout_vld_o   = read_vld_w;
assign rdata_o      = rdataout_w;

assign haddr_o      = addr_i;
assign hwrite_o     = write_cmd_w ? 1'b1 : 1'b0;
assign hwdata_o     = wdata_r;

assign hsize_o      = data_size_i;
assign htrans_o     = 2'b10;
assign hprot_o      = 4'b0;
assign hburst_o     = 3'b0;
assign hmastlock_o  = 1'b0;

endmodule

