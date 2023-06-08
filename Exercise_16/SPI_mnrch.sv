module SPI_mnrch(input clk, input rst_n, output reg SS_n, output SCLK, output MOSI, input MISO, input wrt,
					input [15:0] wrt_data, output reg done, output[15:0] rd_data);

logic [3:0] SCLK_cnt, bit_cnt;
logic [15:0] shft_reg;
logic MISO_smpl, smpl, shft, init, set_done, ld_SCLK, done15, shft_em;
typedef enum reg[1:0] {IDLE, FRONT_PORCH, TRANSFER, BACK_PORCH} state_t ;
state_t state, nxt_state;

always_ff @(posedge clk) begin ///SCLK counter & decode block
	SCLK_cnt <= (ld_SCLK) ? 4'b1011 : SCLK_cnt + 1;
end
assign rd_data = shft_reg;
assign SCLK = SCLK_cnt[3];
assign smpl = (SCLK_cnt == 4'b0111); //if rising edge, sample
assign shft_em = (SCLK_cnt == 4'b1111); //falling edge is about to happen when SCLK_cnt rolls over

always_ff @(posedge clk) begin //bit counter block
	if(init) //reset bit_cnt at the start of a new transmission
		bit_cnt <= 4'h0;
	else if(shft) //only increment on shift signal
		bit_cnt <= bit_cnt + 1;
end
assign done15 = &bit_cnt;


always_ff @(posedge clk) begin //MISO block
	if(smpl) //only shifting in when we are told to sample
		MISO_smpl <= MISO;
end
always_ff @(posedge clk) begin //shift register block
	if(init && SCLK) //starting off a new shift
		shft_reg <= wrt_data;
	else if(shft && SCLK) //shifting is continuing, shift in new data
		shft_reg <= {shft_reg[14:0], MISO_smpl};
end
assign MOSI = shft_reg[15];


always_ff @(posedge clk, negedge rst_n) begin //state machine next state logic
	if(!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end

always_ff @(posedge clk, negedge rst_n) begin //SS_n and done logic
	//SS_n and done are identical aside from the reset value
	if(!rst_n) begin
		SS_n <= 1'b1;
		done <= 1'b0;
	end else if(init) begin
		SS_n <= 1'b0;
		done <= 1'b0;
	end else if(set_done) begin
		SS_n <= 1'b1;
		done <= 1'b1;
	end

end

always_comb begin //SM state transition + output logic
	//preset outputs
    nxt_state = state;
	shft = 1'b0;
	ld_SCLK = 1'b0;
	set_done = 1'b0;
	init = 1'b0; //SS_n is preset
	
case(state)
	FRONT_PORCH : begin 
		if(shft_em) 
			nxt_state = TRANSFER;
	end
	BACK_PORCH : begin
		if(shft_em) begin 
			ld_SCLK = 1'b1;
			shft = 1'b1; //finish final shift, then have SS_n go high
			set_done = 1'b1;
			nxt_state = IDLE;
		end
	end
	TRANSFER : begin
		shft = shft_em; //in the workhorse state, these 2 signals are equivalent
		if(done15) begin //finished transfer
			shft = 1'b1;
			nxt_state = BACK_PORCH;
		end
	end
	IDLE: begin
		if(wrt) begin //start transfer process
			ld_SCLK = 1'b1;
			nxt_state = FRONT_PORCH;
			init = 1'b1;
		end
		else
			ld_SCLK = 1'b1;
	end
endcase
end

endmodule
