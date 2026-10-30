module baud_rate_generator(
    input clk,
    input rst,
    output tx_enable,
    output rx_enable
);

    reg [12:0] tx_counter;   // 13 bits to accommodate 5207
    reg [9:0] rx_counter;    // 10 bits to accommodate 324

    always @(posedge clk)     // synchronous, rising-edge triggered
    begin
        if (rst)
        begin
            tx_counter <= 0;
            rx_counter <= 0;
        end

        else
        begin
            if (tx_counter == 5207)
                tx_counter <= 0;
            else
                tx_counter <= tx_counter + 1'b1;

            if (rx_counter == 324)
                rx_counter <= 0;
            else
                rx_counter <= rx_counter + 1'b1;
        end
    end

    // Enable pulse occurs once every 5208 clock cycles for TX
    // RX uses 16x oversampling: 5208 / 16 ? 325 clock cycles
    assign tx_enable = (tx_counter == 0) ? 1'b1 : 1'b0;
    assign rx_enable = (rx_counter == 0) ? 1'b1 : 1'b0;

endmodule
