`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jenna Whilden
// 
// Create Date: 02/05/2020 10:27:37 AM
// Module Name: Branch_Address_Generator
// Description: Converts several inputs into the appropriate address for different 
//              kinds of operations
//////////////////////////////////////////////////////////////////////////////////

module Branch_Address_Generator(
    input[31:0] pc, j_type, b_type, i_type, rs1,
    output[31:0] jal, jalr, branch
    );
    
    assign branch = b_type + pc;
    assign jal = j_type + pc;
    assign jalr = i_type + rs1;
    
endmodule