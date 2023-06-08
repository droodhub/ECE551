module ring_osc(input en, output out);

logic node1, node2;

nand #5 (node1, en, out);
not #5 (node2, node1);
not #5 (out, node2);


endmodule
