`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2023 12:31:57
// Design Name: 
// Module Name: apb_slave_tb
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


module apb_slave_tb();
wire PREADY;
wire [31:0] PRDATA;
reg PRESETn,PCLK,PWRITE,PSELx,PENABLE;
reg [31:0] PWDATA,PADDR;
parameter cycle = 10;

 apb_slave i1(.PCLK(PCLK),.PSELx(PSELx),.PENABLE(PENABLE),.PREADY(PREADY),.PRESETn(PRESETn),.PWDATA(PWDATA),.PRDATA(PRDATA),.PADDR(PADDR),.PWRITE(PWRITE));
 

 
always
begin
#(cycle/2)PCLK = 1;
#(cycle/2)PCLK = 0;

end


task PWRITE_t(input [31:0]WDATA,input [31:0]ADDR_W); 
begin
@(posedge PCLK) // clock First rising edge
begin
PWRITE = 0;
PSELx =0;
PWDATA  =0;
PADDR =0;
end
@(posedge PCLK) // clock second rising edge
begin
PWRITE = 1;
PSELx =1;
PWDATA  =WDATA;
PADDR =ADDR_W;
end
@(posedge PCLK) // clock third rising edge
PENABLE  = 1;
@(posedge PCLK) // clock fourth rising edge
begin
  PWRITE = 0;
  PENABLE = 0;
  PSELx =0;
end    
    
end
endtask

task PREAD_t(input [31:0] ADDR_R );
begin
@(posedge PCLK)  // clock First rising edge
PWRITE = 1;
PSELx =0;
PADDR =32'd0;
@(posedge PCLK)  // clock second rising edge
PWRITE = 0;
PSELx =1;
PADDR =ADDR_R;
@(posedge PCLK)  // clock third rising edge
PENABLE  = 1;


@(posedge PCLK)  // clock fourth rising edge
 PENABLE  = 0;
 PSELx =0;
    
end
endtask

task PRESETn_t; // reset to idle state
begin
PRESETn =0;
#cycle PRESETn = 1;  
end
endtask


 initial // initialize all the values to zero
 begin
 PCLK = 0;
 PWRITE  = 0;
 PSELx  = 0;
 PENABLE  = 0;
 PWDATA  =32'b0;
 PADDR =32'b0;
 PRESETn = 0;
 #2 PRESETn = 1;

 PREAD_t(32'd7);   // read from slave
 PRESETn_t;
 PWRITE_t(32'd999,32'd2); //write to slave
 PRESETn_t;
 PREAD_t(32'd6); // read from slave
 PRESETn_t;
 PWRITE_t(32'd555,32'd3); //write to slave

$stop;
 end




endmodule
