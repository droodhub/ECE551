module steer_en_SM_tb();

  ////////////////////////////////////////////////
  // Declare any registers needed for stimulus //
  //////////////////////////////////////////////
  
  reg clk,rst_n;
  reg tmr_full;				// 1.3sec expired
  logic[11:0] lft_ld, rght_ld;
  
  ////////////////////////////////////////////
  // declare wires to hook SM output up to //
  //////////////////////////////////////////
  wire en_steer, rider_off;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  steer_en iDUT(.clk(clk),.rst_n(rst_n),.lft_ld(lft_ld), .rght_ld(rght_ld), .en_steer(en_steer),
				   .rider_off(rider_off));
  
  initial begin
    clk=0;
	rst_n = 0;
	lft_ld = 12'h10;
	rght_ld = 12'h10;
	@(posedge clk);
	@(negedge clk);
	rst_n = 1;
	
	/////////////////////////////////////////////////////////////
	// First check no outputs occur when both differences are //
	// less than, but sum_gt_min has not yet occurred.       //
	//////////////////////////////////////////////////////////
	repeat (2) begin
	  if (en_steer) begin
	    $display("ERROR: no en_steer should not be asserted yet\n");
		$stop();
	  end	  
	  @(negedge clk);
	  if (!rider_off) begin
	    $display("ERROR: rider_off should be asserted\n");
		$stop();
	  end
	end
	repeat(100) @(posedge clk); //larger portion of debugging waveform
	
	lft_ld = 12'h240;
	rght_ld = 12'hC0;
	@(negedge clk);
	if (!(iDUT.clr)) begin
	  $display("ERROR: clr_tmr should be asserted after sum_gt_min becomes true\n");
	  $stop();
	end
	///////////////////////////////
	// rider_off shoud deassert //
	/////////////////////////////
	if (rider_off) begin
	  $display("ERROR: rider_off should be deasserted now that sum > MIN\n");
	  $stop();
	end	
	@(posedge iDUT.full); //let the clock run to completion and verify it will clear and not assert anything
	@(posedge clk);
	if (en_steer | rider_off) begin
	    $display("ERROR: no outputs be asserted.  Need left/right balance\n");
		$stop();
	  end
	  if (!(iDUT.clr)) begin
	    $display("ERROR: clr_tmr should be asserted this time\n");
	    $stop();
	  end
	
	
	rght_ld = 12'h240; //deassert diff_gt_1_4
	repeat (2) begin
	  if (en_steer | rider_off) begin
	    $display("ERROR: no outputs should occur until timer expires\n");
		$stop();
	  end
	  @(negedge clk);
	end	
	
	@(posedge iDUT.full);
	@(posedge clk);
	if (!en_steer) begin
	  $display("ERROR: en_steer should be set now\n");
	  $stop();
	end	
	
	
	rght_ld = 12'hC0; //re-assert diff_gt_1_4
	@(negedge clk);
	repeat (2) begin //no transition should happen
	  if (!en_steer | rider_off) begin
	    $display("ERROR: no outputs should change until diff_gt_15_16\n");
		$stop();
	  end
	  @(negedge clk);
	end	
	repeat(1000) @(posedge clk);
	
	lft_ld = 12'h2EE; //should assert diff_gt_15_16
	rght_ld = 12'h12;
	@(negedge clk) //dont need to wait for tmr full signal, should be an instant transition
	if (en_steer) begin
	  $display("ERROR: clr_en_steer should be set now, should be in wait for balance state\n");
	  $stop();
	end	
	repeat(1000) @(posedge clk);





	lft_ld = 12'h10;
	rght_ld = 12'h10;
	@(negedge clk);
	if (iDUT.SM.state==2'b00) begin
	  $display("Yahoo! test passed!\n");
	  $stop();
	end	else begin
	  $display("ERROR: You should be back to reset state\n");
	  $stop();
	end
  end
  
  always
    #10 clk = ~clk;
	
endmodule