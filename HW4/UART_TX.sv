module UART_tx(input clk, input rst_n, output reg TX, input trmt, input [7:0]tx_data, output reg tx_done);

reg [8:0] tx_shft_reg;
reg [11:0] baud_cnt;
reg [3:0] bit_cnt;
logic shift, set_done, load, transmitting;

typedef enum reg[1:0] {IDLE, TRANSMIT} state_t;
state_t state, nxt_state;

assign shift = (baud_cnt == 12'hA2C) ? 1 : 0;
assign TX = tx_shft_reg[0];

always_ff begin @(posedge clk, negedge rst_n) //shift register block

if(!rst_n)
	tx_shft_reg <= 9'h1FF;
else if(load) //load in the new data
	tx_shft_reg <= {tx_data, 1'b0};
else if(shift) //shift data out for transmission
	tx_shft_reg <= {1'b1, tx_shft_reg[8:1]};
	
end

always_ff @(posedge clk) begin //baud counter block

if(load || shift) //reset baud counter for the start of transmission and each bit
	baud_cnt <= 12'h000;
else
	baud_cnt <= baud_cnt + 1;

end
always_ff @(posedge clk) begin //bit counter block

if(load) //reset bit_cnt at the start of a new transmission
	bit_cnt = 4'h0;
else if(shift) //only increment on shift signal
	bit_cnt = bit_cnt + 1;

end
always_ff @(posedge clk, negedge rst_n) begin //state flop block

if(!rst_n)
	state <= IDLE;
else
	state <= nxt_state;

end
always_ff @(posedge clk, negedge rst_n) begin //tx_done output block

if(!rst_n)
	tx_done <= 1'b0;
else if(load) //if loading, not done(actually just started)
	tx_done <= 1'b0;
else if(set_done) //set_done high means we are done
	tx_done <= 1'b1;

end
always_comb begin //state transition block
//preset outputs
nxt_state = state;
load = 1'b0;
set_done = 1'b0;
transmitting = 1'b0;

case(state)
	IDLE: begin 
			if(trmt) begin //start transmission
				nxt_state = TRANSMIT;
				load = 1'b1;
				set_done = 1'b0;
				transmitting = 1'b1;
				end
		  end	
	TRANSMIT: begin 
				if(bit_cnt == 10) begin //we have transmitted 
				//the full register, end transmission
					nxt_state = IDLE;
					set_done = 1'b1;
					load = 1'b0;
					transmitting = 1'b0;
					end
			  end	
	endcase
end

endmodule
