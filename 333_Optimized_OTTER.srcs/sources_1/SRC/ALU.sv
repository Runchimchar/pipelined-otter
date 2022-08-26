`timescale 1ns / 1ps

module ALU(
    input[31:0] A,
    input[31:0] B,
    input[3:0] alu_fun,
    output[31:0] alu_out
    );
    
    //logic[31:0] unsignedA, unsignedB;
    //assign unsignedA = unsigned'(A);
    //assign unsignedB = unsigned'(B);
    
    logic[31:0] out;
    assign alu_out = out;
    
    always_comb
    begin
    case(alu_fun)
        4'b0000 :  out = A+B;//AND
        4'b1000 : out = A-B;//SUB
        4'b0110 : out = A|B;//OR
        4'b0111 : out = A&B;//AND
        4'b0100 : out = A^B;//XOR
        4'b0101 : out = A>>B[4:0];//SRL
        4'b0001 : out = A<<B[4:0];//SLL
        4'b1101 : out = $signed(A)>>>B[4:0];//SRA
        4'b0010 : if($signed(A)<$signed(B)) out = 1; else out = 0;//SLT
        4'b0011 : if(A<B) out = 1; else out = 0;//SLTU
        4'b1001 : out = A;//LUI-COPY
        4'b1010 : out = 0;
        4'b1011 : out = 0;
        4'b1100 : out = 0;
        4'b1110 : out = 0;
        4'b1111 : out = 0;
        endcase
    end
        
endmodule
