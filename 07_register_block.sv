//Adding Register Block In Verification Env.
//Method used as follows
/*
function new(
   	string 	name	 = 	"",
   	int 	has_coverage	 = 	UVM_NO_COVERAGE
)

function void configure(
   	uvm_reg_block 	parent	 = 	null,
   	string 	hdl_path	 = 	""
)

virtual function uvm_reg_map create_map(
   		string 	name,	  	
   		uvm_reg_addr_t 	base_addr,	  	
   	int 	unsigned 	n_bytes,	  	
   		uvm_endianness_e 	endian,	  	
   		bit 	byte_addressing	 = 	1
)

Create an address map in this block

Create an address map with the specified name, then configures it with the following properties.

base_addr	the base address for the map.  All registers, memories, and sub-blocks within the map will be at offsets to this address

n_bytes	the byte-width of the bus on which this map is used

endian	the endian format.  See uvm_endianness_e for possible values

byte_addressing	specifies whether consecutive addresses refer are 1 byte apart (TRUE) or n_bytes apart (FALSE).  Default is TRUE.

uvm_reg_map default_map;

virtual function void lock_model()
Lock a model and build the address map.

virtual function void add_reg (	uvm_reg 	rg,	  	
uvm_reg_addr_t 	offset,	  	
string 	rights	 = 	"RW",
bit 	unmapped	 = 	0,
uvm_reg_frontdoor 	frontdoor	 = 	null	)

Add a register

Add the specified register instance rg to this address map.

The register is located at the specified address offset from this maps configured base address.

The rights specify the register’s accessibility via this map

virtual function uvm_reg_addr_t get_base_addr (	uvm_hier_e 	hier	 = 	UVM_HIER	)
Get the base offset address for this map.

*/

`include "uvm_macros.svh"
import uvm_pkg::*;

class pll_reg_two_field extends uvm_reg;
  `uvm_object_utils(pll_reg_two_field)
  rand uvm_reg_field pll_n_value;
  rand uvm_reg_field pll_l_value;
  
  function new(string name="pll_reg_two_field");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction
  
  function void build();
    pll_n_value=uvm_reg_field::type_id::create("pll_n_value");
    pll_n_value.configure(this,16,0,"RW",0,16'h0,1,1,1);
    
    ////////////////
    pll_l_value=uvm_reg_field::type_id::create("pll_l_value");
    pll_l_value.configure(this,16,16,"RW",0,16'h0,1,1,1);
    
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

class reg_block extends uvm_reg_block;
  `uvm_object_utils(reg_block)
  rand pll_reg_two_field pll_reg_inst;
  uvm_reg_addr_t addr;
  
  function new(string name="regblock");
    super.new(name,UVM_NO_COVERAGE);
  endfunction
  
  function void build();
    pll_reg_inst=pll_reg_two_field::type_id::create("pll_reg_inst");
    pll_reg_inst.configure(this);
    pll_reg_inst.build();
    pll_reg_inst.randomize;
    
    /////////////
    default_map=create_map("register_address_map",16,4,UVM_LITTLE_ENDIAN,0);
    default_map.add_reg(pll_reg_inst,0);
    addr=default_map.get_base_addr();
    $display("Base Address of Register Map: %0d",addr);
    lock_model();
  endfunction
endclass

module top;
  reg_block reg_model;
  initial
    begin
      reg_model=new("two_field");
      reg_model.build();
    end
  
endmodule
