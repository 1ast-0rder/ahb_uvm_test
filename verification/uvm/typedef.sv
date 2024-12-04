
typedef struct {
    logic                       wr_en;
    logic                       rd_en;
    logic [2:0]                 data_size;
    logic [31:0]                addr;
    logic [31:0]                wdata;
} driver_cmd_t;


