module UART_tb();

logic clk, rst_n, trmt, clr_rdy;
wire TX, tx_done, rdy;
logic [7:0] tx_data, rx_data;

UART_tx iDUTTX(.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done));
UART_rx iDUTRX(.clk(clk), .rst_n(rst_n), .RX(TX), .clr_rdy(clr_rdy), .rx_data(rx_data), .rdy(rdy));

initial begin
clk = 0;
rst_n = 0;
trmt = 0;
clr_rdy = 0;
tx_data = 8'b00100111;

repeat(5) @(negedge clk);

rst_n = 1;

@(negedge clk) trmt = 1; //start transmitting data
@(negedge clk) trmt = 0; //trmt can only be asserted for 1 clock cycle

repeat(30000) @(posedge clk); //allow transmitter to run for a while to allow data transfer

if(tx_data !== rx_data) begin
	$display("tx_data and rx_data are not equivalent, tx_data: %b, rx_data: %b", tx_data, rx_data);
	$stop();
end

tx_data = 8'b10110001;

@(negedge clk) trmt = 1; //start transmitting data
@(negedge clk) trmt = 0; //trmt can only be asserted for 1 clock cycle

repeat(30000) @(posedge clk); //allow transmitter to run for a while to allow data transfer

if(tx_data !== rx_data) begin
	$display("tx_data and rx_data are not equivalent, tx_data: %b, rx_data: %b", tx_data, rx_data);
	$stop();
end

$display("YAHOO! All tests passed.");
$stop();

end

always
  #5 clk = ~clk;
  
endmodule

