`ifndef BURST_TEST__SV
`define BURST_TEST__SV
// {{{ burst_test_item
class burst_test_item extends ahb_transaction;
    `uvm_object_utils(burst_test_item)

    `define burst_item(CNT,INVLD,BURST_TYPE,WR_RD_EN,DATA_SIZE,ADDR,WDATA)       \
        ``CNT``:    begin                                           \
                         din_vld_i  = ``INVLD``;                     \
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
            // single
            `burst_item(0,1,3'd0,1,3'd0,32'h0000_0000,32'h0000_0000)
            `burst_item(1,1,3'd0,0,3'd0,32'h0000_0000,32'h0000_0000)
            `burst_item(2,1,3'd0,1,3'd0,32'h0001_0000,32'h0001_0000)
            `burst_item(3,1,3'd0,0,3'd0,32'h0001_0000,32'h0001_0000)
            `burst_item(4,1,3'd0,1,3'd0,32'h0002_0000,32'h0002_0000)
            `burst_item(5,1,3'd0,0,3'd0,32'h0002_0000,32'h0002_0000)
            `burst_item(6,1,3'd0,1,3'd0,32'h0003_0000,32'h0003_0000)
            `burst_item(7,1,3'd0,0,3'd0,32'h0003_0000,32'h0003_0000)

            // wrap4
            `burst_item(8,1,3'd2,1,3'd2,32'h0000_0038,32'h0000_0038)
            `burst_item(9,0,3'd2,1,3'd2,32'h0000_003C,32'h0000_003C)
            `burst_item(10,0,3'd2,1,3'd2,32'h0000_0030,32'h0000_0030)
            `burst_item(11,0,3'd2,1,3'd2,32'h0000_0034,32'h0000_0034)
            `burst_item(12,1,3'd2,0,3'd2,32'h0000_0038,32'h0000_0038)
            `burst_item(13,0,3'd2,0,3'd2,32'h0000_003C,32'h0000_003C)
            `burst_item(14,0,3'd2,0,3'd2,32'h0000_0030,32'h0000_0030)
            `burst_item(15,0,3'd2,0,3'd2,32'h0000_0034,32'h0000_0034)

            // incr4
            `burst_item(16,1,3'd3,1,3'd2,32'h0001_0038,32'h0001_0038)
            `burst_item(17,0,3'd3,1,3'd2,32'h0001_003C,32'h0001_003C)
            `burst_item(18,0,3'd3,1,3'd2,32'h0001_0040,32'h0001_0040)
            `burst_item(19,0,3'd3,1,3'd2,32'h0001_0044,32'h0001_0044)
            `burst_item(20,1,3'd3,0,3'd2,32'h0001_0038,32'h0001_0038)
            `burst_item(21,0,3'd3,0,3'd2,32'h0001_003C,32'h0001_003C)
            `burst_item(22,0,3'd3,0,3'd2,32'h0001_0040,32'h0001_0040)
            `burst_item(23,0,3'd3,0,3'd2,32'h0001_0044,32'h0001_0044)

            // wrap8
            `burst_item(24,1,3'd4,1,3'd2,32'h0002_0034,32'h0002_0034)
            `burst_item(25,0,3'd4,1,3'd2,32'h0002_0038,32'h0002_0038)
            `burst_item(26,0,3'd4,1,3'd2,32'h0002_003C,32'h0002_003C)
            `burst_item(27,0,3'd4,1,3'd2,32'h0002_0020,32'h0002_0020)
            `burst_item(28,0,3'd4,1,3'd2,32'h0002_0024,32'h0002_0024)
            `burst_item(29,0,3'd4,1,3'd2,32'h0002_0028,32'h0002_0028)
            `burst_item(30,0,3'd4,1,3'd2,32'h0002_002C,32'h0002_002C)
            `burst_item(31,0,3'd4,1,3'd2,32'h0002_0030,32'h0002_0030)
            `burst_item(32,1,3'd4,0,3'd2,32'h0002_0034,32'h0002_0034)
            `burst_item(33,0,3'd4,0,3'd2,32'h0002_0038,32'h0002_0038)
            `burst_item(34,0,3'd4,0,3'd2,32'h0002_003C,32'h0002_003C)
            `burst_item(35,0,3'd4,0,3'd2,32'h0002_0020,32'h0002_0020)
            `burst_item(36,0,3'd4,0,3'd2,32'h0002_0024,32'h0002_0024)
            `burst_item(37,0,3'd4,0,3'd2,32'h0002_0028,32'h0002_0028)
            `burst_item(38,0,3'd4,0,3'd2,32'h0002_002C,32'h0002_002C)
            `burst_item(39,0,3'd4,0,3'd2,32'h0002_0030,32'h0002_0030)

            // incr8
            `burst_item(40,1,3'd5,1,3'd1,32'h0003_0034,32'h0003_0034)
            `burst_item(41,0,3'd5,1,3'd1,32'h0003_0036,32'h0003_0036)
            `burst_item(42,0,3'd5,1,3'd1,32'h0003_0038,32'h0003_0038)
            `burst_item(43,0,3'd5,1,3'd1,32'h0003_003A,32'h0003_003A)
            `burst_item(44,0,3'd5,1,3'd1,32'h0003_003C,32'h0003_003C)
            `burst_item(45,0,3'd5,1,3'd1,32'h0003_003E,32'h0003_003E)
            `burst_item(46,0,3'd5,1,3'd1,32'h0003_0040,32'h0003_0040)
            `burst_item(47,0,3'd5,1,3'd1,32'h0003_0042,32'h0003_0042)
            `burst_item(48,1,3'd5,0,3'd1,32'h0003_0034,32'h0003_0034)
            `burst_item(49,0,3'd5,0,3'd1,32'h0003_0036,32'h0003_0036)
            `burst_item(50,0,3'd5,0,3'd1,32'h0003_0038,32'h0003_0038)
            `burst_item(51,0,3'd5,0,3'd1,32'h0003_003A,32'h0003_003A)
            `burst_item(52,0,3'd5,0,3'd1,32'h0003_003C,32'h0003_003C)
            `burst_item(53,0,3'd5,0,3'd1,32'h0003_003E,32'h0003_003E)
            `burst_item(54,0,3'd5,0,3'd1,32'h0003_0040,32'h0003_0040)
            `burst_item(55,0,3'd5,0,3'd1,32'h0003_0042,32'h0003_0042)



            // INCR
            `burst_item(56,1,3'd1,1,3'd1,32'h0000_0020,32'h0000_0020)
            `burst_item(57,0,3'd1,1,3'd1,32'h0000_0022,32'h0000_0022)
            `burst_item(58,1,3'd1,0,3'd2,32'h0003_0034,32'h0000_0034)
            `burst_item(59,0,3'd1,0,3'd2,32'h0003_0038,32'h0000_0038)
            `burst_item(60,0,3'd1,0,3'd2,32'h0003_003C,32'h0000_003C)
            `burst_item(61,1,3'd0,0,3'd0,32'h0000_0000,32'h0000_0000)



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
`endif