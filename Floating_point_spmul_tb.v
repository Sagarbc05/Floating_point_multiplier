/////////////////////////////////////////////////////////////////////////////////////////////
// Institution: University Visvesvaraya College of Engineering
// Project Guide: Dr. B P Harish, Chairman and Asst professor, ECE Dept, UVCE.
// Student: Sagar B C (20GAMD3015), IV sem M Tech in ECE, UVCE.
// Create Date:  15/10/2022 
// Design Name: IEEE 754 standard Single precison floating point multiplier testbench.
// Module Name: floating_point_spmul_tb 
// Version : v1.0
/////////////////////////////////////////////////////////////////////////////////////////////

module floating_point_spmul_tb;
reg [31:0] a, b;
wire [31:0] y;
wire o_flow, u_flow;

floating_point_spmul DUT (y, u_flow, o_flow, a, b);

initial begin
    $dumpfile("floating_point.vcd");
    $dumpvars(0, floating_point_spmul_tb);

    a = 32'h512a83d2;
    b = 32'h2895468e;
    $display("   ");
    $display (" multiplicand = %b,  multiplier = %b", a, b);
    #2 $display (" final_product = %b, under_flow = %b, over_flow = %b", y, u_flow, o_flow);
    $display("_______________________________________________________________________");

    a = 32'h4fc8f240;
    b = 32'h3cb63e8e;
    $display("   ");
    $display (" multiplicand = %b,  multiplier = %b", a, b);
    #2 $display (" final_product = %b, under_flow = %b, over_flow = %b", y, u_flow, o_flow);
    $display("_______________________________________________________________________");

    a = 32'h6274a8df;
    b = 32'h79da256c;
    $display("   ");
    $display (" multiplicand = %b,  multiplier = %b", a, b);
    #2 $display (" final_product = %b, under_flow = %b, over_flow = %b", y, u_flow, o_flow);
    $display("_______________________________________________________________________");

    a = 32'h226b4f5e;
    b = 32'h14977ee1;
    $display("   ");
    $display (" multiplicand = %b,  multiplier = %b", a, b);
    #2 $display (" final_product = %b, under_flow = %b, over_flow = %b", y, u_flow, o_flow);
    $display("_______________________________________________________________________");
end
endmodule