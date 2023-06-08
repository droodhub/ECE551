module saturate_tb();

reg [15:0] unsigned_err, signed_err;
reg [9:0] signed_D_diff, unsigned_err_sat, signed_err_sat;
reg [6:0] signed_D_diff_sat;

saturate iDUT(.unsigned_err(unsigned_err), .signed_err(signed_err), .signed_D_diff(signed_D_diff), 
		.unsigned_err_sat(unsigned_err_sat), .signed_err_sat(signed_err_sat), .signed_D_diff_sat(signed_D_diff_sat));


always begin
	unsigned_err=0;
	signed_D_diff=0;
	signed_err=0;
	#10
	if(signed_D_diff_sat > 0 || signed_err_sat > 0 || unsigned_err_sat > 0) begin
		$display("ERROR: one of the saturation values was > 0 when all inputs were 0");
		$stop();
	end
	
	unsigned_err = 16'hF000; //should fully saturate the output
	#10
	if(unsigned_err_sat !== 10'h3FF) begin
		$display("ERROR: unsigned_err_sat was not fully saturated");
		$stop();
	end
	
	unsigned_err = 16'h00D8; //output should be identical
	#10
	if(unsigned_err_sat !== 10'h0D8) begin
		$display("ERROR: unsigned_err_sat has a different value than its input");
		$stop();
	end
	
	unsigned_err = 16'h0400; //testing "edge" bits
	#10
	if(unsigned_err_sat !== 10'h3FF) begin
		$display("ERROR: unsigned_err_sat was not fully saturated when bit 10 was high");
		$stop();
	end
	
	unsigned_err = 16'h030A; //testing "edge" bits
	#10
	if(unsigned_err_sat !== 10'h30A) begin
		$display("ERROR: unsigned_err_sat was incorrect for input 030A");
		$stop();
	end
	
	signed_err = 16'h0400; //testing positive saturation
	#10
	if(signed_err_sat !== 10'h1FF) begin
		$display("ERROR: signed_err_sat was not fully saturated for positive input h0400");
		$stop();
	end
	
	signed_err = 16'hA750; //testing negative saturation
	#10
	if(signed_err_sat !== 10'h200) begin
		$display("ERROR: signed_err_sat was not fully saturated for negative input hA750");
		$stop();
	end
	
	signed_err = 16'h01AB; //testing normal input
	#10
	if(signed_err_sat !== 10'h01AB) begin
		$display("ERROR: signed_err_sat was not the same as its input for 01AB");
		$stop();
	end
	
	signed_err = 16'hFF81; //testing normal input
	#10
	if(signed_err_sat !== 10'h381) begin
		$display("ERROR: signed_err_sat was not the same as its input for FF81");
		$stop();
	end
	
	signed_D_diff = 10'h100; //should saturate 
	#10
	if(signed_D_diff_sat !== 7'h3F) begin
		$display("ERROR: signed_D_diff_sat was not fully saturated for positive input h100");
		$stop();
	end
	
	signed_D_diff = 10'h30A; //should saturate negatively
	#10
	if(signed_D_diff_sat !== 7'h40) begin
		$display("ERROR: signed_D_diff_sat was not fully saturated for negative input");
		$stop();
	end
	
	signed_D_diff = 10'h01D; //normal input
	#10
	if(signed_D_diff_sat !== 7'h1D) begin
		$display("ERROR: signed_D_diff_sat was not equal to 1D");
		$stop();
	end
	
	$display("YAHOO! All tests passed");
	$stop();
end
endmodule
