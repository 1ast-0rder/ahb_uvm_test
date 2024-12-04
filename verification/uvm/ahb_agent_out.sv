`ifndef AHB_AGENT_OUT__SV
`define AHB_AGENT_OUT__SV

class ahb_agent_out extends uvm_agent ;
    ahb_monitor_out     mon_out;

    uvm_analysis_port #(ahb_transaction_out)  ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction 

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(ahb_agent_out)
endclass 

function void ahb_agent_out::build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_out = ahb_monitor_out::type_id::create("mon_out", this);
endfunction 

function void ahb_agent_out::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ap = mon_out.ap;
endfunction

`endif

