`timescale 1ns / 1ps

module ALU_MUX_A(
    input ALU_SRCA, //select
    input[31:0] RS1,
    input[31:0] U_TYPE,
    output logic[31:0] A
    );
    
    always_comb
    begin
        if(ALU_SRCA == 0) A = RS1;
        else A = U_TYPE;
    end
        
    
endmodule
