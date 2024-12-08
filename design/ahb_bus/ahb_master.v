module ahb_master # (
    parameter AHB_ADDR_WIDTH        = 32
)
(
    input                           hclk,           // AHB 时钟信号
    input                           hresetn,        // AHB 复位信号，低电平有效
// 这里认为，在burst传输时，仿真接口只提供一次相应的地址和控制信号，后面不valid，只需要提供对应的数据就可以了
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
    // burst相关
    input  [2:0]                    burst_i,        // 突发类型输入信号


    output  [3:0]                hprot_o,           // 保护控制输出信号
    output reg [2:0]                hburst_o,          // 突发类型输出信号
    output                       hmastlock_o,       // 主锁输出信号
    output reg [1:0]                htrans_o,          // 传输类型输出信号
    output reg [2:0]                hsize_o,           // 传输大小输出信号
    output reg [31:0]               haddr_o,           // 地址输出信号
    output reg                      hwrite_o,          // 写使能输出信号
    output reg [31:0]               hwdata_o,          // 写数据输出信号

    input                           hreadyout_i,    // 准备好输出输入信号
    input  [31:0]                   hrdata_i,       // 读数据输入信号
    input  [1:0]                    hresp_i         // 响应输入信号
);

localparam BST_SINGLE   = 3'b000;
localparam BST_INCR     = 3'b001;
localparam BST_WRAP4    = 3'b010;
localparam BST_INCR4    = 3'b011;
localparam BST_WRAP8    = 3'b100;
localparam BST_INCR8    = 3'b101;
localparam BST_WRAP16   = 3'b110;
localparam BST_INCR16    = 3'b111;

localparam TRANS_IDLE   = 2'b00;
localparam TRANS_BUSY   = 2'b01;
localparam TRANS_NONSEQ = 2'b10;
localparam TRANS_SEQ    = 2'b11;

localparam SIZE_BYTE = 3'b000;//1
localparam SIZE_HWORD = 3'b001;//2
localparam SIZE_WORD = 3'b010;//4

// 标准的
// localparam ST_IDLE      = 4'b0001;
// localparam ST_BUSY      = 4'b0010;
// localparam ST_NONSEQ    = 4'b0100;
// localparam ST_SEQ       = 4'b1000;

// 简化版状态机
localparam ST_IDLE  = 2'b00;
localparam ST_TRANS = 2'b01;

reg     [1:0] trans_state;
reg    [1:0] trans_state_n;

reg [4:0] remain_beat;



wire            write_cmd_w;       // 写命令信号
wire            read_cmd_w;        // 读命令信号
// wire cmd_w; 
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
assign write_cmd_w  = din_rdy_o & wr_en_i;
assign read_cmd_w   = din_rdy_o & rd_en_i;
// assign cmd_w = write_cmd_w | read_cmd_w;
always @(posedge hclk or negedge hresetn)
if(~hresetn) begin
    wdata_r <= 32'b0;
end else if(write_cmd_w) begin
    wdata_r <= wdata_w;
