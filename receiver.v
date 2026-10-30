module receiver(
    input clk,
    input rst,
    input rx,           // serial input from transmitter
    input rdy_clr,      // clears rdy after data has been read
    input clk_enb,      // baud-rate enable from baud rate generator
    output reg [7:0] data_out,
    output reg rdy
);

    parameter start_state    = 2'b00,
              data_out_state = 2'b01,
              stop_state     = 2'b10;

    reg [1:0] state;
    reg [3:0] sample;          // 0-15: 16x oversampling
    reg [2:0] index;           // 0-7: 8 data bits
    reg [7:0] temp_register;   // stores received serial data

    always @(posedge clk)
    begin
        if (rst)
        begin
            state <= start_state;
            sample <= 0;
            index <= 0;
            temp_register <= 0;
            data_out <= 0;
            rdy <= 0;
        end

        else
        begin
            // Clear ready flag when outside logic has read the data
            if (rdy_clr)
                rdy <= 0;

            // Receiver advances only on baud-rate enable
            if (clk_enb)
            begin
                case (state)

                    // Wait for the falling edge/start bit
                    start_state:
                    begin
                        if (rx == 0)
                            sample <= sample + 1'b1;

                        // One complete start-bit period has passed
                        if (sample == 15)
                        begin
                            state <= data_out_state;
                            sample <= 0;
                            index <= 0;
                            temp_register <= 0;
                        end
                    end

                    data_out_state:
                    begin
                        sample <= sample + 1'b1;

                        // Sample each data bit near the middle
                        // of its 16-sample bit period
                        if (sample == 4'h8)
                        begin
                            temp_register[index] <= rx;
                        end

                        // After the last data bit completes,
                        // move to the stop-bit state
                        if (index == 3'b111 && sample == 15)
                        begin
                            state <= stop_state;
                            sample <= 0;
                        end
                        else if (sample == 15)
                        begin
                            index <= index + 1'b1;
                            sample <= 0;
                        end
                    end

                    stop_state:
                    begin
                        sample <= sample + 1'b1;

                        // Wait for one complete stop-bit period
                        if (sample == 15)
                        begin
                            state <= start_state;
                            data_out <= temp_register;
                            rdy <= 1'b1;
                            sample <= 0;
                        end
                    end

                    default:
                    begin
                        state <= start_state;
                        sample <= 0;
                        index <= 0;
                    end

                endcase
            end
        end
    end

endmodule
