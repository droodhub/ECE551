module PID(input signed [15:0]ptch, input signed [15:0] ptch_rt, input clk, input rst_n,
				 input vld, input pwr_up, input rider_off, output [7:0] ss_tmr, output signed [11:0] PID_cntrl);
				 
parameter fast_sim = 1; //defaulting to fast simulation

logic signed [9:0] ptch_err_sat;
logic signed [17:0] ptch_err_sat_ext, sum_I_term, vld_mux_output, rider_mux_output;
localparam P_COEFF = 5'h0C;

logic signed [14:0] P_term;
logic signed [14:0] I_term;
logic signed [12:0] D_term;
logic signed [15:0] sum;
logic signed [15:0] P_ext, I_ext, D_ext;
logic signed [17:0] integrator;

logic [26:0] timer;
logic [8:0]add_term;
logic ov;

generate
	if(fast_sim)
		assign add_term = 9'h100;
	else	
		assign add_term = 9'h001;
endgenerate

always_ff @(posedge clk, negedge rst_n) begin

	if(!rst_n)
		timer <= 27'h0000000;
	else if(!pwr_up)
		timer <= 27'h0000000;
	else if(~&timer[26:8]) begin
			timer <= timer + add_term;
	end
	
end

assign ss_tmr = timer[26:19];

//saturate the pitch error
assign ptch_err_sat = (~ptch[15] && |ptch[14:9])? 10'h1FF :(ptch[15] && ~&ptch[14:9])? 10'h200 : 
						{ptch[15], ptch[8:0]};
						
//sign extend for I term				
assign ptch_err_sat_ext = {{8{ptch_err_sat[9]}}, ptch_err_sat};

//intermediate value to calculate the integrator
assign sum_I_term = ptch_err_sat_ext + integrator;

//if integrator & sign extend bits are the same and sum isn't overflow occurred
assign ov = (integrator[17] == ptch_err_sat_ext[17] && ptch_err_sat_ext[17] != sum_I_term[17]) ? 1 : 0;

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) 
		integrator <= 18'h00000;
	else if(rider_off)
		integrator <= 18'h00000;
	else if(vld && ~ov)
		integrator <= sum_I_term;
end

//signed multiply of P_COEFF as signed localparams are not recommended
assign P_term = $signed(P_COEFF) * ptch_err_sat;

generate

	if(fast_sim)
		assign I_term = (~integrator[17] && |integrator[16:15])? 15'h3FFF : 
							(integrator[17] && ~&integrator[16:15]) ? 15'h4000 : integrator[15:1];
	else
		assign I_term = {{3{integrator[17]}}, integrator[17:6]}; 
		//sign extend integrator while dividing by 64(6 bit shift)

endgenerate


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
