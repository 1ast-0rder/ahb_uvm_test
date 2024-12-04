`ifndef AHB_SEQUENCER__SV
`define AHB_SEQUENCER__SV

class ahb_sequencer extends uvm_sequencer #(ahb_transaction);
    `uvm_component_utils(ahb_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
endclass

`endif
