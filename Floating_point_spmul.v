///////////////////////////////////////////////////////////////////////////////////////////////
// Institution: University Visvesvaraya College of Engineering
// Project Guide: Dr. B P Harish, Chairman and Asst professor, ECE Dept, UVCE.
// Student: Sagar B C (20GAMD3015), IV sem M Tech in ECE, UVCE.
// Create Date:  15/10/2022 
// Design Name: IEEE 754 standard Single precison floating point multiplier.
// Module Name: floating_point_spmul
// Project Name: IEEE 754 standard Single precison floating point multiplier using 
//              Modified Booth Encoding, Wallace tree structure and Ripple carry adder.
// Target Devices: Xilinx FPGAs - Xilinx Spartan6, Artix 7 etc
// Tool versions: Xilinx ISE 14.7
// Description: IEEE 754 standard single precision floating  multiplier is designed by employing 
//              modified booth encoding, Wallace tree and final stage reduction is done by using 
//              RCA adder. A novel   and   efficient   method  is developed for partial product
//              generation and reduction. Mantissa multiplier module is designed and implemented 
//              in mul_24bit.v file 
// Submodules : Exponent Adder, Ripple Carry Adder, Ripple carry subtractor, 24-bit multiplier
//              Ripple carry half adder, Full Adder, Half Adder
// Version : v1.0
//////////////////////////////////////////////////////////////////////////////////

`include "Mul_SKS_24bit.v"    // 24 bit mantissa multiplier 

// Top module begins here
module floating_point_spmul (f_prod, u_flow, o_flow, a, b);
input [31:0] a, b;        // Multiplier and multiplicand operands
output [31:0] f_prod;     // Final product after normalisation and rounding
output u_flow, o_flow;    // Underflow and overflow flags

wire s_a, s_b, s_prod;    // sign bits 
wire [7:0] exp_a, exp_b;  // Exponent parts
wire [9:0] exp_m;         // Intermediate exponent before normalisation
wire [23:0] sig_a, sig_b; // Significands
wire [47:0] sig_m;        // Product of significands

// Extracting sign bit, Exponent and mantissa parts from operands
assign s_a = a[31];              // Sign bit of multiplicand
assign s_b = b[31];              // Sign bit of multiplier
assign exp_a = a[30:23];         // Exponent of multiplicand
assign exp_b = b[30:23];         // Exponenet of multiplier
assign sig_a = {1'b1, a[22:0]};  // Adding  hidden bit 1'b1 to mantissa part to form significands
assign sig_b = {1'b1, b[22:0]};

assign s_prod = s_a ^ s_b;    // Sign bit of final product


Exponent_adder EXA (.z(exp_m), .x(exp_a), .y(exp_b));         // Exponent adder
mul_24bit mant_mul (.y(sig_m), .a(sig_a), .b(sig_b));         // Significand Multiplier
Normaliser NZ (f_prod, u_flow, o_flow, exp_m, sig_m, s_prod); // Normaliser 

endmodule
// Top module ends here

module Exponent_adder (z, x, y);
input [7:0] x, y;    // Exponents
output [9:0] z;      // Intermediate exponent after subtraction of bias = 127
wire [8:0] w;        // Sum of exponents

RCA_8bit RCA (.sum(w), .x(x), .y(y));  // RCA for addition of exponents
RBS_bias RCB (.y(z), .x(w));           // RBS for subtraction of bias
  
endmodule

// 8-bit Ripple Carry Adder module for Exponents addition
module RCA_8bit (sum, x, y);
input [7:0] x, y;
output [8:0] sum;
wire [7:0] c;
wire [7:0] s;
genvar i;
assign sum = {c[7], s[7:0]};

Half_Adder HA_E0 (s[0], c[0], x[0], y[0]);

generate for (i = 0; i < 7; i = i + 1)
begin : FA_Exp
Full_Adder FA_E (s[i+1], c[i+1], x[i+1], y[i+1], c[i]);
end
endgenerate
endmodule

// 9-bit Ripple borrow subtractor module for bias = 001111111 (127) subtraction
// Implemented using 2 Zero subtractors followed by 7 One suntractors
module RBS_bias (x, y);
input [8:0] x;
output [9:0] y;
wire bout;
wire [7:0] b;
wire [8:0] t;
genvar i;

assign y = {bout, t[8:0]};
One_sub OS0 (t[0], b[0], x[0], 1'b0);

generate for (i = 1; i < 7; i = i + 1)
begin : One_S 
One_sub OS (t[i], b[i], x[i], b[i-1]);
end
endgenerate

Zero_sub ZS0 (t[7], b[7], x[7], b[6]);
Zero_sub ZS1 (t[8], bout, x[8], b[7]);
endmodule

// One subractor module
module One_sub (s, cy, a, b);
input a, b;
output s, cy;

xnor OG1 (s, a, b);
or OG2 (cy, ~a, b);
endmodule


// Zero subtractor module
module Zero_sub (s, cy, a, b);
input a, b;
output s, cy;

xor ZG3 (s, a, b);
and ZG4 (cy, ~a, b);
endmodule 

//Half_Adder module
module Half_Adder (s, cout, a, b);
input a, b;
output s, cout;

assign s = a ^ b;
assign cout = a & b;
endmodule

//Full Adder module
module Full_Adder (s, cout, a, b, cin);
input a, b, cin;
output s, cout;

assign s = a ^ b ^ cin;
assign cout = (a & b) | (b & cin) | (cin & a);
endmodule

// Normaliser block for normalisation of exponent and significands product
module Normaliser (f_prod, u_flow, o_flow, exp_m, sig_m, s_prod);
input [9:0] exp_m;
input [47:0] sig_m;
input s_prod;
output u_flow, o_flow;
output [31:0] f_prod;

wire [7:0] exp_prod; // Exponent of final product
wire [9:0] exp_n;    // Exponent after normalisation of significand product
wire [22:0] m_int;   // Mantissa part of final product after truncation (Round to zero)
wire flag;

// 10-bit RCHA for exponent adjustment after normalisation of significand product
RCHA_10bit RCHA_10 (.y(exp_n), .a(exp_m), .cin(sig_m[47])); 

assign u_flow = exp_n[9];            // Under and overflow flag detection
assign o_flow = exp_n[8] & ~exp_n[9];
assign flag = u_flow | o_flow;

// Overflow : Exponent = 8'hff to indicate infinity
// Underflow : Exponent = 8'h00 to indicate Zero
assign exp_prod = flag ? (u_flow ? 8'h00 : 8'hff) : exp_n[7:0];
assign m_int = flag ? {3'b000,20'h00000} : (sig_m[47] ? sig_m[46:24] : sig_m[45:23]);
assign f_prod = {s_prod, exp_prod, m_int};
endmodule

// Ripple carry Half Adder
module RCHA_10bit (y, a, cin);
input [9:0] a;
input cin;
output [9:0] y;
wire [9:0] c;
genvar i;
Half_Adder HRC_0 (y[0], c[0], a[0], cin);
generate for (i = 1; i < 10; i = i + 1)
begin : RC_10bit 
Half_Adder HRC_10 (y[i], c[i], a[i], c[i-1]);
end
endgenerate
endmodule






