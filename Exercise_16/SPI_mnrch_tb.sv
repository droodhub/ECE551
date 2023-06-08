module SPI_mnrch_tb();

logic SS_n, SCLK, MISO, MOSI, INT, clk, rst_n, wrt, done;
logic [15:0] wrt_data;
wire [15:0] rd_data;

SPI_iNEMO1 iNEMO(.SS_n(SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI), .INT(INT));
SPI_mnrch iDUT(.SS_n(SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI), .clk(clk), .rst_n(rst_n), .wrt(wrt), 
					.wrt_data(wrt_data), .done(done), .rd_data(rd_data));

initial begin
clk = 1'b0;
wrt_data = 16'h8Fxx;
wrt = 1'b0;
rst_n = 1'b0;
repeat(2) @(posedge clk);
@(negedge clk) rst_n = 1'b1;

@(negedge clk) wrt = 1'b1;
@(negedge clk) wrt = 1'b0;
@(posedge done) #100;
if(rd_data !== 16'h006A) begin //should be the value of the WHOAMI register
	$display("rd_data was not xx6A after writing 8F to it");
	$stop();
end

//test to make sure INT will go high when written to
wrt_data = 16'h0D02;
@(negedge clk) wrt = 1'b1;
@(negedge clk) wrt = 1'b0;

fork
	begin : timeout
		repeat(70000)@(posedge clk); //INT needs a long time to go high
		if(!INT)  begin
			$display("INT is not high after writing 0D02");
			$stop();
		end
	end : timeout
	begin
		@(posedge INT) 
		disable timeout;
	end
join 

wrt_data = 16'hA2xx; //reading pitch low
@(negedge clk) wrt = 1'b1;
@(negedge clk) wrt = 1'b0;
@(posedge done) #100;

if(rd_data !== 16'h0063) begin
	$display("rd_data was not xx6A after writing A2 to it");
	$stop();
end

@(posedge INT); //wait for INT to say it is ready again

wrt_data = 16'hA3xx; //reading pitch high
@(negedge clk) wrt = 1'b1;
@(negedge clk) wrt = 1'b0;
@(posedge done) #100;

if(rd_data !== 16'h00CD) begin
	$display("rd_data was not xxCD after writing A3 to it");
	$stop();
end


wrt_data = 16'hA2xx; //reading pitch low
@(negedge clk) wrt = 1'b1;
@(negedge clk) wrt = 1'b0;
@(posedge done) #100;

if(rd_data !== 16'h000D) begin
	$display("rd_data was not xx0D after writing A2 to it");
	$stop();
end

@(posedge INT); //wait for INT to say it is ready again

wrt_data = 16'hA3xx; //reading pitch high
@(negedge clk) wrt = 1'b1;
@(negedge clk) wrt = 1'b0;
@(posedge done) #100;

if(rd_data !== 16'h0024) begin
	$display("rd_data was not xx24 after writing A3 to it");
	$stop();
end

#1000; //give a time delay for waveform debugging
$display("YAHOO! All tests passed");
$stop();

end

always
	#5 clk <= ~clk;

endmodule