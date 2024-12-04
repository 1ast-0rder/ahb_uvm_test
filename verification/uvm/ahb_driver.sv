`ifndef AHB_DRIVER__SV
`define AHB_DRIVER__SV

class ahb_driver extends uvm_driver#(ahb_transaction);

    virtual ahb_if  vif;
    driver_cmd_t    driver_cmd;
    driver_cmd_t    driver_cmd_tmp;
    driver_cmd_t    driver_cmd_queue[$];
    static  bit     last_read_cmd;

    `uvm_component_utils(ahb_driver)

    function new(string name = "ahb_driver", uvm_component parent = null);
        super.new(name, parent);
        last_read_cmd = 1'b0;
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", vif)) begin
            `uvm_fatal("ahb_driver", "virtual interface must be set for vif!!!")
        end
    endfunction

    extern task main_phase(uvm_phase phase);
    extern task drive_one_pkt(ahb_transaction tr);
endclass

task ahb_driver::main_phase(uvm_phase phase);
    vif.din_vld_i       <= 1'b0;
    vif.wr_en_i         <= 1'b0;
    vif.rd_en_i         <= 1'b0;
    vif.data_size_i     <= 3'b0;
    vif.addr_i          <= 32'b0;
    vif.wdata_i         <= 32'b0;

    vif.dout_rdy_i      <= 1'b0;

    while(!vif.hresetn) begin
        @(posedge vif.hclk);
    end
    repeat(10) @(posedge vif.hclk);
    
    while(1) begin
        seq_item_port.get_next_item(req);
//      `uvm_info("ahb_driver", "get item", UVM_LOW);
//      req.print();
        if(req.din_vld_i) begin
            driver_cmd.wr_en    = req.wr_en_i;
            driver_cmd.rd_en    = req.rd_en_i;
            driver_cmd.data_size= req.data_size_i;
            driver_cmd.addr     = req.addr_i;
            driver_cmd.wdata    = req.wdata_i;
            driver_cmd_queue.push_back(driver_cmd);
        end
        seq_item_port.item_done();
        drive_one_pkt(req);
    end
endtask


task ahb_driver::drive_one_pkt(ahb_transaction tr);
    if(vif.din_rdy_o) begin
        if(driver_cmd_queue.size() > 0) begin
            driver_cmd_tmp = driver_cmd_queue.pop_front();
            if(last_read_cmd && driver_cmd_tmp.rd_en) begin
                driver_cmd_queue.push_front(driver_cmd_tmp);
                vif.din_vld_i   <= 1'b0;
                vif.wr_en_i     <= 1'b0;
                vif.rd_en_i     <= 1'b0;
                vif.data_size_i <= 3'b0;
                vif.addr_i      <= 32'b0;
                vif.wdata_i     <= 32'b0;
            end else begin
                vif.din_vld_i   <= 1'b1;
                vif.wr_en_i     <= driver_cmd_tmp.wr_en;
                vif.rd_en_i     <= driver_cmd_tmp.rd_en;
                vif.data_size_i <= driver_cmd_tmp.data_size;
                vif.addr_i      <= driver_cmd_tmp.addr;
                vif.wdata_i     <= driver_cmd_tmp.wdata;
            end
        end else begin
            vif.din_vld_i   <= 1'b0;
            vif.wr_en_i     <= 1'b0;
            vif.rd_en_i     <= 1'b0;
            vif.data_size_i <= 3'b0;
            vif.addr_i      <= 32'b0;
            vif.wdata_i     <= 32'b0;
        end
    end else begin
        vif.din_vld_i       <= 1'b0;
        vif.wr_en_i         <= 1'b0;
        vif.rd_en_i         <= 1'b0;
        vif.data_size_i     <= 3'b0;
        vif.addr_i          <= 32'b0;
        vif.wdata_i         <= 32'b0;
    end
    vif.dout_rdy_i          <= tr.dout_rdy_i;
    @(posedge vif.hclk);
    if(vif.dout_vld_o && vif.dout_rdy_i) begin
        last_read_cmd = 1'b0;
    end
    if(vif.din_vld_i && vif.din_rdy_o && vif.rd_en_i) begin
        last_read_cmd = 1'b1;
    end
endtask

`endif

