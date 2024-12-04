`ifndef AHB_MONITOR_IN__SV
`define AHB_MONITOR_IN__SV

class ahb_monitor_in extends uvm_monitor;

    virtual ahb_if vif;
    uvm_analysis_port #(ahb_transaction)  ap;

    `uvm_component_utils(ahb_monitor_in)
    function new(string name = "ahb_monitor_in",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", vif))
            `uvm_fatal("ahb_monitor_in", "virtual interface must be set for vif !!!");
        ap = new("ap", this);
    endfunction

    extern task main_phase(uvm_phase phase);
    extern task collect_one_pkt(ahb_transaction tr);
endclass

task ahb_monitor_in::main_phase(uvm_phase phase);
    ahb_transaction tr;
    @(posedge vif.hresetn);
    while(1) begin
        tr = new("tr");
        collect_one_pkt(tr);
        ap.write(tr);
//        `uvm_info("ahb_monitor_in", "transaction", UVM_LOW);
//        tr.print();
    end
endtask

task ahb_monitor_in::collect_one_pkt(ahb_transaction tr);

    while(1) begin
        if(vif.din_vld_i && vif.din_rdy_o) break;
        @(posedge vif.hclk);
    end

    if(vif.din_vld_i && vif.din_rdy_o) begin
        tr.din_vld_i    = vif.din_vld_i;
        tr.wr_en_i      = vif.wr_en_i;
        tr.rd_en_i      = vif.rd_en_i;
        tr.data_size_i  = vif.data_size_i;
        tr.addr_i       = vif.addr_i;
        tr.wdata_i      = vif.wdata_i;
    end
    @(posedge vif.hclk);

endtask

`endif


