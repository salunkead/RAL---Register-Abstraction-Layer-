///Adding Adapter in the Verification Env.

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

class ahb_master extends uvm_sequence_item;
  `uvm_object_utils(ahb_master)
  function new(string name="ahb_master");
    super.new(name);
  endfunction
  rand logic[31:0] haddr,hwdata;
  rand logic hwrite;
  rand logic[2:0] hburst;
  rand logic [1:0] hsize;
  rand logic hlock;
  rand logic[3:0] hprot;
  logic[31:0]hrdata;
  logic hresp;
endclass

/*
bit supports_byte_enable
Set this bit in extensions of this class if the bus protocol supports byte enables.

bit provides_responses
Set this bit in extensions of this class if the bus driver provides separate response items

pure virtual function uvm_sequence_item reg2bus(	const ref 	uvm_reg_bus_op 	rw	)

pure virtual function void bus2reg(		uvm_sequence_item 	bus_item,
ref 	uvm_reg_bus_op 	rw	
*/

class cc_adapter extends uvm_reg_adapter;
  `uvm_object_utils(cc_adapter)
  function new(string name="adapter");
    super.new(name);
    supports_byte_enable=0;
    provides_responses=1;
  endfunction
  
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    ahb_master ahb_trans;
    ahb_trans=ahb_master::type_id::create("ahb_trans");
    
    case(rw.kind)
      UVM_READ:
        begin
          if(!ahb_trans.randomize with {
            ahb_trans.hwrite==1'b0;
            ahb_trans.hburst==0;
            ahb_trans.hsize==2;
            ahb_trans.hlock==0;
            ahb_trans.hprot==0;
            ahb_trans.haddr==rw.addr;
          })
            `uvm_error(get_name,"Randomization failure");
        end
      
      UVM_WRITE:
        begin
           if(!ahb_trans.randomize with {
             ahb_trans.hwrite==1'b1;
             ahb_trans.hburst==0;
             ahb_trans.hsize==2;
             ahb_trans.hlock==0;
             ahb_trans.hprot==0;
             ahb_trans.haddr==rw.addr;
             ahb_trans.hwdata==rw.data;
          })
             `uvm_error(get_name,"Randomization failure");
        end
    endcase
    return ahb_trans;
  endfunction
  
  function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
    ahb_master tr;
    tr=ahb_master::type_id::create("ahb_trans");
    
    if(!$cast(tr,bus_item))
      `uvm_fatal(get_name,"Not AHB type");
    
    rw.kind=(tr.hwrite)?UVM_WRITE:UVM_READ;
    rw.addr=tr.haddr;
    if(tr.hwrite==0) rw.data=tr.hrdata;
    if(tr.hresp==0)
      rw.status=UVM_IS_OK;
    else
      rw.status=UVM_NOT_OK;
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
