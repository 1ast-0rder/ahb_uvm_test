`ifndef AHB_TRANSACTION__SV
`define AHB_TRANSACTION__SV

class ahb_transaction extends uvm_sequence_item;

    logic                       din_vld_i;
    logic                       wr_en_i;
    logic                       rd_en_i;
    logic [2:0]                 data_size_i;
    logic [31:0]                addr_i;
    logic [31:0]                wdata_i;
    logic                       dout_rdy_i;

    function new(string name = "ahb_transaction");
        super.new();
    endfunction

    `uvm_object_utils_begin(ahb_transaction)
        `uvm_field_int(din_vld_i            , UVM_ALL_ON)
        `uvm_field_int(wr_en_i              , UVM_ALL_ON)
        `uvm_field_int(rd_en_i              , UVM_ALL_ON)
        `uvm_field_int(data_size_i          , UVM_ALL_ON)
        `uvm_field_int(addr_i               , UVM_ALL_ON)
        `uvm_field_int(wdata_i              , UVM_ALL_ON)
        `uvm_field_int(dout_rdy_i           , UVM_ALL_ON)
    `uvm_object_utils_end

endclass
`endif


