module SegwayMath(PID_cntrl, ss_tmr, steer_pot, en_steer, pwr_up, lft_spd, rght_spd, too_fast);
	input signed [11:0]PID_cntrl;
	input [11:0]steer_pot;
	input [7:0]ss_tmr;
	input en_steer, pwr_up;
	output signed [11:0]lft_spd, rght_spd;
	output too_fast;

//LOCALPARAMS
	localparam MIN_DUTY = 13'h3C0;
	localparam LOW_TORQUE_BAND = 8'h3C;
	localparam GAIN_MULT = 6'h10;

////////////////////////////////////
//WIRES
////////////////////////////////////
wire signed [8:0]ss_tmr_zext;//need to declare sign extended ss_tmr so can do signed multiply with PID_cntrl
wire signed [19:0] ss_tmr_zext_mult_PID_cntrl;
wire signed [11:0]PID_ss;

wire [11:0]steer_pot_clipped;
	wire signed [11:0] steer_pot_signed;
	wire signed[11:0] steer_pot_one_eigth;
	wire signed[11:0] steer_pot_one_sixteen;
	wire signed[11:0] steer_pot_three_sixteen;	

	wire signed [12:0]PID_ss_sext_13b;
	wire signed [12:0]lft_torque,rght_torque;


wire signed [12:0]lft_torque_minus_MIN_DUTY;
	wire signed [12:0]lft_torque_plus_MIN_DUTY;
	wire signed [12:0]lft_torque_comp;
	wire signed [12:0] lft_torque_mult_GAIN_MULT;
	wire signed [12:0]lft_mux2_to_mux3;
	wire [12:0]abs_lft_torque;
	wire signed [12:0]lft_shaped;

wire signed [12:0]rght_torque_minus_MIN_DUTY;
	wire signed [12:0]rght_torque_plus_MIN_DUTY;
	wire signed [12:0]rght_torque_comp;
	wire signed [12:0]rght_torque_mult_GAIN_MULT;
	wire signed [12:0]rght_mux2_to_mux3;
	wire [12:0]abs_rght_torque;
	wire signed [12:0]rght_shaped;
	
	////////////////////////////////////
	//Scaling PID_cntrl with ss_tmr to remove "jerk"
	////////////////////////////////////
	assign ss_tmr_zext = {1'b0,ss_tmr}; 
	assign ss_tmr_zext_mult_PID_cntrl = $signed(ss_tmr_zext) * PID_cntrl;
	assign PID_ss = {ss_tmr_zext_mult_PID_cntrl[19:8]};

	assign steer_pot_clipped =	(steer_pot < 12'h200)? 12'h200:
								(steer_pot > 12'hE00)? 12'hE00:
								steer_pot;
								
								
	assign steer_pot_signed = steer_pot_clipped - 12'h7ff;
	
	////////////////////////////////////
	//This block needs a 2 bit R shift added with a 3 bit R shift to efficiently multiply by 3/16
	////////////////////////////////////
	assign steer_pot_one_eigth = {{4{steer_pot_signed[11]}},steer_pot_signed[11:3]};
	assign steer_pot_one_sixteen = {{5{steer_pot_signed[11]}},steer_pot_signed[11:4]};
	assign steer_pot_three_sixteen = steer_pot_one_eigth + steer_pot_one_sixteen;
	
	
	assign PID_ss_sext_13b = {PID_ss[11],PID_ss};
	assign lft_torque = (en_steer)?(PID_ss_sext_13b + steer_pot_three_sixteen):(PID_ss_sext_13b);
	assign rght_torque = (en_steer)?(PID_ss_sext_13b - steer_pot_three_sixteen):(PID_ss_sext_13b);
	
	
	////////////////////////////////////
	//Left wheel dataflow
	////////////////////////////////////
	assign lft_torque_minus_MIN_DUTY = lft_torque - MIN_DUTY;
	assign lft_torque_plus_MIN_DUTY = lft_torque + MIN_DUTY;
	assign lft_torque_comp = (lft_torque[12])?lft_torque_minus_MIN_DUTY:lft_torque_plus_MIN_DUTY;
	assign lft_torque_mult_GAIN_MULT = lft_torque * $signed(GAIN_MULT);
	assign abs_lft_torque = (lft_torque[12])? ~lft_torque+1 : lft_torque;
	
	assign lft_mux2_to_mux3 = (abs_lft_torque > LOW_TORQUE_BAND)? lft_torque_comp : lft_torque_mult_GAIN_MULT;
	assign lft_shaped = (~pwr_up)? 13'h0000:lft_mux2_to_mux3;
	
	////////////////////////////////////
	//Right wheel dataflow
	////////////////////////////////////
	assign rght_torque_minus_MIN_DUTY = rght_torque - MIN_DUTY;
	assign rght_torque_plus_MIN_DUTY = rght_torque + MIN_DUTY;
	assign rght_torque_comp = (rght_torque[12])?rght_torque_minus_MIN_DUTY:rght_torque_plus_MIN_DUTY;
	assign rght_torque_mult_GAIN_MULT = rght_torque * $signed(GAIN_MULT);
	assign abs_rght_torque = (rght_torque[12])? ~rght_torque+1 : rght_torque;
	
	assign rght_mux2_to_mux3 = (abs_rght_torque > LOW_TORQUE_BAND)? rght_torque_comp : rght_torque_mult_GAIN_MULT;
	assign rght_shaped = (~pwr_up)? 13'h0000:rght_mux2_to_mux3;
	
	////////////////////////////////////
	//Saturate lft_shaped and rght_shaped to 12 bits
	///////////////////////////////////
	assign lft_spd = (~lft_shaped[12] && (lft_shaped[11]))?12'h7ff:
						(lft_shaped[12] && !(&lft_shaped[11]))?12'h800:
						{lft_shaped[12],lft_shaped[10:0]};
	
	assign rght_spd = (~rght_shaped[12] && (rght_shaped[11]))?12'h7ff:
						(rght_shaped[12] && !(&rght_shaped[11]))?12'h800:
						{rght_shaped[12],rght_shaped[10:0]};
						
	assign too_fast = (lft_spd > $signed(12'd1792) || rght_spd > $signed(12'd1792))?1:0;

	



endmodule