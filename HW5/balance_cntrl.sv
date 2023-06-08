module balance_cntrl(clk, rst_n, vld, ptch, ptch_rt, pwr_up, rider_off, steer_pot, en_steer, lft_spd, rght_spd, too_fast);

parameter fast_sim = 1;


input clk, rst_n, vld, rider_off, en_steer, pwr_up;
input [15:0]ptch, ptch_rt;
input [11:0]steer_pot;

output [11:0]lft_spd, rght_spd;
output too_fast;

wire [11:0]PID_cntrl;
wire [7:0]ss_tmr;

PID #(fast_sim) pid1(.clk, .rst_n, .vld, .pwr_up, .rider_off, .ptch, .ptch_rt, .PID_cntrl, .ss_tmr);

SegwayMath swm(.PID_cntrl, .ss_tmr, .steer_pot, .en_steer, .pwr_up, .lft_spd, .rght_spd, .too_fast);

endmodule