module PID_math(input signed [15:0]ptch, input signed [15:0] ptch_rt, input signed [17:0] integrator, output signed [11:0] PID_cntrl);

logic signed [9:0] ptch_err_sat;
localparam P_COEFF = 5'h0C;
logic signed [14:0] P_term;
logic signed [14:0] I_term;
logic signed [12:0] D_term;
logic signed [15:0] sum;
logic signed [15:0] P_ext, I_ext, D_ext;

//saturate the pitch error
assign ptch_err_sat = (~ptch[15] && |ptch[14:9])? 10'h1FF :(ptch[15] && ~&ptch[14:9])? 10'h200 : 
						{ptch[15], ptch[8:0]};

//signed multiply of P_COEFF as signed localparams are not recommended
assign P_term = $signed(P_COEFF) * ptch_err_sat;

//sign extend integrator while dividing by 64(6 bit shift)
assign I_term = {{3{integrator[17]}}, integrator[17:6]};

//sign extend and divide by 64 again, but also invert the value w/one's complement
assign D_term = ~({{3{ptch_rt[15]}}, ptch_rt[15:6]});

//ensure all signals to be summed are the same length
assign P_ext = {P_term[14], P_term[14:0]};
assign I_ext = {I_term[14], I_term[14:0]};
assign D_ext = {{3{D_term[12]}}, D_term[12:0]};

//sum signals
assign sum = P_ext + I_ext + D_ext;

//saturate sum to reduce signal size
assign PID_cntrl = (~sum[15] && |sum[14:11])? 12'h7FF :(sum[15] && ~&sum[14:11])? 12'h800 : 
						{sum[15], sum[10:0]};
						
endmodule
