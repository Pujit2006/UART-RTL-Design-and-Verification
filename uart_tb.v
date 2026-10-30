module uart_tb;

    reg clk, rst;
    reg [7:0] data_in;
    reg wr_enb, rdy_clr;

    wire rdy, busy, tx;
    wire [7:0] data_out;

    integer pass_count, fail_count;
    integer i;
    reg [7:0] random_data;

    // DUT
    uart_top dut(.rst(rst), .data_in(data_in), .wr_enb(wr_enb),.clk(clk), .rdy_clr(rdy_clr), .tx(tx),.rdy(rdy), .busy(busy), .data_out(data_out));
                 
    // 50 MHz clock
    always #10 clk = ~clk;

    // Send one byte
    task send_byte(input [7:0] din);
    begin
        @(negedge clk);
        data_in = din;
        wr_enb = 1'b1;
        @(negedge clk);
        wr_enb = 1'b0;
    end
    endtask

    // Clear ready flag
    task clear_ready;
    begin
        @(negedge clk);
        rdy_clr = 1'b1;
        @(negedge clk);
        rdy_clr = 1'b0;
    end
    endtask

    // Check received data with timeout
    task check_byte(input [7:0] expected);
        integer timeout_count;
    begin
        timeout_count = 0;

        while ((rdy !== 1'b1) && (timeout_count < 120000))
        begin
            @(posedge clk);
            timeout_count = timeout_count + 1;
        end

        #1;

        if (rdy !== 1'b1)
        begin
            $display("FAIL: Timeout waiting for %h", expected);
            fail_count = fail_count + 1;
        end
        else if (data_out === expected)
        begin
            $display("PASS: Expected = %h, Received = %h", expected, data_out);
            pass_count = pass_count + 1;
        end
        else
        begin
            $display("FAIL: Expected = %h, Received = %h", expected, data_out);
            fail_count = fail_count + 1;
        end
    end
    endtask

    // Send and verify a byte
    task send_and_check(input [7:0] din);
    begin
        send_byte(din);
        check_byte(din);
        clear_ready;
    end
    endtask

    initial
    begin
        clk = 0;
        rst = 1;
        data_in = 0;
        wr_enb = 0;
        rdy_clr = 0;
        pass_count = 0;
        fail_count = 0;
        i = 0;
        random_data = 0;

        $display("UART VERIFICATION STARTED");

        // Initial reset
        repeat(3) @(negedge clk);
        rst = 0;

        // Basic functional tests
        $display("\nBasic functional tests");

        send_and_check(8'h41);
        send_and_check(8'h55);
        send_and_check(8'hAA);
        send_and_check(8'h00);
        send_and_check(8'hFF);
        send_and_check(8'h80);
        send_and_check(8'h01);
        send_and_check(8'hA5);

        // Ready flag test
        $display("\nReady flag test");

        send_byte(8'hC3);
        check_byte(8'hC3);

        repeat(100) @(posedge clk);

        if (rdy === 1'b1 && data_out === 8'hC3)
        begin
            $display("PASS: rdy remains HIGH until cleared");
            pass_count = pass_count + 1;
        end
        else
        begin
            $display("FAIL: Ready flag did not remain HIGH");
            fail_count = fail_count + 1;
        end

        clear_ready;
        @(posedge clk);
        #1;

        if (rdy === 1'b0)
        begin
            $display("PASS: Ready flag cleared successfully");
            pass_count = pass_count + 1;
        end
        else
        begin
            $display("FAIL: Ready flag was not cleared");
            fail_count = fail_count + 1;
        end

        // Write request while transmitter is busy
        $display("\nBusy condition test");

        send_byte(8'h96);
        wait(busy === 1'b1);

        @(negedge clk);
        data_in = 8'hDE;
        wr_enb = 1'b1;
        @(negedge clk);
        wr_enb = 1'b0;

        check_byte(8'h96);
        clear_ready;

        repeat(55000) @(posedge clk);
        #1;

        if (rdy === 1'b0)
        begin
            $display("PASS: Write request while busy was ignored");
            pass_count = pass_count + 1;
        end
        else
        begin
            $display("FAIL: Unexpected additional reception");
            fail_count = fail_count + 1;
        end

        // Reset during transmission
        $display("\nReset during transmission");

        send_byte(8'hB6);
        wait(busy === 1'b1);

        repeat(6000) @(posedge clk);

        @(negedge clk);
        rst = 1'b1;
        repeat(3) @(negedge clk);
        rst = 1'b0;

        @(posedge clk);
        #1;

        if (busy === 1'b0 && tx === 1'b1 && rdy === 1'b0)
        begin
            $display("PASS: UART recovered after reset");
            pass_count = pass_count + 1;
        end
        else
        begin
            $display("FAIL: Incorrect state after reset");
            fail_count = fail_count + 1;
        end

        send_and_check(8'h3C);

        // Random data tests
        $display("\nRandom data tests");

        for (i = 0; i < 10; i = i + 1)
        begin
            random_data = $random;
            send_and_check(random_data);
        end

        // Test summary
        $display("\nUART TEST SUMMARY");
        $display("Total tests : %0d", pass_count + fail_count);
        $display("Passed      : %0d", pass_count);
        $display("Failed      : %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");

        #100;
        $finish;
    end

endmodule


