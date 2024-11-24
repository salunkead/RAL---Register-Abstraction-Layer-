//Randomize method on register class

`include "uvm_macros.svh"
import uvm_pkg::*;

class LPASS_CC_PLL extends uvm_reg;
  `uvm_object_utils(LPASS_CC_PLL)
  rand uvm_reg_field pll_reg;
  
  function new(string name="LPASS_CC_PLL");
    super.new(.name(name),.n_bits(32),.has_coverage(UVM_NO_COVERAGE));
  endfunction
  
  function void build();
    pll_reg=uvm_reg_field::type_id::create("pll_reg");
    pll_reg.configure(.parent(this),.size(32),.lsb_pos(0),.access("RW"),.volatile(0),.reset(32'h0),.has_reset(1),.is_rand(1),.individually_accessible(1));
  endfunction
  
  constraint reg_constraint {
    pll_reg.value inside{[10:50]};
  }
  
  function void post_randomize();
    $display("value of the field is : %0d",pll_reg.value);
  endfunction

endclass

class reg_block extends uvm_reg_block;
  `uvm_object_utils(reg_block)
  rand LPASS_CC_PLL pll_reg_inst;
  uvm_sequencer #(uvm_sequence_item) sqr;
  
  function new(string name="regblock");
    super.new(name,UVM_NO_COVERAGE);
  endfunction
  
  function void build();
    pll_reg_inst=LPASS_CC_PLL::type_id::create("pll_reg_inst");
    pll_reg_inst.configure(this);
    pll_reg_inst.build();
    
    /////////////
    default_map=create_map("register_address_map",16,4,UVM_LITTLE_ENDIAN,0);
    default_map.add_reg(pll_reg_inst,0);
    default_map.set_sequencer(sqr);
    lock_model();
  endfunction
endclass



class register_seq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(register_seq)
  reg_block reg_model;
  uvm_status_e status;
  function new(string n="reg_seq");
    super.new(n);
     reg_model=reg_block::type_id::create("reg_model");
  endfunction
  
  task body();
    reg_model.build();
    repeat(2)
      begin
        reg_model.pll_reg_inst.randomize();
      end
  endtask
  
endclass

module top;
  register_seq seq;
  uvm_sequencer #(uvm_sequence_item) sqr;
  
  initial
    begin
      seq=new("seq");
      sqr=new("sqr",null);
      seq.reg_model.sqr=sqr;
      seq.start(sqr);
    end
endmodule
