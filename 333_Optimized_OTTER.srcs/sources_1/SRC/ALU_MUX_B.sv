`timescale 1ns / 1ps

module ALU_MUX_B(
    input[31:0] RS2,
    input[31:0] I_TYPE,
    input[31:0] S_TYPE,
    input[31:0] PC,
    input[1:0] ALU_SRCB,
    output logic[31:0] B
    );
    
    always_comb
    begin
        if(ALU_SRCB == 0) B = RS2;
        else if(ALU_SRCB == 1) B = I_TYPE;
        else if(ALU_SRCB == 2) B = S_TYPE;
        else B = PC;
    end
endmodule
