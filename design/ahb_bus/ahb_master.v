module ahb_master # (
    parameter AHB_ADDR_WIDTH        = 32
)
(
    input                           hclk,           // AHB 时钟信号
    input                           hresetn,        // AHB 复位信号，低电平有效

    input                           din_vld_i,      // 数据输入有效信号
    output                          din_rdy_o,      // 数据输入准备好信号
    input                           wr_en_i,        // 写使能输入信号
    input                           rd_en_i,        // 读使能输入信号
    input  [2:0]                    data_size_i,    // 数据大小输入信号
    input  [31:0]                   addr_i,         // 地址输入信号
    input  [31:0]                   wdata_i,        // 写数据输入信号
    output                          dout_vld_o,     // 数据输出有效信号
    output [31:0]                   rdata_o,        // 读数据输出信号
    input                           dout_rdy_i,     // 数据输出准备好信号

    output  [3:0]                hprot_o,           // 保护控制输出信号
    output  [2:0]                hburst_o,          // 突发类型输出信号
    output                       hmastlock_o,       // 主锁输出信号
    output  [1:0]                htrans_o,          // 传输类型输出信号
    output  [2:0]                hsize_o,           // 传输大小输出信号
    output  [31:0]               haddr_o,           // 地址输出信号
    output                       hwrite_o,          // 写使能输出信号
    output  [31:0]               hwdata_o,          // 写数据输出信号

    input                           hreadyout_i,    // 准备好输出输入信号
    input  [31:0]                   hrdata_i,       // 读数据输入信号
    input  [1:0]                    hresp_i         // 响应输入信号
);

wire            write_cmd_w;       // 写命令信号
wire            read_cmd_w;        // 读命令信号
reg  [31:0]     wdata_w;           // 写数据寄存器
reg  [31:0]     wdata_r;           // 写数据寄存器
reg             read_cmd_r;        // 读命令寄存器
reg  [31:0]     read_addr_r;       // 读地址寄存器
reg  [31:0]     hrdata_r;          // 读数据寄存器
wire [31:0]     hrdata_w;          // 读数据信号
reg  [31:0]     rdata_w;           // 读数据寄存器
reg  [31:0]     rdata_r;           // 读数据寄存器
reg             read_vld_r;        // 读有效寄存器
wire            read_vld_w;        // 读有效信号
wire [31:0]     rdataout_w;        // 读数据输出信号
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

