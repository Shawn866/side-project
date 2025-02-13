`ifndef ROUTER_ENV__SV
`define ROUTER_ENV__SV

`include "input_agent.sv"

class router_env extends uvm_env;

  input_agent i_agent;

  `uvm_component_utils(router_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    i_agent = input_agent::type_id::create("i_agent", this);
    uvm_config_db #(uvm_object_wrapper)::set(this, "i_agent.seqr.main_phase", "default_sequence", packet_sequence::get_type());
  endfunction: build_phase

endclass: router_env

`endif
