`timescale 1ns / 1ps

module tb_booth;

parameter N = 4;

reg clk;
reg rst;
reg start;
reg signed [N-1:0] M, Q;

wire signed [2*N-1:0] result;
wire done;

// Instantiate your top module
booth_top #(N) uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .M(M),
    .Q(Q),
    .result(result),
    .done(done)
);

// Clock generation (10 time unit period)
always #5 clk = ~clk;

initial begin
    // Initialize
    clk = 0;
    rst = 1;
    start = 0;
    M = 0;
    Q = 0;

    // Apply reset
    #10 rst = 0;

    // Test Case 1: 3 × -2 = -6
    M = 4'd3;
    Q = -4'd2;

    #10 start = 1;  
    #10 start = 0;

    wait(done);

    #10;
    $display("Result = %d", result);

    // Test Case 2: -3 × -2 = 6
    #10;
    rst = 1; #10 rst = 0;

    M = -4'd3;
    Q = -4'd2;

    #10 start = 1;
    #10 start = 0;

    wait(done);

    #10;
    $display("Result = %d", result);
      // Test Case 2: 7× 4 = 28
      #10;
      rst = 1; #10 rst = 0;
  
      M = 4'd7;
      Q = 4'd4;
  
      #10 start = 1;
      #10 start = 0;
  
      wait(done);
  
      #10;
      $display("Result = %d", result);
  // Test Case 2: -7× 4 = -28
           #10;
           rst = 1; #10 rst = 0;
       
           M = -4'd7;
           Q = 4'd4;
       
           #10 start = 1;
           #10 start = 0;
       
           wait(done);
       
           #10;
           $display("Result = %d", result);
    #20 $finish;
end

endmodule
