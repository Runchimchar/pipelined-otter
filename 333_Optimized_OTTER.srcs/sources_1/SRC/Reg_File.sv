`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jenna Whilden
// 
// Create Date: 01/22/2020 11:11:55 AM
// Module Name: Reg_File
// Description: OTTER Register File module
// 
//////////////////////////////////////////////////////////////////////////////////


module Reg_File(
    input[4:0] RF_ADR1, RF_ADR2, RF_WA,
    input[31:0] RF_WD,
    input RF_EN, CLK,
    output[31:0] RF_RS1, RF_RS2
    );
    
    // Declare & Assign vars
    logic[31:0] mem[0:31];
    assign RF_RS1 = mem[RF_ADR1];
    assign RF_RS2 = mem[RF_ADR2];
    
    // Initialization
    initial begin
        // Clear mem
        for (int i=0; i<32; i++) begin
            mem[i] = 0;   
        end
        mem[2] = 32'h00010000; // Set default sp
    end
    
    // Ff logic ( <= )
    // WRITE ON THE NEGATIVE EDGE FOR SAME CYCLE RW
    always_ff@(negedge CLK) begin
        // If write is enabled, write to mem
        // Can't write if addressing x0
        if (RF_EN && RF_WA != 0) begin
            mem[RF_WA] <= RF_WD;
        end
    end
    
endmodule