end else if(hreadyout_i & (hresp_i == 2'b00)) begin
    wdata_r <= 32'b0;
end
else
    wdata_r <= wdata_r;

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

// burst相关


//一个状态机控制传输，主要是burst传输用到
always @(posedge hclk or negedge hresetn)
begin
if(~hresetn) begin
    trans_state <= ST_IDLE;
end
else begin
    trans_state <= trans_state_n;
end
end

// 状态转移
always @(*)
begin
    case(trans_state)
        ST_IDLE: begin
            if(din_vld_i)
                trans_state_n = ST_TRANS;
            else
                trans_state_n = ST_IDLE;
        end
        ST_TRANS: begin
            if(remain_beat==0 && din_vld_i==0)
                trans_state_n = ST_IDLE;
            else
                trans_state_n = ST_TRANS;
        end
        default: begin 
            trans_state_n = ST_IDLE;
        end
    endcase
end

// 传输beat计数
always @(posedge hclk or negedge hresetn)
begin
    if(~hresetn) begin
        remain_beat <= 0;
    end
    else begin
        if(din_vld_i) begin
            case(burst_i)
                BST_SINGLE: begin
                    remain_beat <= 5'b00000;
                end
                BST_INCR: begin
                    remain_beat <= 5'b10000;
                end
                BST_WRAP4: begin
                    remain_beat <= 5'b00011;
                end
                BST_INCR4: begin
                    remain_beat <= 5'b00011;
                end
                BST_WRAP8: begin
                    remain_beat <= 5'b00111;
                end
                BST_INCR8: begin
                    remain_beat <= 5'b00111;
                end
                BST_WRAP16: begin
                    remain_beat <= 5'b01111;
                end
                BST_INCR16: begin
                    remain_beat <= 5'b01111;
                end
                default: begin
                    remain_beat <= 0;
                end
            endcase
        end
        // 1. burst还需要继续传输
        // 2.3. 从设备输出无错误
        // 4. 未定义长度的递增突发，INCR
        else if(remain_beat>0 && hreadyout_i==1 && hresp_i==0 && remain_beat[4]!=1) begin
            remain_beat <= remain_beat - 1;
        end
        else
            remain_beat <= remain_beat;
    end
end

// 控制HTRANS
always @(*)
begin
    if(din_vld_i==1)
        htrans_o = TRANS_NONSEQ;
    else if(remain_beat>0)
        htrans_o = TRANS_SEQ;
    else
        htrans_o = TRANS_IDLE;
    // 这里没有实现TRANS_BUSY
end


// 控制HADDR
reg [2:0] size_r;
wire [2:0] size; 
reg [2:0] size_w;
always @(*)
begin
    case(data_size_i)
        SIZE_BYTE: begin
            size_w = 3'b001;
        end
        SIZE_HWORD: begin
            size_w = 3'b010;
        end
        SIZE_WORD: begin
            size_w = 3'b100;
        end
        default: begin
            size_w = 3'b000;
        end
    endcase
end                                    

always @(posedge hclk or negedge hresetn)
begin
    if(~hresetn)
        size_r <= 3'b000;
    else if(din_vld_i)
        case(data_size_i)
            SIZE_BYTE: begin
                size_r <= 3'b001;
            end
            SIZE_HWORD: begin
                size_r <= 3'b010;
            end
            SIZE_WORD: begin
                size_r <= 3'b100;
            end
            default: begin
                size_r <= 3'b000;
            end
        endcase
    else
        size_r <= size_r;
end  

assign size = (din_vld_i==1)?size_w:size_r;

reg [2:0] burst_r;
always @(posedge hclk or negedge hresetn)           
    begin                                        
        if(!hresetn)                               
            burst_r <= 3'b000;                                   
        else if(din_vld_i)                                
            burst_r <= burst_i;                            
        else                
            burst_r <= burst_r;                     
    end                                          

reg [5:0] beats;
always @(*)
begin
    case (burst_r)
        BST_SINGLE: begin
            beats = 6'b000001;
        end
        BST_INCR: begin
            beats = 6'b100000;
        end
        BST_WRAP4: begin
            beats = 6'b000100;
        end
        BST_INCR4: begin
            beats = 6'b000100;
        end
        BST_WRAP8: begin
            beats = 6'b001000;
        end
        BST_INCR8: begin
            beats = 6'b001000;
        end
        BST_WRAP16: begin
            beats = 6'b010000;
        end
        BST_INCR16: begin
            beats = 6'b010000;
        end
        default: beats = 6'b000000;
    endcase
end

reg [8:0] wrap_boundary;
always @(*)
begin
    case (size)
        3'b001: begin
            wrap_boundary = beats;
        end
        3'b010: begin
            wrap_boundary = {beats, 1'b0};
        end
        3'b100: begin
            wrap_boundary = {beats, 2'b00};
        end
        default: wrap_boundary = 9'b000000000;
    endcase
end

reg [31:0] addr_r;
always @(posedge hclk or negedge hresetn)
begin
    if (!hresetn)
        addr_r <= 32'b0;
    else if (din_vld_i&&burst_i!=BST_SINGLE)
        addr_r <= addr_i + size;
    else if (din_rdy_o && (burst_r[0]==1) && (remain_beat > 0))// incr
        addr_r <= addr_r + size;
    else if (din_rdy_o && (burst_r[0]==0) && (remain_beat > 0) && burst_r!=BST_SINGLE)// wrap
        addr_r <= (((addr_r)&(wrap_boundary))==((addr_r + size)&(wrap_boundary)))?(addr_r + size):(addr_r+size-wrap_boundary);
    else
        addr_r <= addr_r;
end

always @(*)
begin
    if(din_vld_i==1||hreadyout_i==0)
        haddr_o = addr_i;
    else
        haddr_o = addr_r; 
end  

// 控制HWRITE
reg wr_r;
always @(posedge hclk or negedge hresetn)           
    begin                                        
        if(!hresetn)                               
            wr_r<= 1'b0;                                
        else if(din_vld_i)                                
            wr_r<=wr_en_i;                
        else      
            wr_r<=wr_r;                               
    end       
                                    

always @(*)
begin
    if(din_vld_i==1)
        hwrite_o = wr_en_i;
    else
        hwrite_o = wr_r;
end

// 控制HBURST
// assign hburst_o = (cmd_w==1)?burst_i:burst_r;
always @(*)
begin
    if(din_vld_i==1)
        hburst_o = burst_i;
    else
        hburst_o = burst_r;
end
// 控制HSIZE

reg [2:0] data_size_r;
always @(posedge hclk or negedge hresetn)
begin
    if (!hresetn)
        data_size_r <= 3'b000;
    else if (din_vld_i)
        data_size_r <= data_size_i;
    else
        data_size_r <= data_size_r;
end

// assign hsize_o = (cmd_w==1)?data_size_i:data_size_r;
always @(*)
begin
    if(din_vld_i==1)
        hsize_o = data_size_i;
    else
        hsize_o = data_size_r;
end
// 控制HPORT
assign hprot_o = 4'b0000;
// always @(*)
// begin
//     hprot_o = 4'b0000;
// end                                         
// 控制HWDATA
// assign hwdata_o = wdata_r;
always @(*)
begin
    hwdata_o = wdata_r;
end

// 控制HMASTLOCK
assign hmastlock_o = 1'b0;
// always @(*)
// begin
//     hmastlock_o = 1'b0;
// end


// // assign haddr_o      = addr_i;
// assign haddr_o = ;
// assign hwrite_o     = write_cmd_w ? 1'b1 : 1'b0;
// assign hwdata_o     = wdata_r;

// assign hsize_o      = data_size_i;
// assign htrans_o     = 2'b10;
// // 要改
// assign hprot_o      = 4'b0;
// assign hburst_o     = burst_i;
// assign hmastlock_o  = 1'b0;

endmodule

