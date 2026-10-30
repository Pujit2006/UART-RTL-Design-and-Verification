module uart_top(
    input rst,
    input [7:0] data_in, // given by testbench/user
    input wr_enb,       // tells transmitter to transmit data_in
    input clk,          // reference clock
    input rdy_clr,      // clears rdy
    output tx,
    output [7:0] data_out,
    output busy,        // high when transmitter is busy
    output rdy          // high when receiver has received a byte
);

    wire rx_clk_en;      // RX baud-rate enable
    wire tx_clk_en;      // TX baud-rate enable
    wire tx_temp;        // TX output connected to RX input

    baud_rate_generator br(.clk(clk), .rst(rst), .tx_enable(tx_clk_en), .rx_enable(rx_clk_en));

    transmitter us(.clk(clk), .wr_enb(wr_enb), .enb(tx_clk_en), .rst(rst), .data_in(data_in), .tx(tx_temp), .busy(busy));

    receiver ur(.clk(clk), .rst(rst), .rx(tx_temp), .rdy_clr(rdy_clr), .clk_enb(rx_clk_en), .data_out(data_out), .rdy(rdy));

    assign tx = tx_temp;

endmodule
