module auth_blk(input clk, input rider_off, input rst_n, input RX, output reg pwr_up);

logic clr_rx_rdy, rx_rdy;
logic[7:0] rx_data;

UART_rx receiver(.clk(clk), .rst_n(rst_n), .RX(RX), .clr_rdy(clr_rx_rdy), .rx_data(rx_data), .rdy(rx_rdy));

typedef enum reg[1:0] {OFF, PWR1, PWR2} state_nm;
state_nm state, nxt_state;

//state machine flops to hold current state
always_ff@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		state <= OFF;
	else
		state <= nxt_state;
end

//combinational logic for sm
always_comb begin
	//defaulting outputs
	clr_rx_rdy = 1'b0;
	pwr_up = 1'b0;
	nxt_state = state;
	
	case(state)
		PWR1: if(rx_data == 8'h73 && rx_rdy) begin
				nxt_state = rider_off ? OFF : PWR2; //if rider_off, we go to off, otherwise go to alt power state
				clr_rx_rdy = 1'b1; //clear ready signal every time it is asserted
				pwr_up = ~rider_off; //if rider is on, we need to keep power up
			end else	
				pwr_up = 1'b1;
		PWR2: if(rider_off)
				nxt_state = OFF;
			else if(rx_data == 8'h67 && rx_rdy) begin //signal to give power is sent again
				nxt_state = PWR1;
				pwr_up = 1'b1;
				clr_rx_rdy = 1'b1;
			end else	
				pwr_up = 1'b1;
		default: if(rx_data == 8'h67 && rx_rdy) begin
					nxt_state = PWR1;
					pwr_up = 1'b1;
					clr_rx_rdy = 1'b1;
				end
	endcase
end

endmodule
