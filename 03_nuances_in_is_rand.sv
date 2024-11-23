//Nuances in is_rand parameter
/*
we have changed is_rand actual parameter while calling configure method of uvm_reg_field
*/

//see the results

`include "uvm_macros.svh"
import uvm_pkg::*;

class pll_reg_two_field extends uvm_reg;
  `uvm_object_utils(pll_reg_two_field)
  rand uvm_reg_field pll_n_value;
  rand uvm_reg_field pll_l_value;
  
  function new(string name="pll_reg_two_field");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction
  
  /*
  function void configure(		uvm_reg 	parent,
int 	unsigned 	size,
int 	unsigned 	lsb_pos,
string 	access,
bit 	volatile,
uvm_reg_data_t 	reset,
bit 	has_reset,
bit 	is_rand,
bit 	individually_accessible	
  */
  
  function void build();
    pll_n_value=uvm_reg_field::type_id::create("pll_n_value");
    pll_n_value.configure(this,16,0,"RW",0,16'h0,1,0,1);
    
    ////////////////
    pll_l_value=uvm_reg_field::type_id::create("pll_l_value");
    pll_l_value.configure(this,16,16,"RW",0,16'h0,1,0,1);
    
  endfunction
  
  constraint l_constraint{
    pll_n_value.value inside{3,4,5};
    pll_l_value.value inside{7,8,10};
  }
  
  function void post_randomize();
    $display("field :: pll_n_value : %0d",pll_n_value.value);
    $display("field :: pll_l_value : %0d",pll_l_value.value);
  endfunction
endclass

module top;
  pll_reg_two_field two_field;
  initial
    begin
      two_field=new("two_field");
      two_field.build();
      two_field.randomize();
    end
  
endmodule
