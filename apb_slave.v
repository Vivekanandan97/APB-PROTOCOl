`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vivekanandan and Harini
// Create Date: 13/11/23
// Module Name: apb_slave
// Project Name: UART controller using apb protocol
// Target Devices: 
// Tool Versions: xilinx vivado
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module apb_slave(PCLK,PSELx,PENABLE,PREADY,PRESETn,PWDATA,PRDATA,PADDR,PWRITE);
reg [31:0]mem[31:0];
output reg PREADY;
output reg [31:0] PRDATA;

input PRESETn,PCLK,PWRITE,PSELx,PENABLE;
input [31:0] PWDATA,PADDR;
parameter IDLE = 2'b00;
parameter SETUP = 2'b01;
parameter ACCESS = 2'b10;
reg [1:0]present_state,next_state;


initial
begin
PREADY = 0;
PRDATA = 32'b0;
end


always@(posedge PCLK or negedge PRESETn)
begin

  if(!PRESETn)begin
     present_state <= IDLE;
    
     end
  else 
     begin
  
     present_state <= next_state;
     end
end

always@(present_state or PSELx or PENABLE )
begin
next_state = IDLE; // default state
case(present_state)

IDLE : if(PSELx & !PENABLE)
       begin
        next_state = SETUP;        
        PREADY = 1'b0;
        PRDATA = 32'b0;
        end
       else
       begin
        next_state = IDLE;
        PREADY = 1'b0;
        PRDATA = 32'b0;
       end
SETUP :begin 
        next_state = ACCESS;
          if(PWRITE)
             begin
               PREADY = (PWRITE && PSELx && PENABLE ); // To avaoid protocol violation
                  if(PREADY)
                      mem[PADDR] = PWDATA; // Write transfer performed
                  else
                      mem[PADDR] = mem[PADDR]; //Write is not transfer performed
              end
          else
               begin
                  PREADY = (!PWRITE && PSELx && PENABLE ); // To avaoid protocol violation
                     if(PREADY)
                         begin
                           mem[6] = 32'd917;
                           mem[7] = 32'd817;
                           PRDATA = mem[PADDR];
                        end
               end         
       end
          
ACCESS : if(!PSELx & !PENABLE )
         begin
         next_state = IDLE;         
         PREADY = 1'b0;
         PRDATA = 32'b0;
         end  
         else if(PSELx & !PENABLE)
         next_state = SETUP;                     
         else
         next_state = ACCESS;
 endcase
 end 
 
endmodule
