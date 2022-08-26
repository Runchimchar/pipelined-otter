`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2020 07:54:10 PM
// Design Name: 
// Module Name: OTTER_Wrapper_Sim
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


module OTTER_Wrapper_Sim();
    logic CLK = 1;
    logic BTNL = 0;
    logic BTNC = 0;
    logic [15:0] SWITCHES;
    logic [15:0] LEDS;
    logic [7:0] CATHODES;
    logic [3:0] ANODES;
    //logic [7:0] VGA_RGB;
    //logic VGA_HS;
    //logic VGA_VS;
    
    OTTER_Wrapper inst(.*);
    
    // Clock generator
    always begin
        #5 CLK = 0;
        #5 CLK = 1;
    end
    
    // Tests
    initial begin
        BTNC = 1;
        SWITCHES = 16'b0;
        #25 BTNC = 0;
    end
    
endmodule
