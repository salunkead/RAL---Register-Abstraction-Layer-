class pll_ctrl_post_div_ratio_odd;
 typedef enum bit[3:0]{
    divide_by_1=0,
    divide_by_3=2,
    divide_by_5=4,
    divide_by_7=6
  } post_div_value_odd;
endclass

class test extends pll_ctrl_post_div_ratio_odd;
  post_div_value_odd value;
  function new();
    value=divide_by_5;
    $display("divide_by_5 value is : %0d and name : %s",value,value.name());
  endfunction
endclass

module top;
  test t;
  initial
    begin
      t=new;
            
    end
endmodule
