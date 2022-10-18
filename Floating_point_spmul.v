/////////////////////////////////////////////////////////////////////////////////
// Institution: University Visvesvaraya College of Engineering
// Project Guide: Dr. B P Harish, Chairman and Asst professor, ECE Dept, UVCE.
// Student: Sagar B C (20GAMD3015), IV sem M Tech in ECE, UVCE.
// Create Date:  15/10/2022 
// Design Name: IEEE 754 standard Single precison floating point multiplier .
// Module Name: floating_point_spmul
// Project Name: IEEE 754 standard Single precison floating point multiplier using 
//              Modified Booth Encoding, Wallace tree structure and Ripple carry adder.
// Target Devices: Xilinx FPGAs - Xilinx Spartan6, Artix 7 etc
// Tool versions: Xilinx ISE 14.7.
// Description: IEEE 754 standard single precision floating  multiplier is designed by employing modified booth
//              encoding and final stage reduction is done by using RCA adder.
//              A novel  and  efficient  way  is developed for partial product
//              generation and reduction.
// Version : v1.0
//
//////////////////////////////////////////////////////////////////////////////////







`include "mul_24bit.v"
module floating_point_spmul (a, b, f_prod, u_flow, o_flow);
input [31:0] a, b;   // Multiplier and multiplicand operands
output [31:0] f_prod;     // Final product after normalisation and rounding
output u_flow, o_flow; // Underflow and overflow flags

wire s_a, s_b, s_prod;           // sign bits 
wire [7:0] exp_a, exp_b; // Exponent parts
wire [9:0] exp_m;       // Intermediate exponent before normalisation
wire [23:0] sig_a, sig_b; // Significands
wire [47:0] sig_m;  // Product of significands

// Extracting sign bit, Exponent and mantissa parts
assign s_a = a[31];
assign s_b = b[31];
assign exp_a = a[30:23];
assign exp_b = b[30:23];
assign sig_a = {1'b1, a[22:0]};  // Adding  hidden bit 1'b1 to mantissa part to form significands
assign sig_b = {1'b1, b[22:0]};

assign s_prod = s_a ^ s_b;    // Sign bit of final result

// To find resultant exponent
Exponent_adder EXA (.x(exp_a), .y(exp_b), .z(exp_m));
mul_24bit mant_mul (.y(sig_m), .a(sig_a), .b(sig_b));
Normaliser NZ (f_prod, u_flow, o_flow, exp_m, sig_m, s_prod);

endmodule

module Exponent_adder (x, y, z);
input [7:0] x, y;
output [9:0] z;
wire [8:0] w;

RCA_8bit RCA (.x(x), .y(y), .sum(w));
RBS_bias RCB (.x(w), .y(z));

endmodule

module RCA_8bit (x, y, sum);
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

module One_sub (s, cy, a, b);
input a, b;
output s, cy;

xnor OG1 (s, a, b);
or OG2 (cy, ~a, b);
endmodule

module Zero_sub (s, cy, a, b);
input a, b;
output s, cy;

xor ZG3 (s, a, b);
and ZG4 (cy, ~a, b);
endmodule 

module Half_Adder (s, cout, a, b);
input a, b;
output s, cout;

assign s = a ^ b;
assign cout = a & b;
endmodule

module Full_Adder (s, cout, a, b, cin);
input a, b, cin;
output s, cout;

assign s = a ^ b ^ cin;
assign cout = (a & b) | (b & cin) | (cin & a);
endmodule


module Normaliser (f_prod, u_flow, o_flow, exp_m, sig_m, s_prod);
input [9:0] exp_m;
input [47:0] sig_m;
input s_prod;
output u_flow, o_flow;
output [31:0] f_prod;

wire [7:0] exp_prod;
wire [9:0] exp_n;   // Exponent after normalisation of mantissa product
wire [22:0] m_int;
wire flag;
RCA_10bit RC_10 (.y(exp_n), .a(exp_m), .cin(sig_m[47]));

assign u_flow = exp_n[9];
assign o_flow = exp_n[8] & ~exp_n[9];
assign flag = u_flow | o_flow;

assign exp_prod = flag ? (u_flow ? 8'h00 : 8'hff) : exp_n[7:0];
//assign m_int = flag ? (u_flow ? {3'b000,20'h00000} : {3'b111, 20'hfffff}) : (sig_m[47] ? sig_m[46:24] : sig_m[45:23]);
assign m_int = flag ? {3'b000,20'h00000} : (sig_m[47] ? sig_m[46:24] : sig_m[45:23]);
assign f_prod = {s_prod, exp_prod, m_int};
endmodule

module RCA_10bit (y, a, cin);
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






