module PWM11(input clk, input rst_n, input [10:0] duty, output reg PWM_sig, output PWM_synch, output OVR_I_blank_n);

logic [10:0] cnt;
logic set, reset, SR_output;

//bitwise NOR duty together -- if all zeros, it will be 1 and set will be active
assign set = (~|cnt); 
assign reset = (cnt>=duty) ? 1'b1 : 1'b0;

//check if cnt is all 1s for synch
assign PWM_synch = &cnt;

//we won't look for the over current until the first 255
//cycles have passed
assign OVR_I_blank_n = (cnt>255) ? 1'b1 : 1'b0;

///SR FF with active low reset
always_ff @(posedge clk, negedge rst_n) begin 
	if(!rst_n) 
		PWM_sig <= 1'b0;
	else if(reset) 
		PWM_sig <= 1'b0;
	else if(set) 
		PWM_sig <= 1'b1;

end

//logic for incrementing count
always_ff @(posedge clk, negedge rst_n) begin 
	if(!rst_n)
		cnt <= 1'b0;
	else //increment counter
		cnt <= cnt + 1;
end

endmodule
