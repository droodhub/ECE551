module steer_en(clk, rst_n, lft_ld, rght_ld, en_steer, rider_off);

	parameter fast_sim = 1;
	
	input clk, rst_n;
	input [11:0] lft_ld, rght_ld;
	output en_steer, rider_off;

	localparam MIN_RIDER_WT = 12'h200;
	localparam WT_HYSTERESIS = 8'h40;

	//Intermediate logic
	logic [12:0]sum;
	logic [11:0]diff;
	logic [11:0]abs_diff;
	logic [11:0]sum_15_16;
	logic [10:0]sum_1_4;
	logic clr, full;
	reg [25:0]tmr;
	
	reg rider_off;
	reg en_steer;
	

	assign sum = lft_ld + rght_ld;
	assign diff = lft_ld - rght_ld;

	assign abs_diff = (diff[11] == 1)? 1 + ~diff : diff;

	//assigning sum min gt lt min
	assign sum_lt_min = (sum < MIN_RIDER_WT - WT_HYSTERESIS);
	assign sum_gt_min = (sum > MIN_RIDER_WT + WT_HYSTERESIS);


	//Getting scale values
	assign sum_15_16 = (sum[12:1]/* 1/2 */ + sum[12:2] /* 1/4 */ + sum[12:3] /* 1/8 */ + sum[12:4] /* 1/16 */);
	assign sum_1_4 = sum[12:2];

	//assigning gt 1/4 and gt 15/16
	assign diff_gt_1_4 = (abs_diff > sum_1_4);
	assign diff_gt_15_16 = (abs_diff > sum_15_16);
	
	
	//TIMER BLOCK based off 50MHz clk
	
	always @(posedge clk)
		if(clr)
			tmr <= '0;
		else
			tmr <= tmr + 1;
	
	
	generate if(fast_sim)
		assign full = &tmr[14:0];
		else
			assign full = &tmr;
	endgenerate

	//Instantiate steen_en_SM here
	
	steer_en_SM SM(.clk, .rst_n, .clr_tmr(clr), .tmr_full(full), .sum_gt_min, .sum_lt_min, .diff_gt_1_4, .diff_gt_15_16, .rider_off, .en_steer);
	

endmodule
