module floating_point_spmul_tb;
reg [31:0] a, b;
wire [31:0] y;
wire o_flow, u_flow;

floating_point_spmul DUT (a, b, y, u_flow, o_flow);

initial begin
    //$monitor ("u_flow = %b, o_flow = %b, exp = %b", u_flow, o_flow, DUT.exp_prod);
    a = 32'h2274af6d;
    b = 32'h14a20465;
    $display (" multiplicand = %b  multiplier = %b", a, b);
    #2 $display ("final_product = %b under_flow = %b, over_flow = %b", y, u_flow, o_flow);
end
endmodule