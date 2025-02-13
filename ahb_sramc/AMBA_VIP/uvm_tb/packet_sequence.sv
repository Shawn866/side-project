`ifndef PACKET_SEQUENCE__SV
`define PACKET_SEQUENCE__SV

`include "packet.sv"

class packet_sequence extends uvm_sequence #(packet);

  `uvm_object_utils(packet_sequence)

  function new(string name = "packet_sequence");
    super.new(name);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
  endfunction: new

  virtual task body();
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    if (starting_phase != null)
      starting_phase.raise_objection(this);
    repeat(2000) begin
      `uvm_do(req);
    end
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask: body

endclass: packet_sequence

`endif
