`ifndef AHB_MODEL__SV
`define AHB_MODEL__SV

class ahb_model extends uvm_component;

    logic [7:0] memory[logic[31:0]];
    ahb_transaction         drv_in;
    ahb_transaction_out     model_out;
    static bit [31:0]       mem_addr;
    static bit [31:0]       mem_data;
    int burst_count = 0;  // 记录 burst 剩余的周期数
    int burst_type = 0;   // 记录 burst 类型：例如 INCR4、INCR8
    // int mem_addr = 0;     // 内存地址寄存器
    // int mem_data = 0;     // 内存数据寄存器
    int size = 0;         // 数据大小
    int burst_boundary = 0;  // burst 边界
    int trans_flag = 0;   // 是否有传输
    int hwrite = 0;       // 读写标志位
    int rd_mem_addr = 0;  // 读内存地址 

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

    initial_mem;  // 初始化内存
    #1;

    while(1) begin
        trans_flag = 0;  // 无传输
        port.get(drv_in);
        model_out = new("model_out");
        if (drv_in.din_vld_i) begin  // 非 burst 操作或新的 burst 开始
            // 确定数据大小
            case (drv_in.data_size_i)
                3'd0: size = 1;  // Byte
                3'd1: size = 2;  // Halfword
                3'd2: size = 4;  // Word
                // default: `uvm_info("ahb_model", $sformatf("cmd error : data_size_i %0d", drv_in.data_size_i), UVM_LOW);
            endcase
            // 确定 burst 类型
            case (drv_in.burst_i)
                3'd0: begin  // SINGLE
                    burst_type = 0;
                    burst_count = 1;  // SINGLE 对应 1 个周期
                    // burst_count = 1-1;  // SINGLE 对应 1 个周期
                end
                3'd1: begin  // INCR
                    burst_type = 1;
                    burst_count = 1024;  // INCR 未定义周期数，这里设置为 1024 个周期
                    // burst_count = 1024-1;  // INCR 未定义周期数，这里设置为 1024 个周期
                end
                3'd2: begin  // WRAP4
                    burst_type = 2;
                    burst_count = 4;  // WRAP4 对应 4 个周期
                    // burst_count = 4-1;  // WRAP4 对应 4 个周期
                end
                3'd3: begin  // INCR4
                    burst_type = 3;
                    burst_count = 4; // INCR4 对应 4 个周期
                    // burst_count = 4-1; // INCR4 对应 4 个周期
                end
                3'd4: begin  // WRAP8
                    burst_type = 4;
                    burst_count = 8;  // WRAP8 对应 8 个周期
                    // burst_count = 8-1;  // WRAP8 对应 8 个周期
                end
                3'd5: begin  // INCR8
                    burst_type = 5;
                    burst_count = 8;  // INCR8 对应 8 个周期
                    // burst_count = 8-1;  // INCR8 对应 8 个周期
                end
                3'd6: begin  // WRAP16
                    burst_type = 6;
                    burst_count = 16; // WRAP16 对应 16 个周期
                    // burst_count = 16-1; // WRAP16 对应 16 个周期
                end
                3'd7: begin  // INCR16
                    burst_type = 7;
                    burst_count = 16; // WRAP16 对应 16 个周期
                    // burst_count = 16-1; // WRAP16 对应 16 个周期
                end
                default: begin
                    // `uvm_info("ahb_model", "Unknown burst type!", UVM_LOW);
                end
            endcase
            //确定内存地址
            mem_addr = drv_in.addr_i;
            burst_boundary = size*burst_count;  // 计算 burst 边界
            trans_flag = 1;  // 有传输
            hwrite = drv_in.wr_en_i;  // 读写标志位
        end
        else if (burst_count > 0) begin  // burst 操作
            trans_flag = 1;  // 有传输
            if(burst_type!=1)
                burst_count = burst_count - 1;  // 递减 burst 计数
            if(burst_type==0 || burst_type==1 || burst_type==3 || burst_type==5 || burst_type==7)  // INCR4 或 INCR8
                mem_addr = mem_addr + size;  
            else // WRAP4、WRAP8、WRAP16
            begin
                if ((mem_addr + size)/burst_boundary!=mem_addr/burst_boundary)  // 到达边界
                    mem_addr = mem_addr + size - burst_boundary;
                else
                    mem_addr = mem_addr + size;
            end
        end
        else begin// 无传输
            trans_flag = 0;
        end


        // 写操作
        if(hwrite==1&&trans_flag==1) begin
            if(mem_addr >= 32'h0004_0000) begin
                // `uvm_info("ahb_model", $sformatf("write addr 0x%0h over boundary", mem_addr), UVM_LOW);
            end else begin
                case(drv_in.data_size_i)
                    3'd0: memory[mem_addr] = drv_in.wdata_i[7:0];  // Byte
                    3'd1: begin  // Halfword
                        memory[mem_addr]     = drv_in.wdata_i[7:0];
                        memory[mem_addr+1]   = drv_in.wdata_i[15:8];
                    end
                    3'd2: begin  // Word
                        memory[mem_addr]     = drv_in.wdata_i[7:0];
                        memory[mem_addr+1]   = drv_in.wdata_i[15:8];
                        memory[mem_addr+2]   = drv_in.wdata_i[23:16];
                        memory[mem_addr+3]   = drv_in.wdata_i[31:24];
                    end
                    default: begin
                        `uvm_info("ahb_model", $sformatf("cmd error : data_size_i %0d", drv_in.data_size_i), UVM_LOW);
                    end
                endcase
                // model_out.rdata = 32'h0;
                // model_out.rd_addr = 32'h0;
                // ap.write(model_out);
            end
        // 读操作
        end else if(hwrite==0&&trans_flag==1) begin
            rd_mem_addr = {mem_addr[31:2], 2'b00};  // 以 word 对齐的地址
            if(mem_addr >= 32'h0004_0000) begin
                mem_data = 32'hDEAD_BEEF;  // 超过边界则返回特殊数据
            end else begin
                mem_data = {memory[rd_mem_addr+3], memory[rd_mem_addr+2], memory[rd_mem_addr+1], memory[rd_mem_addr]};
            end
            // 根据 addr 的最低两位选择需要输出的 byte
            model_out.rdata = (mem_addr[1:0] == 2'b00) ? mem_data :
                                (mem_addr[1:0] == 2'b01) ? mem_data >> 8 :
                                (mem_addr[1:0] == 2'b10) ? mem_data >> 16 : mem_data >> 24;
            model_out.rd_addr = mem_addr;
            ap.write(model_out);
        end else begin
            // model_out.rdata = 32'h0;
            // model_out.rd_addr = 32'h0;
            // ap.write(model_out);
        end
    end
endtask


`endif

