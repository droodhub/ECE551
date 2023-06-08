module adder_tb();

//DUT inputs
//one bit longer than necessary for the loop parameters
reg[4:0] A, B; 
reg[1:0] cin;
//DUT outputs
wire [3:0] sum;
wire co;
//model we will compare the DUT against
reg [4:0] goldStandard; 

adder iDUT(.A(A[3:0]), .B(B[3:0]), .cin(cin[0]), .sum(sum), .co(co));

initial begin
//nested for loops will allow us to iterate through every possible input to the DUT
//loop through A, B, and cin, and verify corectness
	for (A = 0; A < 16; A = A+1) begin
		for(B = 0; B < 16; B = B+1)begin
			for(cin = 0; cin < 2; cin = cin+1) begin 
				#5; //delay for waveform debugging
				goldStandard = A[3:0] + B[3:0] + cin;
				if(sum != goldStandard[3:0]) begin
					$display("ERROR: Sum returned was %d for %d + %d + %d, with carryout %d.", sum, A, B, cin, co);
					$stop();
				end
				if(co != goldStandard[4]) begin
					$display("ERROR: co returned was %d for %d + %d + %d, with sum %d.", co, A, B, cin, sum);
					$stop();
				end
			end
		end
	end
	$display("YAHOO! All tests passed.");
	$stop();
end

endmodule
