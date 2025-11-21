module tb;
    reg         clk;
    reg         rst;
    reg         wen;
    reg         ren;
    reg  [7:0]  din;
    wire [7:0]  dout;
    wire        full;
    wire        empty;
	
    fifo DUT (clk, rst, wen, ren, din, dout, full, empty);
	
    reg [7:0] seq_val;
    integer   seq_idx;

    task initialize;
    begin
        clk = 1'b0;
        rst = 1'b1;
        wen = 1'b0;
        ren = 1'b0;
        din = 8'h00;

        #20;
        rst = 1'b0;
    end
    endtask

    task clock_gen;
    begin
        forever begin
            #5 clk = ~clk;    
        end
    end
    endtask
	
    task stop_sim;
    begin
        #600;
        $finish;
    end
    endtask

    task SIM;
    begin
        fork
            initialize;
            clock_gen;
            stop_sim;
        join
    end
    endtask

    initial begin
        SIM;
    end

    task write_data;
        input [7:0] data;
    begin
        @(posedge clk);
        wen = 1'b1;
        ren = 1'b0;
        din = data;

        @(posedge clk);
        wen = 1'b0;
    end
    endtask

    task read_data;
    begin
        @(posedge clk);
        ren = 1'b1;
        wen = 1'b0;

        @(posedge clk);
        ren = 1'b0;
    end
    endtask

    initial begin : STIMULUS
        @(negedge rst);
        @(posedge clk);

        write_data(8'h00);
        write_data(8'h55);

        read_data();

        write_data(8'hAA);
        write_data(8'hFF);

        read_data();
        read_data();

        seq_idx = 0;

        while (!full) begin
            case (seq_idx)
                0: seq_val = 8'h00;
                1: seq_val = 8'h55;
                2: seq_val = 8'hAA;
                3: seq_val = 8'hFF;
            endcase

            write_data(seq_val);

            seq_idx = seq_idx + 1;
            if (seq_idx == 4)
                seq_idx = 0;
        end
        read_data();

        #50;
    end
endmodule



/*module tb;

    reg         clk;
    reg         rst;
    reg         wen;
    reg         ren;
    reg  [7:0]  din;
    wire [7:0]  dout;
    wire        full;
    wire        empty;

    fifo DUT (clk, rst, wen, ren, din, dout, full, empty);

    // ================================
    // PRINT FIFO CONTENTS
    // ================================
    task print_fifo;
        integer idx;
    begin
        $display("--------------------------------------------------");
        $display("[%0t] FIFO STATE  (wptr=%0d, rptr=%0d, full=%b, empty=%b)", 
                  $time, DUT.wptr, DUT.rptr, DUT.full, DUT.empty);
        for (idx = 0; idx < 8; idx = idx + 1) begin
            $display(" mem[%0d] = %02h", idx, DUT.mem[idx]);
        end
        $display("--------------------------------------------------");
    end
    endtask

    // ================================
    // TASK 1: initialize
    // ================================
    task initialize;
    begin
        clk = 0; rst = 1; wen = 0; ren = 0; din = 0;
        #20 rst = 0;
        $display("[%0t] RESET released", $time);
        print_fifo();
    end
    endtask

    // ================================
    // TASK 2: clock gen
    // ================================
    task clock_gen;
    begin
        forever #5 clk = ~clk;
    end
    endtask

    // ================================
    // TASK 3: stop sim
    // ================================
    task stop_sim;
    begin
        #600;
        $display("[%0t] Ending simulation", $time);
        $finish;
    end
    endtask

    // ================================
    // TASK 4: SIM
    // ================================
    task SIM;
    begin
        fork
            initialize;
            clock_gen;
            stop_sim;
        join
    end
    endtask

    initial begin
        SIM;
    end

    // ================================
    // WRITE task with FIFO PRINT
    // ================================
    task write_data;
        input [7:0] data;
    begin
        @(posedge clk);
        wen = 1; ren = 0; din = data;

        @(posedge clk);
        wen = 0;

        $display("[%0t] WRITE: %02h", $time, data);
        print_fifo();
    end
    endtask

    // ================================
    // READ task with FIFO PRINT
    // ================================
    task read_data;
    begin
        @(posedge clk);
        ren = 1; wen = 0;

        @(posedge clk);
        ren = 0;

        $display("[%0t] READ:  %02h", $time, dout);
        print_fifo();
    end
    endtask

    // ================================
    // Pattern generator
    // ================================
    reg [7:0] pattern [0:3];
    integer p_idx;

    task write_next_pattern;
    begin
        write_data(pattern[p_idx]);
        p_idx = (p_idx + 1) % 4;
    end
    endtask

    // ================================
    // STIMULUS (Exactly from PDF)
    // ================================
    initial begin : STIMULUS
        pattern[0] = 8'h00;
        pattern[1] = 8'h55;
        pattern[2] = 8'hAA;
        pattern[3] = 8'hFF;
        p_idx = 0;

        @(negedge rst);
        @(posedge clk);

        // 2 writes
        write_next_pattern();
        write_next_pattern();

        // 1 read
        read_data();

        // 2 writes
        write_next_pattern();
        write_next_pattern();

        // 2 reads
        read_data();
        read_data();

        // Fill FIFO
        while (!full) begin
            write_next_pattern();
        end
        $display("[%0t] FIFO reached FULL", $time);
        print_fifo();

        // Final read
        read_data();

        #50;
    end

endmodule*/


/*module tb;

    // --------------------------------
    // DUT interface signals
    // --------------------------------
    reg         clk;
    reg         rst;
    reg         wen;
    reg         ren;
    reg  [7:0]  din;
    wire [7:0]  dout;
    wire        full;
    wire        empty;

    // Instantiate DUT
    fifo DUT (clk, rst, wen, ren, din, dout, full, empty);

    // Optional pointer access for debug
    // wire [2:0] wptr = DUT.wptr;
    // wire [2:0] rptr = DUT.rptr;

    // ======================================================
    // TASK 1: initialize the FIFO
    // ======================================================
    task initialize;
    begin
        clk = 0;
        rst = 1;
        wen = 0;
        ren = 0;
        din = 8'h00;

        #20;
        rst = 0;
        $display("[%0t] RESET released", $time);
    end
    endtask

    // ======================================================
    // TASK 2: create clock
    // ======================================================
    task clock_gen;
    begin
        forever begin
            #5 clk = ~clk;
        end
    end
    endtask

    // ======================================================
    // TASK 3: stop simulation
    // ======================================================
    task stop_sim;
    begin
        #500;
        $display("[%0t] Simulation auto-stopped", $time);
        $finish;
    end
    endtask

    // ======================================================
    // TASK 4: run all 3 tasks simultaneously
    // ======================================================
    task SIM;
    begin
        fork
            initialize;
            clock_gen;
            stop_sim;
        join
    end
    endtask

    initial begin
        SIM;
    end

    // ======================================================
    // Helper tasks
    // ======================================================

    task write_data;
        input [7:0] data;
    begin
        @(posedge clk);
        wen = 1;
        ren = 0;
        din = data;

        @(posedge clk);
        wen = 0;

        $display("[%0t] WRITE: %02h   full=%b empty=%b", 
                  $time, data, full, empty);
    end
    endtask

    task read_data;
    begin
        @(posedge clk);
        ren = 1;
        wen = 0;

        @(posedge clk);
        ren = 0;

        $display("[%0t] READ:  %02h   full=%b empty=%b",
                  $time, dout, full, empty);
    end
    endtask

    // ======================================================
    // Data pattern generator: 00, 55, AA, FF
    // ======================================================
    reg [7:0] pattern [0:3];
    integer p_idx;

    task write_next_pattern;
    begin
        write_data(pattern[p_idx]);
        p_idx = (p_idx + 1) % 4;
    end
    endtask

    // ======================================================
    // STIMULUS – EXACT PDF SEQUENCE
    // ======================================================
    initial begin : STIMULUS
        pattern[0] = 8'h00;
        pattern[1] = 8'h55;
        pattern[2] = 8'hAA;
        pattern[3] = 8'hFF;
        p_idx = 0;

        @(negedge rst);
        @(posedge clk);

        // ------------------------------------------
        // Step 2: two write operations
        // ------------------------------------------
        write_next_pattern();  
        write_next_pattern();  

        // ------------------------------------------
        // Step 3: one read operation
        // ------------------------------------------
        read_data();           

        // ------------------------------------------
        // Step 4: two write operations
        // ------------------------------------------
        write_next_pattern();  
        write_next_pattern();  

        // ------------------------------------------
        // Step 5: two read operations
        // ------------------------------------------
        read_data();           
        read_data();           

        // ------------------------------------------
        // Step 6: write until FIFO is FULL
        // ------------------------------------------
        while (!full) begin
            write_next_pattern();
        end
        $display("[%0t] FIFO became FULL", $time);

        // ------------------------------------------
        // Step 7: one read operation
        // ------------------------------------------
        read_data();
        $display("[%0t] COMPLETED FINAL READ", $time);

        #50;
    end

endmodule*/

/*module tb;
    reg         clk;
    reg         rst;
    reg         wen;
    reg         ren;
    reg  [7:0]  din;
    wire [7:0]  dout;
    wire        full;
    wire        empty;

    fifo DUT (clk, rst, wen, ren, din, dout, full, empty);

    task initialize;
    begin
        clk = 1'b0;
        rst = 1'b1;
        wen = 1'b0;
        ren = 1'b0;
        din = 8'h00;
        #20;
        rst = 1'b0;
    end
    endtask

    task clock_gen;
    begin
        forever begin
            #5 clk = ~clk;   // 10 ns period → 100 MHz
        end
    end
    endtask

    task stop_sim;
    begin
        #500;
        $display("Simulation finished at time %0t", $time);
        $finish;
    end
    endtask

    task SIM;
    begin
        fork
            initialize;
            clock_gen;
            stop_sim;
        join
    end
    endtask

    initial begin
        SIM;
    end

    task write_data;
        input [7:0] data;
    begin
        @(posedge clk);
        wen = 1'b1;
        ren = 1'b0;
        din = data;
        @(posedge clk);
        wen = 1'b0;
    end
    endtask

    task read_data;
    begin
        @(posedge clk);
        ren = 1'b1;
        wen = 1'b0;
        @(posedge clk);
        ren = 1'b0;
    end
    endtask

    reg [7:0] pattern [0:3];
    integer   p_idx;

    task write_next_pattern;
    begin
        write_data(pattern[p_idx]);
        p_idx = (p_idx + 1) % 4;   
    end
    endtask

    initial begin : STIMULUS

        pattern[0] = 8'h00;
        pattern[1] = 8'h55;
        pattern[2] = 8'hAA;
        pattern[3] = 8'hFF;
        p_idx      = 0;

        @(negedge rst);

        @(posedge clk);

        write_next_pattern();  
        write_next_pattern();  

 
        read_data();       

        write_next_pattern(); 
        write_next_pattern(); 


        read_data();      
        read_data();   

        while (!full) begin
            write_next_pattern();
        end

        read_data();        
        #50;
    end
endmodule*/
