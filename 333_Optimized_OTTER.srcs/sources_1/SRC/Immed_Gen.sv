`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jenna Whilden, Daniel Munic
// 
// Create Date: 01/29/2020 11:21:01 AM
// Module Name: Immed_Gen
// Description: Recieves a 32b instruction and converts it to 5 immediate types
// 
//////////////////////////////////////////////////////////////////////////////////


module Immed_Gen(
    input [31-7:7-7] ir,
    output [31:0] u_type, i_type, s_type, b_type, j_type
    );
    
    assign u_type = {ir[31-7:12-7],12'b0};
    assign i_type = {{21{ir[31-7]}},ir[30-7:20-7]};
    assign s_type = {{21{ir[31-7]}},ir[30-7:25-7],ir[11-7:7-7]};
    assign b_type = {{20{ir[31-7]}},ir[7-7],ir[30-7:25-7],ir[11-7:8-7],1'b0};
    assign j_type = {{12{ir[31-7]}},ir[19-7:12-7],ir[20-7],ir[30-7:21-7],1'b0};
    
endmodule
