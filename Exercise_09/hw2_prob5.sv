module latch(input d, input clk, output reg q1, output reg q2, output reg q3, 
				input synch_rst, input rst_n, input s, input r, input rst_n_sr, input en);

//the code in the slides does not model a latch correctly
//it should be always @(posedge clk) or negedge
//that way it is working in time with the clock cycle as opposed to whenever clk = 1

//D-FF with synch reset
always @(posedge clk) begin //reset not in trigger list as it is synchronous
	if(synch_rst) //verify reset first, either reset value or set to d
		q1 <= 1'b0;
	else
		q1 <= d;
end

//D-FF with asynch low reset
always @(posedge clk, negedge rst_n) begin //rst_n going from high to low should trigger the reset
	if(!rst_n) //check reset first as it takes priority
		q2 <= 1'b0;
	else if(en) //values will only change if enabled
		q2 <= d;
end

always_ff @(posedge clk, negedge rst_n_sr) begin //does not guarantee a flop
//always_ff will warn the user if code is written that does not infer a flop
//a warning does not mean it won't compile and run, however, nor does it guarantee a FF can be generated from the code
	if(!rst_n_sr) //check in order of priority -- asynch reset, r, s
		q3 <= 1'b0;
	else if(r)
		q3 <= 1'b0;
	else if(s)
		q3 <= 1'b1; 
end
endmodule