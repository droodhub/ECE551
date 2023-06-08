module pwm_tb();
reg clk;
reg [10:0] duty;
reg rst_n;
wire PWM_sig, PWM_synch, OVR_I_blank_n;

PWM11 iDUT(.clk(clk), .duty(duty), .rst_n(rst_n), .PWM_sig(PWM_sig), .PWM_synch(PWM_synch), .OVR_I_blank_n(OVR_I_blank_n));

initial begin
clk = 0;
duty = 11'h0; //start with 0% duty cycle
rst_n = 0;				//assert reset
@(posedge clk);			// wait one clock cycle
@(negedge clk) rst_n = 1;	// deassert reset on negative edge

//testing min duty cycle
repeat(5)
	repeat(2047) @(posedge clk);

@(negedge clk) rst_n = 0;
@(negedge clk) begin
	rst_n = 1;
	#5 duty = 11'h7FF; //maximum duty value
end

//testing max duty cycle
repeat(5)
	repeat(2047) @(posedge clk);
	
@(negedge clk) rst_n = 0;
@(negedge clk) begin
	rst_n = 1;
	#5 duty = 11'h4F9; //set duty cycle to middle of the range
end

//testing mid duty cycle
repeat(5)
	repeat(2047) @(posedge clk);

$stop();
end


always
	#5 clk <= ~clk;


endmodule

