module ahb_slave3 #(
    parameter ADDR_WIDTH        = 16
)
(
    input                       hclk,
    input                       hresetn, 

    input                       hsel_i,
    input                       hready_i,
    input  [1:0]                htrans_i,
    input  [2:0]                hsize_i,
    input                       hwrite_i,
    input  [ADDR_WIDTH-1:0]     haddr_i,
    input  [31:0]               hwdata_i,
    output                      hready_o,
    output [1:0]                hresp_o,
    output [31:0]               hrdata_o
);

wire                            ahb_access_w;
wire                            ahb_write_w;
wire                            ahb_read_w;
wire                            ahb_byte_w;
wire                            ahb_half_w;
wire                            ahb_word_w;
wire                            byte_at_00_w;
wire                            byte_at_01_w;
wire                            byte_at_10_w;
wire                            byte_at_11_w;
wire                            half_at_00_w;
wire                            half_at_10_w;
wire                            word_at_00_w;
wire [3:0]                      byte_sel_w;

reg                             ahb_write_r;
reg                             ahb_read_r;
reg  [3:0]                      byte_sel_r;
reg  [ADDR_WIDTH-3:0]           ahb_addr_r;

assign ahb_access_w     = htrans_i[1] & hsel_i & hready_i;
assign ahb_write_w      = ahb_access_w & hwrite_i;
assign ahb_read_w       = ahb_access_w & (~hwrite_i);
assign ahb_byte_w       = (hsize_i == 3'b000);
assign ahb_half_w       = (hsize_i == 3'b001);
assign ahb_word_w       = (hsize_i == 3'b010);
assign byte_at_00_w     = ahb_byte_w & (haddr_i[1:0]==2'b00);
assign byte_at_01_w     = ahb_byte_w & (haddr_i[1:0]==2'b01);
assign byte_at_10_w     = ahb_byte_w & (haddr_i[1:0]==2'b10);
assign byte_at_11_w     = ahb_byte_w & (haddr_i[1:0]==2'b11);
assign half_at_00_w     = ahb_half_w & (~haddr_i[1]);
assign half_at_10_w     = ahb_half_w & haddr_i[1];
assign word_at_00_w     = ahb_word_w;

assign byte_sel_w[0]    = (word_at_00_w | half_at_00_w | byte_at_00_w) & ahb_access_w;
assign byte_sel_w[1]    = (word_at_00_w | half_at_00_w | byte_at_01_w) & ahb_access_w;
assign byte_sel_w[2]    = (word_at_00_w | half_at_10_w | byte_at_10_w) & ahb_access_w;
assign byte_sel_w[3]    = (word_at_00_w | half_at_10_w | byte_at_11_w) & ahb_access_w;

always @(posedge hclk or negedge hresetn)
if(~hresetn) begin
    ahb_write_r <= 1'b0;
    ahb_read_r  <= 1'b0;
    byte_sel_r  <= 4'b0;
end else begin
    ahb_write_r <= ahb_write_w;
    ahb_read_r  <= ahb_read_w;
    byte_sel_r  <= byte_sel_w;
end

always @(posedge hclk or negedge hresetn)
if(~hresetn)
    ahb_addr_r  <= 'b0;
else if(ahb_access_w)
    ahb_addr_r  <= haddr_i[ADDR_WIDTH-1:2];

reg [31:0] mem [16383:0];
reg [31:0] rdata_w;
reg        ahb_read_dly_r;

/////////////////////////////////////////////////AHB Write REG
always @(posedge hclk)
if(ahb_write_r) begin
    if(byte_sel_r[0])
        mem[ahb_addr_r][7:0]   <= hwdata_i[7:0];
    if(byte_sel_r[1])
        mem[ahb_addr_r][15:8]  <= hwdata_i[15:8];
    if(byte_sel_r[2])
        mem[ahb_addr_r][23:16] <= hwdata_i[23:16];
    if(byte_sel_r[3])
        mem[ahb_addr_r][31:24] <= hwdata_i[31:24];
end

/////////////////////////////////////////////////AHB Read REG
always @(*) begin
    if(ahb_read_dly_r) begin
        rdata_w = mem[ahb_addr_r];
    end else begin
        rdata_w = 32'b0;
    end
end

always @(posedge hclk or negedge hresetn)
if(~hresetn)
    ahb_read_dly_r <= 1'b0;
else if(ahb_read_r)
    ahb_read_dly_r <= 1'b1;
else
    ahb_read_dly_r <= 1'b0;

assign hready_o     = (ahb_write_r|ahb_read_r) ? 1'b0 : 1'b1;
assign hresp_o      = 2'b0;
assign hrdata_o     = (ahb_write_r|ahb_read_r) ? 32'b0 : rdata_w;

endmodule

