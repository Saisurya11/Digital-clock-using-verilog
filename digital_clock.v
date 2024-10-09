`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2024 15:34:40
// Design Name: 
// Module Name: clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock(clk,con,ih,im,h,m,s);
input clk,con,ih,im;
output reg [4:0]h=0;
output reg [5:0]m=0,s=0;
always@(posedge clk)
begin

if(con && ih)
begin
if(h==23)
h<=0;
else
h<=h+1;
end

if(con && im)
begin
if(m==59)
m<=0;
else
m<=m+1;
end


if(s==59)
begin
s<=0;
if(m==59)
begin
m<=0;
if(h==23)
h<=0;
else
h<=h+1;
end
else
m<=m+1;
end
else
s<=s+1;
end
endmodule
/*
module test;
reg clk=0,con=0,ih=0,im=0;
wire [3:0]h;
wire [5:0]m,s;

clock tb(clk,con,ih,im,h,m,s);
initial
begin
#5000
con=1; #2
ih=0; im=1;#2
ih=1; im=0;#2
ih=0; im=1;#2
ih=1; im=0;#2
con=0;
#5
$stop;
end

always #1clk=~clk;
endmodule
*/

module alarm(clk,ala,ih,im,h,m);
input ala,ih,im,clk;
output reg [4:0]h=0;
output reg [5:0]m=0;
always@(posedge clk)
begin
if(ala && ih)
begin
if(h==23)
h<=0;
else
h<=h+1;
end
else
h<=h;
end

always@(posedge clk)
begin
if(ala && im)
begin
if(m==60)
m<=0;
else
m<=m+1;
end
else
m<=m;
end

endmodule

//module test;
//reg ala,ih=0,im=0;
//wire [3:0]h;
//wire [5:0]m;
//alarm tb(ala,ih,im,h,m);
//initial
//begin
//ala=0; #2
//ih=1; im=1; #2
//ala=1; #2
//ih=1; im=1; #2
//ih=0; im=0; #2
//ih=1; im=1; #2
//ih=0; im=0; #2
//ih=1; im=1; #2
//$stop;
//end
//endmodule

module convert(clk,con,ih,im,ala,ala_con,ah,am,hr,min,sec,light);
input clk,con,ih,im,ah,am,ala;
output reg [4:0]hr;
output reg [5:0]min,sec;
output reg light=0;
input ala_con;
wire [4:0]h1,h2;
wire [5:0]m1,m2,s1;

clock con1(clk,con,ih,im,h1,m1,s1);
alarm con2(clk,ala,ah,am,h2,m2);
always@(*)
begin
light=0;

if(h2==h1 && m2==m1)
begin
if(ala_con)
light<=1;
end

if(ala)
begin
hr<=h2;
min<=m2;
sec<=s1;
end
else
begin
hr<=h1;
min<=m1;
sec<=s1;
end
end
endmodule

//module test;
//reg clk=0,con=0,ih=0,im=0,ah=0,am=0,ala=0,ala_con=0;
//wire [3:0]hr;
//wire [5:0]min,sec;
//wire light;
//convert tb1(clk,con,ih,im,ala,ala_con,ah,am,hr,min,sec,light);
//initial
//begin
//#5000
//ala=1;
//ah=1; am=1; #2
//ah=0; #2
//ah=1; #2
//ah=0; am=0; #2
//ah=1; am=0; #2
//ala=0;
//con=1; 
//ih=1; im=1;#2
//ih=0; im=0;#2
//ih=1; im=1;#2
//con=0; #2
//#10
//ala_con=1;
//$finish;
//end

//always #1clk=~clk;
//endmodule

module refresh_counter(clk,out);
input clk;
output reg [2:0]out=0;
always@(posedge clk)
begin
if(out==5)
out<=0;
else
out<=out+1;
end
endmodule

module clock_divider(clk,nclk,seg_clk);
input clk;
output reg nclk=0;
output seg_clk;
reg [31:0]count,val;
always@(posedge clk)
begin
if(count==50000000)
begin
count<=0;
nclk<=~nclk;
end
else
count<=count+1;
end

always@(posedge clk)
begin
if(val==32'hFFFFFFFF)
val<=0;
else
val<=val+1;
end

assign seg_clk=val[16];
endmodule


module display(clk,con,ih,im,ala,ala_con,ah,am,an,light,seg);
input clk,con,ih,im,ala,ala_con,ah,am;
output reg[7:0]an=8'b11111111;
output reg [6:0]seg=7'b1111111;
output light;

wire nclk,seg_clk;
wire [2:0]out;
wire [4:0]hr;
wire [5:0]min,sec;
reg [3:0]bcd=0;

clock_divider m1(clk,nclk,seg_clk);
refresh_counter m2(seg_clk,out);
convert m3(nclk,con,ih,im,ala,ala_con,ah,am,hr,min,sec,light);
always@(out,hr,min,sec)
begin
case(out)
0:begin
bcd<=hr/10;
an<=8'b01111111;
end
1:begin
bcd<=hr%10;
an<=8'b10111111;
end
2:begin
bcd<=min/10;
an<=8'b11101111;
end
3:begin
bcd<=min%10;
an<=8'b11110111;
end
4:begin
bcd<=sec/10;
an<=8'b11111101;
end
5:begin
bcd<=sec%10;
an<=8'b11111110;
end
default:begin
bcd<=8;
an<=8'b11111110;
end
endcase
case(bcd)
0:seg<=7'b1000000;
1:seg<=7'b1111001;
2:seg<=7'b0100100;
3:seg<=7'b0110000;
4:seg<=7'b0011001;
5:seg<=7'b0010010;
6:seg<=7'b0000010;
7:seg<=7'b1111000;
8:seg<=7'b0000000;
9:seg<=7'b0010000;
default:seg<=7'b0111111;
endcase
end
endmodule

module top(clk,btnU,btnD,btnL,btnR,sw,an,seg,led);
input [2:0]sw;
input clk,btnU,btnD,btnL,btnR;
output [7:0]an;
output [6:0]seg;
output led;
/*
con=sw[0] ,for updating the time , after updating it has to be set low
ih=sw[1] , for updating the hour
im=sw[2], for updating the minute
ala=sw[3], for setting the alarm
ala_con=sw[4], for actvating the alarm
ah=sw[5], for setting the alarm high
am=sw[6], for seeting the minutes for alarm

sw[6]=top_btn
*/
display tp1(clk,sw[0],btnL,btnR,sw[1],sw[2],btnU,btnD,an,led,seg);
//display  (clk,con,ih,im,ala,ala_con,ah,am,an,light,seg);
endmodule

/*hr will be continously updating untile the clock is coming so we have to turn off the swithc as soon as reaches requirement
same for minutes and alarm inputs*/




