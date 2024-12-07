`ifndef AHB_MODEL__SV
`define AHB_MODEL__SV

class ahb_model extends uvm_component;

    logic [7:0] memory[logic[31:0]];
    ahb_transaction         drv_in;
    ahb_transaction_out     model_out;
    static bit [31:0]       mem_addr;
    static bit [31:0]       mem_data;

    uvm_blocking_get_port #(ahb_transaction)     port;
    uvm_analysis_port #(ahb_transaction_out)     ap;


    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern virtual  task main_phase(uvm_phase phase);

    task initial_mem;
        for(int i=0;i<32'h00040000;i=i+1) begin
            memory[i]=8'hff;
        end
    endtask

    `uvm_component_utils(ahb_model)
endclass 

function ahb_model::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void ahb_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
    ap = new("ap", this);
endfunction

task ahb_model::main_phase(uvm_phase phase);
    super.main_phase(phase);

    initial_mem;
    #1;
    while(1) begin
        port.get(drv_in);
        model_out = new("model_out");

        if(drv_in.din_vld_i) begin
            if(drv_in.wr_en_i) begin
                if(drv_in.addr_i >= 32'h0004_0000) begin
                    `uvm_info("ahb_moedl", $sformatf("write addr 0x%0h over boundary ",drv_in.addr_i), UVM_LOW);
                end else begin
                    case(drv_in.data_size_i)
                        3'd0: begin
                            mem_addr = drv_in.addr_i;
                            memory[mem_addr]    = drv_in.wdata_i[7:0];
                        end
                        3'd1: begin
                            mem_addr = drv_in.addr_i;
                            memory[mem_addr]    = drv_in.wdata_i[7:0];
                            memory[mem_addr+1]  = drv_in.wdata_i[15:8];
                        end
                        3'd2: begin
                            mem_addr = drv_in.addr_i;
                            memory[mem_addr]    = drv_in.wdata_i[7:0];
                            memory[mem_addr+1]  = drv_in.wdata_i[15:8];
                            memory[mem_addr+2]  = drv_in.wdata_i[23:16];
                            memory[mem_addr+3]  = drv_in.wdata_i[31:24];
                        end
                        default: begin
                            `uvm_info("ahb_moedl", $sformatf("cmd error : data_size_i %0d",drv_in.data_size_i), UVM_LOW);
                        end
                    endcase
                end
            end else if(drv_in.rd_en_i) begin
                mem_addr = {drv_in.addr_i[31:2],2'b0};
                if(drv_in.addr_i >= 32'h0004_0000) begin
                    mem_data = 32'hDEAD_BEEF;
                end else begin
                    mem_data = {memory[mem_addr+3],memory[mem_addr+2],memory[mem_addr+1],memory[mem_addr]};
                end
                case(drv_in.addr_i[1:0])
                    2'b00 : begin
                        model_out.rdata = mem_data;
                    end
                    2'b01 : begin
                        model_out.rdata = mem_data>>8;
                    end
                    2'b10 : begin
                        model_out.rdata = mem_data>>16;
                    end
                    2'b11 : begin
                        model_out.rdata = mem_data>>24;
                    end
                    default : begin
                        model_out.rdata = mem_data;
                    end
                endcase
                model_out.rd_addr = drv_in.addr_i;
                //`uvm_info("ahb_moedl : model_out is ", model_out.sprint(), UVM_LOW);
                ap.write(model_out);
            end else begin
                `uvm_info("ahb_moedl", "cmd error, no wr_en_i and no rd_en_i !!!", UVM_LOW);
            end
        end else begin
            `uvm_info("ahb_moedl", "get invalid cmd !!!", UVM_LOW);
        end
    end
endtask

`endif

