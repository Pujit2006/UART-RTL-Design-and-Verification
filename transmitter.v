module transmitter(
    input clk,
    input wr_enb,       // tells transmitter that new data is available
    input enb,          // baud-rate tick from baud rate generator
    input rst,
    input [7:0] data_in,
    output reg tx,
    output busy
);

    parameter idle_state  = 2'b00,
              start_state = 2'b01,
              data_state  = 2'b10,
              stop_state  = 2'b11;

    reg [7:0] data;      // internal register storing data to be transmitted
    reg [2:0] index;     // selects data bit 0 to 7
    reg [1:0] state;     // current FSM state

    always @(posedge clk)
    begin
        if (rst)
        begin
            state <= idle_state;
            tx <= 1'b1;
            data <= 8'b0;
            index <= 3'b0;
        end

        else
        begin
            case (state)

                idle_state:
                begin
                    tx <= 1'b1;     // UART remains HIGH when idle, transmission happens when start bit goes from high to low

                    if (wr_enb)
                    begin
                        // Data is loaded, but transmission has not started yet.
                        data <= data_in;
                        index <= 3'b0;
                        state <= start_state;
                    end
                    else
                        state <= idle_state;
                end

                start_state:
                begin
                    // Wait for baud-rate tick before actually starting transmission.
                    if (enb)
                    begin
                        tx <= 1'b0;          // 1 -> 0 indicates start bit
                        state <= data_state;
                    end
                    else
                        state <= start_state;
                end

                data_state:
                begin
                    // Each enb pulse transmits one data bit.
                    if (enb)
                    begin
                        tx <= data[index];

                        if (index == 3'b111)
                            state <= stop_state;
                        else
                            index <= index + 1'b1;
                    end
                    else
                        state <= data_state;
                end

                stop_state:
                begin
                    if (enb)
                    begin
                        tx <= 1'b1;           // stop bit
                        state <= idle_state;
                    end
                    else
                        state <= stop_state;
                end

                default:
                begin
                    tx <= 1'b1;
                    state <= idle_state;
                end

            endcase
        end
    end

    assign busy = (state != idle_state);

endmodule