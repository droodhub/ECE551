module circuit_tb();
reg d;
reg clk;

circuit testCircuit(.d(d), .clk(clk), .q());

always begin
//test changes in the value of d 
//should show a mirror change in q at the positive clock edge
 clk = 0;
 d = 0;
 #15;
 d = 1; 
 #20;
 d=0;
 #20
 d=1;
 #20 
 d=0;
 #5
 d=1;
 #10;


end

always
	#10 clk <= ~clk;

endmodule
