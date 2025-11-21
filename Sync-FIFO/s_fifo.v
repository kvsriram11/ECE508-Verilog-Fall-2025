module fifo #(parameter WIDTH = 8, parameter DEPTH = 8) (clk, rst, wen, ren, din, dout, full, empty);
    input  clk;
    input  rst;
    input  wen;
    input  ren;
    input  [WIDTH-1:0] din;
    output [WIDTH-1:0] dout;
    output full;
    output empty;

    reg [WIDTH-1:0] dout;


    parameter PTR_WIDTH = 3; 

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] wptr;
    reg [PTR_WIDTH-1:0] rptr;

    wire [PTR_WIDTH-1:0] wptr_next = wptr + 1'b1;
    wire [PTR_WIDTH-1:0] rptr_next = rptr + 1'b1;


    assign empty = (wptr == rptr);
    assign full  = (wptr_next == rptr);


    always @(posedge clk) begin
        if (rst) begin
            wptr <= 0;
            rptr <= 0;
            dout <= 0;
        end else begin
            if (wen && !full) begin
                mem[wptr] <= din;
                wptr <= wptr_next;
            end
            if (ren && !empty) begin
                dout <= mem[rptr];
                rptr <= rptr_next;
            end
        end
    end

endmodule
