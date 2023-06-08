module auth_blk_tb();

logic clk, rst_n, TX, tx_done, rider_off, pwr_up, trmt;
logic [7:0] tx_data;

auth_blk iDUT(.clk(clk), .rider_off(rider_off), .rst_n(rst_n), .RX(TX), .pwr_up(pwr_up));
UART_tx UART(.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done));

initial begin
clk = 1'b0;
trmt = 1'b0;
rst_n = 1'b0;
rider_off = 1'b0;
tx_data = 8'h67; //signal to switch to power1

@(negedge clk); //wait one clock cylce with rst_n low
@(negedge clk) rst_n = 1'b1;

@(negedge clk) trmt = 1'b1; //transition to PWR1
@(negedge clk) trmt = 1'b0;
@(posedge tx_done) #50;

tx_data = 8'h73;
rider_off = 1'b1; //transition to off state
@(negedge clk) trmt = 1'b1;
@(negedge clk) trmt = 1'b0;
@(posedge tx_done) #50;

tx_data = 8'h67;
rider_off = 1'b0; //transition back to PWR1
@(negedge clk) trmt = 1'b1;
@(negedge clk) trmt = 1'b0;
@(posedge tx_done) #50;

tx_data = 8'h73; //transition to PWR2
@(negedge clk) trmt = 1'b1;
@(negedge clk) trmt = 1'b0;
@(posedge tx_done) #50;

tx_data = 8'h67; //transition back to PWR1
@(negedge clk) trmt = 1'b1;
@(negedge clk) trmt = 1'b0;
@(posedge tx_done) #50;

tx_data = 8'h73; //transition to PWR2
@(negedge clk) trmt = 1'b1;
@(negedge clk) trmt = 1'b0;
@(posedge tx_done) #20000;

rider_off = 1'b1; //transition to OFF from PWR2
repeat(5)@(posedge clk); //let the clock run for this transition to show on waveforms
#20000;


$stop();
end

always
	#5 clk = ~clk;
	
endmodule
