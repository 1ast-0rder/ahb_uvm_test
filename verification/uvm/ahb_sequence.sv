`ifndef AHB_SEQUENCE__SV
`define AHB_SEQUENCE__SV

class ahb_sequence extends uvm_sequence #(ahb_transaction);
  ahb_transaction ahb_trans;

  function new(string name= "ahb_sequence");
    super.new(name);
  endfunction

  virtual task body();
    if(starting_phase != null)
      starting_phase.raise_objection(this);

    repeat (100) begin
      `uvm_do(ahb_trans)
    end
    #1000;
    if(starting_phase != null)
      starting_phase.drop_objection(this);
  endtask

  `uvm_object_utils(ahb_sequence)
endclass
`endif
