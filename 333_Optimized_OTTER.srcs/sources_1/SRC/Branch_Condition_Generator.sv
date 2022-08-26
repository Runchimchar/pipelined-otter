`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2020 10:21:47 AM
// Design Name: 
// Module Name: Branch_Condition_Generator
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


module Branch_Condition_Generator(
    input[31:0] rs1,
    input[31:0] rs2,
    input[6:0] opcode, 
    input[2:0] funct3,
    input isValid,
    output logic[2:0] pcSource
    /*output br_eq,
    output br_lt,
    output br_ltu*/
    );
    
    logic int_taken, br_eq, br_lt, br_ltu;
    
    assign int_taken = 0;
    assign br_eq = rs1==rs2; //check if the two values are equal
    assign br_lt = $signed(rs1)<$signed(rs2); //check if the first number is less than the second, signed
    assign br_ltu = rs1<rs2; //check if the first number is less than the second, unsigned
    
    always_comb begin
    pcSource = 0;
    
    if(int_taken) begin
        pcSource = 4;
    end
    
    else if (!isValid) begin
        pcSource = 0;
    end
    
    else begin
        case(opcode)
            7'b0110011: begin //R-Type
            pcSource = 0;
            end
    
            7'b0010011: begin //immediate instructions (I-type)
            pcSource = 0;
            end
    
            7'b0000011: begin //load instructions (I-type)
            pcSource = 0;
            end
    
            7'b1100111: begin //jalr (I-type)
            pcSource = 1;
            end
    
            7'b0100011: begin //S-type
            pcSource = 0;
            end
    
            7'b1100011: begin //B-Type
            if((funct3 == 3'b000 && br_eq) || (funct3 == 3'b101 && ~br_lt)
                || (funct3 == 3'b111 && ~br_ltu) || (funct3 == 3'b100 && br_lt)
                || (funct3 == 3'b110 && br_ltu) || (funct3 == 3'b001 && ~br_eq)) pcSource = 2;
            else pcSource = 0;
            end
    
            7'b0110111: begin //lui (U-Type)
            pcSource = 0;
            end
    
            7'b0010111: begin //auipc (U-Type)
            pcSource = 0;
            end
    
            7'b1101111: begin //jal (J-Type)
            pcSource = 3;
            end
    
            7'b1110011: begin  //csr related instructions
            if(funct3 == 3'b000) pcSource = 5;
            else pcSource = 0;
            end
    
            default: begin
            pcSource = 0;
            end
    
    endcase
    end
    end
    
    
endmodule
