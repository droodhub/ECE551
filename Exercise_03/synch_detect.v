module synch_detect(asynch_sig_in, clk, fall_edge);

input asynch_sig_in;
input clk;
output fall_edge;
wire ffOutput1;
wire ffOutput2;
wire ffOutput3;


//double-flop the signal to synchronize it to our clock domain + ensure metastability
dff dff1(.D(asynch_sig_in), .clk(clk), .Q(ffOutput1));
dff dff2(.D(ffOutput1), .clk(clk), .Q(ffOutput2));
//put synchronized signal into flip flop
dff dff3(.D(ffOutput2), .clk(clk), .Q(ffOutput3));
//a falling edge occurs when ffOutput2 = 0 and ffOutput3 = 1

assign fall_edge = (!ffOutput2 && ffOutput3)?1'b1:1'b0;

endmodule
