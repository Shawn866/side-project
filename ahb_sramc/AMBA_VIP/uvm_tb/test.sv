program automatic test;
import uvm_pkg::*;

`include "test_base.sv"

initial begin
  $timeformat(-9, 1, "ns", 10);
  run_test();
end

endprogram

