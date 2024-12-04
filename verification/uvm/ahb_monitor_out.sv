`ifndef AHB_MONITOR_OUT__SV
`define AHB_MONITOR_OUT__SV

class ahb_monitor_out extends uvm_monitor;

    virtual ahb_if vif;
    logic [31:0]    rd_addr_queue[$];

    uvm_analysis_port #(ahb_transaction_out)  ap;

    `uvm_component_utils(ahb_monitor_out)
    function new(string name = "ahb_monitor_out",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", vif))
            `uvm_fatal("ahb_monitor_out", "virtual interface must be set for vif !!!");
        ap = new("ap", this);
    endfunction

    extern task main_phase(uvm_phase phase);
    extern task collect_one_pkt(ahb_transaction_out tr);
endclass

task ahb_monitor_out::main_phase(uvm_phase phase);

    ahb_transaction_out tr;
    @(posedge vif.hresetn);
    while(1) begin
        tr = new("tr");
        collect_one_pkt(tr);
        ap.write(tr);
     end

endtask


task ahb_monitor_out::collect_one_pkt(ahb_transaction_out tr);

    while(1) begin
        if(vif.din_vld_i && vif.din_rdy_o && vif.rd_en_i) begin
            rd_addr_queue.push_back(vif.addr_i);
        end
        if(vif.dout_vld_o && vif.dout_rdy_i) break;
        @(posedge vif.hclk);
    end

    if(vif.dout_vld_o && vif.dout_rdy_i) begin
        if(rd_addr_queue.size() > 0) begin
            tr.rd_addr  = rd_addr_queue.pop_front();
        end else begin
            `uvm_error("ahb_monitor_out", "rd addr queue is empty !!!");
        end
        tr.rdata    = vif.rdata_o;
    end
    //`uvm_info("ahb_monitor_out : dut_out is ", tr.sprint(), UVM_LOW);
    @(posedge vif.hclk);

endtask

`endif


