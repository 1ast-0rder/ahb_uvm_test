
typedef struct {
    logic                       din_vld_i;
    logic                       wr_en;
    logic                       rd_en;
    logic [2:0]                 data_size;
    logic [31:0]                addr;
    logic [31:0]                wdata;
    logic [2:0]                 burst;
} driver_cmd_t;


