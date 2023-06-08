module balance_cntrl(input clk, input rst_n, input vld, input signed[15:0]ptch, input signed[15:0]ptch_rt, input pwr_up, input rider_off,
						 input [11:0]steer_pot, input en_steer, output signed[11:0]lft_spd, output signed[11:0]rght_spd, output too_fast);

parameter fast_sim = 1;

logic[11:0] PID_cntrl;
logic[7:0] ss_tmr;

PID #(1)ipid(.ptch(ptch), .ptch_rt(ptch_rt), .clk(clk), .rst_n(rst_n),
				 .vld(vld), .pwr_up(pwr_up), .rider_off(rider_off), .ss_tmr(ss_tmr), .PID_cntrl(PID_cntrl));
				 
segway_math isegway(.ss_tmr(ss_tmr), .PID_cntrl(PID_cntrl), .steer_pot(steer_pot), .en_steer(en_steer), .pwr_up(pwr_up),
			.lft_spd(lft_spd), .rght_spd(rght_spd), .too_fast(too_fast));




endmodule
