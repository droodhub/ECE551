module UART_rx(input clk, input rst_n, input RX, input clr_rdy, output reg [7:0] rx_data, output reg rdy);

reg [8:0] rx_shft_reg;
reg [11:0] baud_cnt;
reg [3:0] bit_cnt;
logic shift, set_rdy, start, receiving, rx_intermediate_1, rx_intermediate_2;

typedef enum reg[1:0] {IDLE, RECEIVE} state_t;
state_t state, nxt_state;

assign shift = (baud_cnt == 0) ? 1 : 0; //shift if all zeros

assign rx_data = rx_shft_reg[7:0];

initial 
	rx_shft_reg = 9'h1FF; //preset shift register

always_ff @(posedge clk) begin //double flop the input for meta stability
	rx_intermediate_1 <= RX;
	rx_intermediate_2 <= rx_intermediate_1;
end

always_ff @(posedge clk) begin //baud counter block

if(start || shift) //maybe inefficient structure here
	//set baud_cnt to half of max val for first sample
	baud_cnt <= start ? 12'h516 : 12'hA2C;
else if(receiving)
	baud_cnt <= baud_cnt - 1;

end

always_ff @(posedge clk) begin //bit counter block

if(start)
	bit_cnt <= 3'h0;
else if(shift)
	bit_cnt <= bit_cnt + 1;

end

always_ff begin @(posedge clk) //shift register block
if(shift) //shift when told to, otherwise value remains the same
	rx_shft_reg <= {rx_intermediate_2, rx_shft_reg[8:1]};

end

always_ff @(posedge clk, negedge rst_n) begin //state flop block

if(!rst_n)
	state <= IDLE;
else
	state <= nxt_state;

end

always_ff @(posedge clk, negedge rst_n) begin //rdy output block

if(!rst_n)
	rdy <= 1'b0;
else if(start)
	rdy <= 1'b0;
else if(set_rdy)
	rdy <= 1'b1;

end

always_comb begin
//preset outputs
nxt_state = state;
receiving = 0;
set_rdy = 0; 
start = 0;

case(state) 
	IDLE: begin
		if(!rx_intermediate_2) begin 
			//when meta-stable RX goes low, we have received the start bit
			set_rdy = 0; 
			nxt_state = RECEIVE;
			start = 1;
		end
	end
	RECEIVE: begin
		if(bit_cnt == 10) begin
		//10 bits received = entire byte + start/end bits
		//end receiving
			nxt_state = IDLE;
			set_rdy = 1;
		end
		else receiving = 1;
	end
endcase
end
endmodule