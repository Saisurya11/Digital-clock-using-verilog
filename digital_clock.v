module clock(clk,is,im,ih,s,m,h,am,ah,alarm);
input clk;
input wire [5:0]is,im,am;
input wire [3:0]ih,ah;
output reg [5:0]s=0,m=0;
output reg [3:0]h=0;
output reg alarm;
always @(posedge clk)
begin
if(s==59)
begin
s=0;
m=m+1;
end
else
s=s+1;

if(m==60)
begin
m=0;
h=h+1;
end

if(h==11)
h=0;

if(am==m && ah==h)
alarm=1;
else 
alarm=0;

$display("h=%d,m=%d,s=%d",h,m,s);
end

always @(is)
begin
s=is;
end

always @(im)
begin
m=im;
end

always @(ih)
begin
h=ih;
end

endmodule

module test;
reg clk=0;
reg [3:0]ih;
reg [5:0]im,is;
reg [3:0]ah;
reg [5:0]am;
wire [3:0]h;
wire [5:0] m,s;
wire alarm;

clock c1(clk,is,im,ih,s,m,h,am,ah,alarm);

initial
begin
$monitor("alarm=%d",alarm);
is=20;
im=58;
//ih=2;

am=20;
ah=3;
#100000
$stop;
end
always #2 clk=~clk;
endmodule
