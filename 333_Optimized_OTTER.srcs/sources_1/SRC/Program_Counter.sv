`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2020 10:11:50 AM
// Design Name: 
// Module Name: Program_Counter
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


module Program_Counter(
    input CLK,
    input PC_WRITE,
    input PC_RST,
    input[31:0] PC_DIN,
    output logic[31:0] PC_COUNT = 0
    );
    
    // Immediatly output 0 if reset
    always_comb begin
        if (PC_RST == 1)
            PC_COUNT = 0;
    end
    
    //this completes on the falling edge of every clock cycle
    always_ff@(negedge CLK)
    begin
        //Write, synchronous active high
        if(PC_WRITE == 1)
        begin
        //if Write is high and Reset is low, the output is the input.
            PC_COUNT = PC_DIN; 
        end
        //Reset, synchronous active high
        if (PC_RST == 1) 
        begin
            PC_COUNT = 0;
        end
    end
    
endmodule
