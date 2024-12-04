`ifndef AHB_AGENT_IN__SV
`define AHB_AGENT_IN__SV

class ahb_agent_in extends uvm_agent ;
    ahb_sequencer   sqr;
    ahb_driver      drv;
    ahb_monitor_in  mon_in;

    uvm_analysis_port #(ahb_transaction)  ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction 

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(ahb_agent_in)
endclass 


function void ahb_agent_in::build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr    = ahb_sequencer::type_id::create("sqr", this);
    drv    = ahb_driver::type_id::create("drv", this);
    mon_in = ahb_monitor_in::type_id::create("mon_in", this);
endfunction 

function void ahb_agent_in::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
    ap = mon_in.ap;
endfunction

`endif

