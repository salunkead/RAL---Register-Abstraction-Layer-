///Implementing register with five fields in Verification Env.

`include "uvm_macros.svh"
import uvm_pkg::*;

class audio_cc_bus_cbcr extends uvm_reg;
  `uvm_object_utils(audio_cc_bus_cbcr)
  
  //Register fields
  uvm_reg_field clk_off;
  rand uvm_reg_field ignore_ares;
  rand uvm_reg_field ignore_clk_dis;
  rand uvm_reg_field clk_dis;
  rand uvm_reg_field clk_ares;
  
  function new(string name="audio_cc_bus_cbcr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction
  
  constraint clk_ares_constraint {clk_ares.value inside{0,1};}
  
  function void build();
    clk_off=uvm_reg_field::type_id::create("clk_off");
    clk_off.configure(this,1,31,"RO",0,1'h0,1,0,0);
    
    //////////////////////////////
    
    ignore_ares=uvm_reg_field::type_id::create("ignore_ares");
    ignore_ares.configure(this,1,24,"RW",0,1'h0,1,0,0);
    //////////////////////
    
    ignore_clk_dis=uvm_reg_field::type_id::create("ignore_clk_dis");
    ignore_clk_dis.configure(this,1,23,"RW",0,0,1,0,0);
    ////////////////////
    
    clk_dis=uvm_reg_field::type_id::create("clk_dis");
    clk_dis.configure(this,1,22,"RW",0,0,1,0,0);
    
    ///////////////////////
    clk_ares=uvm_reg_field::type_id::create("clk_ares");
    clk_ares.configure(this,1,21,"RW",0,0,1,1,0);
  endfunction
  
  function void post_randomize;
    $display("field name : clk_off : %0d",clk_off.value);
    $display("field name : ignore_ares : %0d",ignore_ares.value);
    $display("field name : ignore_clk_dis : %0d",ignore_clk_dis.value);
    $display("field name : clk_dis : %0d",clk_dis.value);
    $display("field name : clk_ares : %0d",clk_ares.value);
    $display("****************************************************");

  endfunction
endclass

module top;
  audio_cc_bus_cbcr cbcr;
  initial
    begin
      cbcr=new("four_fields");
      cbcr.build();
      repeat(2)cbcr.randomize();
    end
  
endmodule
