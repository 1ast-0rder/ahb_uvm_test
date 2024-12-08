`ifndef BURST_TEST__SV
`define BURST_TEST__SV
// {{{ burst_test_item
class burst_test_item extends ahb_transaction;
    `uvm_object_utils(burst_test_item)

    `define burst_item(CNT,INVLD,BURST_TYPE,WR_RD_EN,DATA_SIZE,ADDR,WDATA)       \
        ``CNT``:    begin                                           \
                        din_vld_i   = ``INVLD``;                     \
                        wr_en_i     = ``WR_RD_EN``;                 \
                        rd_en_i     = ~``WR_RD_EN``;                \
                        data_size_i = ``DATA_SIZE``;                \
                        addr_i      = ``ADDR``;                     \
                        if(wr_en_i) begin                           \
                            wdata_i = ``WDATA``;                       \
                        end else begin                              \
                            wdata_i = 32'b0;                        \
                        end                                         \
                        burst_i     = ``BURST_TYPE``;               \
                    end

    function new(string name = "burst_test_item");
        super.new();
    endfunction

    function void post_randomize();
        static int  cnt=0;
        // din_vld_i   = 1'b1;
        dout_rdy_i  = 1'b1;

        case(cnt)
                    //cnt,vld,bst,wr,size,addr,wdata
            `burst_item(0,1,3'd0,1,32'h0000_0000,32'h0000_0000)
            `burst_item(1,0,3'd0,0,32'h0000_0000,32'h0000_0000)
            default:
                begin
                    din_vld_i   = 1'b0;
                    dout_rdy_i  = 1'b1;
                end
        endcase
        cnt = cnt+1;
    endfunction
endclass
// }}} burst_test_item

// {{{ burst_test_sequence
class burst_test_sequence extends uvm_sequence #(burst_test_item);
    `uvm_object_utils(burst_test_sequence)
    burst_test_item              ahb_trans;
    
    function new(string name= "burst_test_sequence");
        super.new(name);
        ahb_trans = new("ahb_trans");
    endfunction
    
    virtual task body();
        while (1) begin
            `uvm_create(ahb_trans)
  	        assert(ahb_trans.randomize());
            `uvm_send(ahb_trans)
        end
        #1000;
    endtask
endclass
// }}} burst_test_sequence

// {{{ burst_test
class burst_test extends base_test;
    function new(string name = "burst_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(burst_test)
endclass

function void burst_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            burst_test_sequence::type_id::get());
endfunction
// }}} burst_test
