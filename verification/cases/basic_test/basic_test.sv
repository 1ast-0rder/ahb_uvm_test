`ifndef BASIC_TEST__SV
`define BASIC_TEST__SV
// {{{ basic_test_item
class basic_test_item extends ahb_transaction;
    `uvm_object_utils(basic_test_item)


    `define test_item(CNT,WR_RD_EN,DATA_SIZE,ADDR)            \
        ``CNT``:    begin                                           \
                        wr_en_i     = ``WR_RD_EN``;                 \
                        rd_en_i     = ~``WR_RD_EN``;                \
                        data_size_i = ``DATA_SIZE``;                \
                        addr_i      = ``ADDR``;                     \
                        if(wr_en_i) begin                           \
                            wdata_i = addr_i;                       \
                        end else begin                              \
                            wdata_i = 32'b0;                        \
                        end                                         \
                    end


    function new(string name = "basic_test_item");
        super.new();
    endfunction

    function void post_randomize();
        static int  cnt=0;
        din_vld_i   = 1'b1;
        dout_rdy_i  = 1'b1;

        case(cnt)
            `test_item( 0,1,3'd0,32'h0000_0000)
            `test_item( 1,0,3'd0,32'h0000_0000)
            `test_item( 2,1,3'd0,32'h0001_0000)
            `test_item( 3,0,3'd0,32'h0001_0000)
            `test_item( 4,1,3'd0,32'h0002_0000)
            `test_item( 5,0,3'd0,32'h0002_0000)
            `test_item( 6,1,3'd0,32'h0003_0000)
            `test_item( 7,0,3'd0,32'h0003_0000)
            `test_item( 8,1,3'd0,32'h0000_0001)
            `test_item( 9,0,3'd0,32'h0000_0001)
            `test_item(10,1,3'd0,32'h0001_0001)
            `test_item(11,0,3'd0,32'h0001_0001)
            `test_item(12,1,3'd0,32'h0002_0001)
            `test_item(13,0,3'd0,32'h0002_0001)
            `test_item(14,1,3'd0,32'h0003_0001)
            `test_item(15,0,3'd0,32'h0003_0001)
            `test_item(16,1,3'd0,32'h0000_0002)
            `test_item(17,0,3'd0,32'h0000_0002)
            `test_item(18,1,3'd0,32'h0001_0002)
            `test_item(19,0,3'd0,32'h0001_0002)
            `test_item(20,1,3'd0,32'h0002_0002)
            `test_item(21,0,3'd0,32'h0002_0002)
            `test_item(22,1,3'd0,32'h0003_0002)
            `test_item(23,0,3'd0,32'h0003_0002)
            `test_item(24,1,3'd0,32'h0000_0003)
            `test_item(25,0,3'd0,32'h0000_0003)
            `test_item(26,1,3'd0,32'h0001_0003)
            `test_item(27,0,3'd0,32'h0001_0003)
            `test_item(28,1,3'd0,32'h0002_0003)
            `test_item(29,0,3'd0,32'h0002_0003)
            `test_item(30,1,3'd0,32'h0003_0003)
            `test_item(31,0,3'd0,32'h0003_0003)

            `test_item(32,1,3'd1,32'h0000_1000)
            `test_item(33,0,3'd1,32'h0000_1000)
            `test_item(34,1,3'd1,32'h0001_1000)
            `test_item(35,0,3'd1,32'h0001_1000)
            `test_item(36,1,3'd1,32'h0002_1000)
            `test_item(37,0,3'd1,32'h0002_1000)
            `test_item(38,1,3'd1,32'h0003_1000)
            `test_item(39,0,3'd1,32'h0003_1000)
            `test_item(40,1,3'd1,32'h0000_1002)
            `test_item(41,0,3'd1,32'h0000_1002)
            `test_item(42,1,3'd1,32'h0001_1002)
            `test_item(43,0,3'd1,32'h0001_1002)
            `test_item(44,1,3'd1,32'h0002_1002)
            `test_item(45,0,3'd1,32'h0002_1002)
            `test_item(46,1,3'd1,32'h0003_1002)
            `test_item(47,0,3'd1,32'h0003_1002)
            `test_item(48,1,3'd1,32'h0000_1004)
            `test_item(49,0,3'd1,32'h0000_1004)
            `test_item(50,1,3'd1,32'h0001_1004)
            `test_item(51,0,3'd1,32'h0001_1004)
            `test_item(52,1,3'd1,32'h0002_1004)
            `test_item(53,0,3'd1,32'h0002_1004)
            `test_item(54,1,3'd1,32'h0003_1004)
            `test_item(55,0,3'd1,32'h0003_1004)
            `test_item(56,1,3'd1,32'h0000_1004)
            `test_item(57,0,3'd1,32'h0000_1006)
            `test_item(58,1,3'd1,32'h0001_1006)
            `test_item(59,0,3'd1,32'h0001_1006)
            `test_item(60,1,3'd1,32'h0002_1006)
            `test_item(61,0,3'd1,32'h0002_1006)
            `test_item(62,1,3'd1,32'h0003_1006)
            `test_item(63,0,3'd1,32'h0003_1006)

            `test_item(64,1,3'd2,32'h0000_2000)
            `test_item(65,0,3'd2,32'h0000_2000)
            `test_item(66,1,3'd2,32'h0001_2000)
            `test_item(67,0,3'd2,32'h0001_2000)
            `test_item(68,1,3'd2,32'h0002_2000)
            `test_item(69,0,3'd2,32'h0002_2000)
            `test_item(70,1,3'd2,32'h0003_2000)
            `test_item(71,0,3'd2,32'h0003_2000)
            `test_item(72,1,3'd2,32'h0000_2004)
            `test_item(73,0,3'd2,32'h0000_2004)
            `test_item(74,1,3'd2,32'h0001_2004)
            `test_item(75,0,3'd2,32'h0001_2004)
            `test_item(76,1,3'd2,32'h0002_2004)
            `test_item(77,0,3'd2,32'h0002_2004)
            `test_item(78,1,3'd2,32'h0003_2004)
            `test_item(79,0,3'd2,32'h0003_2004)

            default:
                begin
                    din_vld_i   = 1'b0;
                    dout_rdy_i  = 1'b1;
                end
        endcase
        cnt = cnt+1;
    endfunction
endclass
// }}} basic_test_item


// {{{ basic_test_sequence
class basic_test_sequence extends uvm_sequence #(basic_test_item);
    `uvm_object_utils(basic_test_sequence)
    basic_test_item              ahb_trans;
    function new(string name= "basic_test_sequence");
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
// }}} basic_test_sequence


// {{{ basic_test
class basic_test extends base_test;
    function new(string name = "basic_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(basic_test)
endclass

function void basic_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            basic_test_sequence::type_id::get());
endfunction
// }}} basic_test

`endif

