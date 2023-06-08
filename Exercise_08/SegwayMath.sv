module segway_math(input signed[11:0] PID_cntrl, input[7:0] ss_tmr, input[11:0]steer_pot, input en_steer, input pwr_up,
			output signed[11:0]lft_spd, output signed[11:0]rght_spd, output too_fast);
	
	localparam MIN_DUTY = 13'h3C0;
	localparam LOW_TORQUE_BAND = 8'h3C;
	localparam GAIN_MULT = 6'h10;
	
	//intermediate PID signals
	logic signed [19:0]large_PID_ss; //PID scaled by ss_tmr
	logic signed [11:0]PID_ss; //PID_ss divided by 256 and then sign extended below
	logic signed [12:0]PID_ss_ext;
	
	
	logic [11:0]steer_pot_clipped; //value for steer_pot confined from h200 - hE00
	logic signed [11:0]steer_pot_signed;
	logic signed [12:0]steer_pot_8th, steer_pot_16th, scaled_steer_pot; //sum 1/8 and 1/16 to get 3/16
	
	//various intermediate torque signals from slides 4 & 6
	logic signed [12:0]lft_torque, rght_torque, lft_torque_select, rght_torque_select, lft_torque_comp,
				rght_torque_comp; 
				
	//magnitude of torque values to compare to LOW_TORQUE_BAND
	logic [12:0] lft_torque_abs, rght_torque_abs; 
	
	//input and output of muxes to shape the torque
	logic signed [12:0] lft_shaped_pre, rght_shaped_pre, lft_shaped, rght_shaped; 
	
	//product of GAIN_MULT and torque
	logic signed [12:0] rght_gain_check, lft_gain_check; 
	
	//0 extend ss_tmr and do signed multiplication
	assign large_PID_ss = $signed({1'b0, ss_tmr}) * PID_cntrl; 
	assign PID_ss = large_PID_ss[19:8]; // divide by 256 is a shift of 8 bits
	assign PID_ss_ext = {PID_ss[11], PID_ss};
	
	//clip steer_pot and then make it a signed value by subtracting 12'h7FF
	assign steer_pot_clipped = (~|steer_pot[11:9])? 12'h200 : (&steer_pot[11:9])? 12'hE00 : steer_pot; 
	assign steer_pot_signed = steer_pot_clipped - 12'h7FF;
	
	//multiply by 3/16 by summing 1/8th and 1/16th
	assign steer_pot_8th = {{4{steer_pot_signed[11]}}, steer_pot_signed[11:3]};
	assign steer_pot_16th = {{5{steer_pot_signed[11]}}, steer_pot_signed[11:4]};
	assign scaled_steer_pot = steer_pot_16th + steer_pot_8th;
	
	//input values for left & right torque muxes
	assign lft_torque_select = PID_ss_ext + scaled_steer_pot;
	assign rght_torque_select = PID_ss - scaled_steer_pot;
	
	//assign based on steering enabled signal
	assign lft_torque = en_steer ? lft_torque_select : PID_ss_ext;
	assign rght_torque = en_steer ? rght_torque_select : PID_ss_ext;
	
	//add/subtract MIN_DUTY if torque is pos or neg
	assign lft_torque_comp = lft_torque[12]? (lft_torque - MIN_DUTY) : (lft_torque + MIN_DUTY);
	assign rght_torque_comp = rght_torque[12]? (rght_torque - MIN_DUTY) : (rght_torque + MIN_DUTY);
	
	//scaled torque value for when torque is in the low torque band
	assign lft_gain_check = $signed(GAIN_MULT) * lft_torque;
	assign rght_gain_check = $signed(GAIN_MULT) * rght_torque;
	
	//either convert to positive 2's complement if negative, or leave as is for magnitude 
	assign lft_torque_abs = lft_torque[12] ? (~lft_torque + 1) : lft_torque;
	assign rght_torque_abs = rght_torque[12] ? (~rght_torque + 1) : rght_torque;
	
	//if out of low torque band, assign to torque + duty
	//otherwise, need to use the multiplied value to change the slope of the torque
	assign lft_shaped_pre = (lft_torque_abs > LOW_TORQUE_BAND) ? lft_torque_comp : lft_gain_check;
	assign rght_shaped_pre = (rght_torque_abs > LOW_TORQUE_BAND) ? rght_torque_comp : rght_gain_check;
	
	//either enabled and we use the value calculated, or set to 0
	assign lft_shaped = pwr_up ? lft_shaped_pre : 13'h0000;
	assign rght_shaped = pwr_up ? rght_shaped_pre : 13'h0000;
	
	//saturate values from 13 to 12 bits
	assign lft_spd = (~lft_shaped[12] && lft_shaped[11]) ? 12'h7FF : 
						(lft_shaped[12] && !lft_shaped[11]) ? 12'h800 : {lft_shaped[12], lft_shaped[10:0]};
	assign rght_spd = (~rght_shaped[12] && rght_shaped[11]) ? 12'h7FF : 
						(rght_shaped[12] && !rght_shaped[11]) ? 12'h800 : {rght_shaped[12], rght_shaped[10:0]};
	
	assign too_fast = (lft_shaped > $signed(12'd1792)) ? 1 : (rght_shaped > $signed(12'd1792)) ?  1 : 0;

	
endmodule
