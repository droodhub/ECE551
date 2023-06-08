module steer_en_SM(clk,rst_n,tmr_full,sum_gt_min,sum_lt_min,diff_gt_1_4,
                   diff_gt_15_16,clr_tmr,en_steer,rider_off);

 input clk;				// 50MHz clock
  input rst_n;				// Active low asynch reset
  input tmr_full;			// asserted when timer reaches 1.3 sec
  input sum_gt_min;			// asserted when left and right load cells together exceed min rider weight
  input sum_lt_min;			// asserted when left_and right load cells are less than min_rider_weight

  /////////////////////////////////////////////////////////////////////////////
  // HEY HOFFMAN...you are a moron.  sum_gt_min would simply be ~sum_lt_min. 
  // Why have both signals coming to this unit??  ANSWER: What if we had a rider
  // (a child) who's weigth was right at the threshold of MIN_RIDER_WEIGHT?
  // We would enable steering and then disable steering then enable it again,
  // ...  We would make that child crash(children are light and flexible and 
  // resilient so we don't care about them, but it might damage our Segway).
  // We can solve this issue by adding hysteresis.  So sum_gt_min is asserted
  // when the sum of the load cells exceeds MIN_RIDER_WEIGHT + HYSTERESIS and
  // sum_lt_min is asserted when the sum of the load cells is less than
  // MIN_RIDER_WEIGHT - HYSTERESIS.  Now we have noise rejection for a rider
  // who's weight is right at the threshold.  This hysteresis trick is as old
  // as the hills, but very handy...remember it.
  //////////////////////////////////////////////////////////////////////////// 

  input diff_gt_1_4;		// asserted if load cell difference exceeds 1/4 sum (rider not situated)
  input diff_gt_15_16;		// asserted if load cell difference is great (rider stepping off)
  output logic clr_tmr;		// clears the 1.3sec timer
  output logic en_steer;	// enables steering (goes to balance_cntrl)
  output logic rider_off;	// held high in intitial state when waiting for sum_gt_min
  
  // You fill out the rest...use good SM coding practices ///
  typedef enum reg[1:0] {IDLE, RIDER_ON, STEER_ENABLED} state_t;
	state_t state, nxt_state;

  always_ff @(posedge clk, negedge rst_n) begin //state flop block

		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;

	end
	
  always_comb begin //state transition block
	//preset output values
	nxt_state = state;
	clr_tmr = 1'b0;
	en_steer = 1'b0;
	rider_off = 1'b1;

	case(state)
		IDLE: begin 
				if(sum_gt_min) begin //rider is now on
					rider_off = 1'b0;
					nxt_state = RIDER_ON;
					clr_tmr = 1'b1;
				end
			end	
		RIDER_ON: begin 
					if(sum_lt_min) begin //rider off
						nxt_state = IDLE;
					end
					else if(~diff_gt_1_4 && tmr_full) begin 
						//rider is on and balanced for a full timer
						//ready to enable steering
						nxt_state = STEER_ENABLED;
						rider_off = 1'b0;
						en_steer = 1'b1;
						clr_tmr = 1'b1;
					end
					else if(~diff_gt_1_4) begin
						//rider is balanced, but not for a full timer
						//make sure to not reset the timer for this state
						rider_off = 1'b0;
					end
					else if(tmr_full) begin
						rider_off = 1'b0;
						clr_tmr = 1'b1;
					end
					else begin //rider is still not balanced
						clr_tmr = 1'b0;
						rider_off = 1'b0;
					end
				end	
		STEER_ENABLED: begin
				if(sum_lt_min) begin //rider off
					nxt_state = IDLE;
				end
				else if(diff_gt_15_16) begin
					//rider is unbalanced
					nxt_state = RIDER_ON;
					clr_tmr = 1'b1;
					rider_off = 1'b0;
				end
				else begin //default state
					en_steer = 1'b1;
					rider_off = 1'b0;
				end
			end
		endcase
	end
		
endmodule