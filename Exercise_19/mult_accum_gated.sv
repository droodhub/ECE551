module mult_accum(clk,clr,en,A,B,accum);

input clk,clr,en;
input [15:0] A,B;
output reg [63:0] accum;

reg [31:0] prod_reg;
reg en_stg2, mult_clk, accum_clk, clk_en_mult, clk_en_accum;

always @* begin //gated clock latches
	if(~clk) begin	
		clk_en_accum <= en_stg2;
		clk_en_mult <= en;
	end	
end
assign mult_clk = clk && clk_en_mult; //input to multiplier FF
assign accum_clk = clk && clk_en_accum; //input to accumulator FF, should be 1 clock cycle behind mult_clk



///////////////////////////////////////////
// Generate and flop product if enabled //
/////////////////////////////////////////
always_ff @(posedge mult_clk)
      prod_reg <= A*B;

/////////////////////////////////////////////////////
// Pipeline the enable signal to accumulate stage //
///////////////////////////////////////////////////
always_ff @(posedge clk)
    en_stg2 <= en;

always_ff @(posedge accum_clk)
    if (clr)
      accum <= 64'h0000000000000000;
    else
      accum <= accum + prod_reg;

endmodule
