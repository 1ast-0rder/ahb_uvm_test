`ifndef AHB_TRANSACTION_EVENT__SV
`define AHB_TRANSACTION_EVENT__SV

class ahb_transaction_out extends uvm_sequence_item;

    logic [31:0]                rd_addr;
    logic [31:0]                rdata;

    `uvm_object_utils_begin(ahb_transaction_out)
        `uvm_field_int(rd_addr  , UVM_ALL_ON )
        `uvm_field_int(rdata    , UVM_ALL_ON /*| UVM_NOCOMPARE | UVM_NOPRINT*/)
    `uvm_object_utils_end

    function new(string name = "ahb_transaction_out");
        super.new();
    endfunction

endclass
`endif


