module balance_cntrl_chk_tb();
logic [48:0] stim [0:1499];
logic [48:0] memory;
logic [24:0] outputs, correct_outputs;
logic [24:0] resp [0:1499];
logic [10:0] line;
logic clk;

balance_cntrl	iDUT(.clk(clk), .rst_n(memory[48]), .vld(memory[47]), .ptch(memory[46:31]), .ptch_rt(memory[30:15]), .pwr_up(memory[14]), 
				.rider_off(memory[13]), .steer_pot(memory[12:1]), .en_steer(memory[0]), 
				.lft_spd(outputs[24:13]), .rght_spd(outputs[12:1]), .too_fast(outputs[0]));

initial begin
clk = 1'b0;
line = '0;
force iDUT.ss_tmr = 8'hFF;
$readmemh("balance_cntrl_stim.hex", stim);
$readmemh("balance_cntrl_resp.hex", resp);

for(line = 0; line < 1500; line = line + 1) begin //run through all 1500 lines of test file
	@(negedge clk) begin //update inputs & expected outputs
		memory <= stim[line]; 
		correct_outputs <= resp[line];
	end
	@(posedge clk) begin
		#1;
		if(correct_outputs!== outputs) begin
			if(outputs[24:13] !== correct_outputs[24:13])
				$display("Actual lft_spd: %h, Expected lft_spd: %h", outputs[24:13], correct_outputs[24:13]);
			if(outputs[12:1] !== correct_outputs[12:1])
				$display("Actual rght_spd: %h, Expected rght_spd: %h", outputs[12:1], correct_outputs[12:1]);
			if(outputs[0] !== correct_outputs[0])
				$display("Actual too_fast: %h, Expected too_fast: %h", outputs[0], correct_outputs[0]);
			$display("\n");
		end
	end
end
$display("YAHOO! All tests passed");
$stop();
end


always
	#5 clk = ~clk;

endmodule
