module circuit(input d, input clk, output q);

wire md, mq, sd;

notif1 #1 triOne(md, d, !clk); //a tristate combined with reciprocating inverters represents a latch
//when active the latch is "transparent"
not (mq, md); //these two reciprocating inverters are a form of memory -- md remains constant until
//a new signal is input
not(weak0, weak1) (md, mq);
 
notif1 #1 triTwo(sd, mq, clk);

not(q, mq);
not(weak0, weak1) (sd, q);





endmodule
