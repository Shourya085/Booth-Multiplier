`timescale 1ns / 1ps

module booth_datapath #(parameter N=4)(clk,load,rst,shift,add,sub,m_in,q_in,q0,q_1,result);

input clk,rst,load,add,sub,shift;
input signed [N-1:0] m_in,q_in;
output q0,q_1;
output [2*N-1:0] result; 

reg signed [N-1:0] A, Q, M ;
reg Q_1 ;

always@(posedge clk or posedge rst)begin
if(rst)begin
A<=0 ;
Q<=0 ;
M<=0;
Q_1<=0 ;
end

else begin
 if(load)begin
A<=0 ;
Q<=q_in ;
M<=m_in ;
Q_1<=0 ;
end 
else if(add)begin
A<=A+M ; end 
else if(sub) begin
A<=A-M ; end 
else if(shift) begin
{A ,Q ,Q_1} <= {A[N-1] ,A, Q}; end 
end 
end

assign q0 =Q[0] ;
assign q_1 =Q_1 ;
assign result = {A , Q };
endmodule

module controller#(parameter N=4)(clk , rst , start , q0 , q_1 , load , add ,sub , shift , done );
input clk , rst , start ;
input q0 ,q_1 ;
output reg load , shift , add, sub, done ;

reg[2:0] state ; 
reg[N:0] count ; 

localparam IDLE=0 , LOAD=1, CHECK=2 , ADD=3 , SUB=4, SHIFT=5, DONE=6 ;

always@(posedge clk or posedge rst) begin
if(rst) begin
state<=IDLE ;
count<=0 ; 
end 
else begin
case(state)
IDLE: begin
if(start) state<=LOAD ; 
end
LOAD: begin
count<=N ; 
state<=CHECK ;
end 
CHECK: begin
case({q0,q_1})
2'b01:  state<=ADD ;
2'b10:  state<=SUB ;
default: state<=SHIFT; 
endcase
end 
ADD: state<=SHIFT ;
SUB: state<=SHIFT ; 
SHIFT: begin
count<= count -1 ;
if(count==1) 
state <=DONE ; 
else 
state <= CHECK ; 
end 
DONE: state <= IDLE ;

endcase
end 
end 

//control signal generator 
always@(*) begin
load=0 ; add=0 ; sub =0 ; shift=0 ; done=0 ; 

case(state)
LOAD: load=1 ;
ADD: add=1 ;
SUB:  sub=1 ;
SHIFT: shift=1 ;
DONE: done=1 ; 
endcase
end 
endmodule

module booth_top #(parameter N=4)(clk,rst,start,M,Q,result,done);
input clk,start,rst ;
input[N-1:0] M,Q ;
output [2*N-1:0] result ;
output done ;

wire load ,add , sub , shift , q0,q_1 ;

booth_datapath #(N) dp (
              .clk(clk),
              .rst(rst),
              .load(load),
              .shift(shift),
              .add(add),
              .sub(sub),
              .m_in(M),
              .q_in(Q),
              .q0(q0),
              .q_1(q_1),
              .result(result)
              ) ;
controller #(N) cp (
                    .clk(clk),
                    .rst(rst),
                    .start(start),
                    .q0(q0),
                    .q_1(q_1),
                    .load(load),
                    .add(add),
                    .sub(sub),
                    .shift(shift),
                    .done(done)
                    );

endmodule
