module segway_math_tb();
logic signed [11:0] PID_cntrl, lft_spd, rght_spd;
logic [11:0] steer_pot;
logic en_steer, too_fast, pwr_up;
logic [7:0] ss_tmr;

segway_math iDUT(.PID_cntrl(PID_cntrl), .lft_spd(lft_spd), .rght_spd(rght_spd), .steer_pot(steer_pot), 
					.en_steer(en_steer), .too_fast(too_fast), .pwr_up(pwr_up), .ss_tmr(ss_tmr));

initial begin
	//test structure provided by exercise outline
	PID_cntrl = 12'h3FF;
	ss_tmr = 8'h00;
	en_steer = 0;
	pwr_up = 1;
	steer_pot = 12'h000;
	
	//ramp up ss_tmr until it reaches it max value
	repeat(255) begin
		#1 ss_tmr = ss_tmr + 1;
	end

	//reduce PID_cntrl to 0 
	//looking for proper torque shaping from this test & too_fast signal
	repeat(2047) begin 
		#1 PID_cntrl = PID_cntrl - 1;
	end
	
	
	PID_cntrl = 12'h3FF;
	ss_tmr = 8'hFF;
	en_steer = 1;
	pwr_up = 1;
	steer_pot = 12'h000;
	//reduce PID_cntrl while incrementing steer_pot
	//trying to see different slopes for torque gain shaping region
	repeat(2047) begin
		#2 
		PID_cntrl = PID_cntrl - 1;
		steer_pot = steer_pot + 2;
	end
	
	//set pwr_up to 0, should see lft & rght signals 0 out
	pwr_up = 0;
	#100;
	

end
endmodule
