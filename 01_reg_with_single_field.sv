//Implementaion of register in Verification Environment
//Implenting register with single field

/*

function new (
   		string 	name	 = 	"",
   	int 	unsigned 	n_bits,	  	
   		int 	has_coverage	  	
)
Create a new instance and type-specific configuration

Creates an instance of a register abstraction class with the specified name.

n_bits specifies the total number of bits in the register.  Not all bits need to be implemented.  This value is usually a multiple of 8.

has_coverage specifies which functional coverage models are present in the extension of the register abstraction class.  Multiple functional coverage models may be specified by adding their symbolic names, as defined by the uvm_coverage_model_e type.

*/

/*
virtual function string get_full_name()
Get the hierarchical name

Return the hierarchal name of this field The base of the hierarchical name is the root block.
*/

/*
configure
function void configure(		uvm_reg 	parent,
int 	unsigned 	size,
int 	unsigned 	lsb_pos,
string 	access,
bit 	volatile,
uvm_reg_data_t 	reset,
bit 	has_reset,
bit 	is_rand,
bit 	individually_accessible	)
Instance-specific configuration

Specify the parent register of this field, its size in bits, the position of its least-significant bit within the register relative to the least-significant bit of the register, its access policy, volatility, “HARD” reset value, whether the field value is actually reset (the reset value is ignored if FALSE), whether the field value may be randomized and whether the field is the only one to occupy a byte lane in the register.

See set_access for a specification of the pre-defined field access policies.

If the field access policy is a pre-defined policy and NOT one of “RW”, “WRC”, “WRS”, “WO”, “W1”, or “WO1”, the value of is_rand is ignored and the rand_mode() for the field instance is turned off since it cannot be written.
*/

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

module top;
  LPASS_CC_PLL pll;
  initial
    begin
      pll=new("pll");
      pll.build();
      pll.randomize();
    end
  
endmodule
