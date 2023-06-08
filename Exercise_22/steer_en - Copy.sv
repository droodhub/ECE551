module steer_en(input clk, input rst_n, input [11:0]lft_ld, input [11:0]rght_ld, output en_steer, output rider_off);

parameter fast_sim = 1;
localparam MIN_RIDER_WT = 10'h200;
localparam WT_HYSTERESIS = 7'h40;

logic [25:0] clk_tmr;
logic [12:0] sum, sum_fraction;
logic [11:0] diff, abs_diff;
logic sum_lt_min, sum_gt_min, diff_gt_15_16, diff_gt_1_4, tmr_full, clr_tmr;

assign sum = lft_ld + rght_ld;
assign sum_15_16 = {sum[12:1] + sum[12:2] + sum[12:3] + sum[12:4]};
assign diff = lft_ld - rght_ld;
assign abs_diff = diff[11] ? (~diff + 1) : diff; 

assign sum_gt_min = sum > (MIN_RIDER_WT + WT_HYSTERESIS);
assign sum_lt_min = sum < (MIN_RIDER_WT - WT_HYSTERESIS);

assign diff_gt_1_4 = {sum[12], sum[12:2]} < abs_diff;
assign diff_gt_15_16 = abs_diff > sum_15_16;

generate
	if(fast_sim)
		assign tmr_full = &clk_tmr[14:0];
	else	
		assign tmr_full = (clk_tmr == 26'b11111111100101011011000000); //1.34sec @50MHz is this many cycles

endgenerate

always_ff @(posedge clk) begin
	if(clr_tmr) 
		clk_tmr = '0;
	else
		clk_tmr <= clk_tmr + 1;
end

steer_en_SM mySM(.clk(clk), .rst_n(rst_n), .tmr_full(tmr_full), .sum_gt_min(sum_gt_min), .sum_lt_min(sum_lt_min),
					.diff_gt_1_4(diff_gt_1_4), .diff_gt_15_16(diff_gt_15_16), .clr_tmr(clr_tmr), .en_steer(en_steer), .rider_off(rider_off));
					
endmodule