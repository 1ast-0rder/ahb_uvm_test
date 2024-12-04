`ifndef AHB_SCOREBOARD__SV
`define AHB_SCOREBOARD__SV
class ahb_scoreboard extends uvm_scoreboard;
    bit result;
    ahb_transaction_out get_expect, get_actual, tmp_tran;
    ahb_transaction_out     expect_queue[$];
    int test_cnt=0;

    uvm_blocking_get_port #(ahb_transaction_out)  exp_port;
    uvm_blocking_get_port #(ahb_transaction_out)  act_port;
    `uvm_component_utils(ahb_scoreboard)

    extern function new(string name, uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass 

function ahb_scoreboard::new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction 

function void ahb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port   = new("exp_port", this);
    act_port   = new("act_port", this);
endfunction

task ahb_scoreboard::main_phase(uvm_phase phase);
    phase.raise_objection(this);  
    super.main_phase(phase);
    fork 
        while (1) begin
            exp_port.get(get_expect);
            expect_queue.push_back(get_expect);
        end
        while (1) begin
            act_port.get(get_actual);
            if(expect_queue.size() > 0) begin
                tmp_tran = expect_queue.pop_front();
                result = get_actual.compare(tmp_tran);
                if(result) begin 
                    `uvm_info("ahb_scoreboard", "Compare SUCCESSFULLY", UVM_LOW);
                    //`uvm_info("ahb_scoreboard : the reference model out is", tmp_tran.sprint(), UVM_LOW);
                    //`uvm_info("ahb_scoreboard : the dut out is", get_actual.sprint(), UVM_LOW);
                end else begin
                    `uvm_error("ahb_scoreboard", "Compare FAILED");
                    `uvm_info("ahb_scoreboard : the reference model out is", tmp_tran.sprint(), UVM_LOW);
                    `uvm_info("ahb_scoreboard : the dut out is", get_actual.sprint(), UVM_LOW);
                end
                test_cnt = test_cnt+1;
                if(test_cnt == `TEST_CMD_NUM) begin
                    break;
                end
            end else begin
                `uvm_error("ahb_scoreboard", "Received from DUT, while Expect Queue is empty");
                `uvm_info("ahb_scoreboard : the unexpected pkt is", get_actual.sprint(), UVM_LOW);
            end 
        end
    join_any
    phase.drop_objection(this);  
endtask
`endif

