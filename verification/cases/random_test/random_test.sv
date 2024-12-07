`ifndef RANDOM_TEST__SV
`define RANDOM_TEST__SV

// {{{ random_test_item
class random_test_item extends ahb_transaction;
    `uvm_object_utils(random_test_item)

    // rand
    rand bit                    r_din_vld;
    rand bit                    r_wr_rd_en;
    rand bit [2:0]              r_data_size;
    rand bit [31:0]             r_addr;
    rand bit [31:0]             r_wdata;
    rand bit                    r_dout_rdy;

    constraint  c_cmd {
                        r_din_vld dist {1:=70,0:=30};
                        r_data_size <= 3'd2;
                        r_addr dist {[0:262143]:=95,[262144:262200]:=5};
                        r_dout_rdy dist {1:=70,0:=30};
                        }

    function new(string name = "random_test_item");
        super.new();
    endfunction

    function void post_randomize();
        din_vld_i   = r_din_vld;
        wr_en_i     = r_wr_rd_en;
        rd_en_i     = ~r_wr_rd_en;
        data_size_i = r_data_size;
        addr_i      = r_addr;
        burst_i     = 3'd0;
        if(data_size_i == 3'd2) begin
            addr_i[1:0] = 2'b0;
        end else if(data_size_i == 3'd1) begin
            addr_i[0]   = 1'b0;
        end
        wdata_i     = r_wdata;
        dout_rdy_i  = r_dout_rdy;
        if((~dout_rdy_i) && din_vld_i && rd_en_i) begin
            wr_en_i = 1'b1;
            rd_en_i = 1'b0;
        end
        if(~din_vld_i) begin
            wr_en_i = 1'b0;
            rd_en_i = 1'b0;
            data_size_i = 3'b0;
            addr_i  = 32'b0;
            wdata_i = 32'b0;
        end
        if(rd_en_i) begin
            wdata_i = 32'b0;
        end
    endfunction

endclass
// }}} random_test_item


// {{{ random_test_sequence
class random_test_sequence extends uvm_sequence #(random_test_item);
    `uvm_object_utils(random_test_sequence)
    random_test_item              ahb_trans;
    function new(string name= "random_test_sequence");
        super.new(name);
        ahb_trans = new("ahb_trans");
    endfunction

    virtual task body();
        while (1) begin
	        `uvm_create(ahb_trans)
  	        assert(ahb_trans.randomize());
//	        ahb_trans.print();
	        `uvm_send(ahb_trans)
        end
        #1000;
    endtask
endclass
// }}} random_test_sequence


// {{{ random_test
class random_test extends base_test;
    function new(string name = "random_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(random_test)
endclass

function void random_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "env.i_agt.sqr.main_phase",
                                            "default_sequence",
                                            random_test_sequence::type_id::get());
endfunction
// }}} random_test

`endif

