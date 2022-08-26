`timescale 1ns / 1ps

module CU_DCDR(
    /*input br_eq,
    input br_lt,
    input br_ltu,*/
    input[6:0] opcode, funct7,
    input[2:0] funct3,
    input int_taken,
    
    output[3:0] alu_fun,
    output alu_srcA,
    output[1:0] alu_srcB,
    //output[2:0] pcSource,
    output[1:0] rf_wr_sel,
    output logic regWrite, memWrite, memRead2
    );
    
    //outputs
    logic aluA;
    logic[1:0] aluB, wr_sel;
//    logic[2:0] pcS;
    logic[3:0] alu_sel;
    logic REGWRITE;
    logic MEMWE2;
    logic MEMRDEN2;
    
    assign alu_srcA = aluA; assign alu_srcB = aluB; //assign pcSource = pcS; 
    assign rf_wr_sel = wr_sel; assign alu_fun = alu_sel;
    assign regWrite = REGWRITE; assign memWrite = MEMWE2; assign memRead2 = MEMRDEN2;
    
    always_comb begin
    aluA = 0; aluB = 0; /*pcS = 0;*/ wr_sel = 0; alu_sel = 0;
    
    if(int_taken) begin
        wr_sel = 1;/* pcS = 4;*/
    end
    
    else begin
        REGWRITE = 1; MEMWE2 = 0; MEMRDEN2 = 0;
        case(opcode)
            7'b0110011: begin //R-Type
            aluA = 0; aluB = 0; /*pcS = 0;*/ wr_sel = 3; //!!! Added wr_sel
            alu_sel = {funct7[5], funct3};
            end
    
            7'b0010011: begin //immediate instructions (I-type)
            aluA = 0; aluB = 1; /*pcS = 0;*/ wr_sel = 3;
            if (funct3 == 3'b101) alu_sel = {funct7[5], funct3}; //!!! This only applies to SRLI/SRAI
            else alu_sel = {1'b0, funct3};  //!!! For all other I-types
            end
    
            7'b0000011: begin //load instructions (I-type)
            aluA = 0; aluB = 1; /*pcS = 0;*/ wr_sel = 2; alu_sel = 4'b0000;
            REGWRITE = 1;
            MEMRDEN2 = 1;
            end
    
            7'b1100111: begin //jalr (I-type)
            aluA = 0; aluB = 1; /*pcS = 1;*/
            end
    
            7'b0100011: begin //S-type
            aluA = 0; aluB = 2; /*pcS = 0;*/ alu_sel = 4'b0000;
            REGWRITE = 0;
            MEMWE2 = 1;
            end
    
            7'b1100011: begin //B-Type
            /*if((funct3 == 3'b000 && br_eq) || (funct3 == 3'b101 && ~br_lt)
                || (funct3 == 3'b111 && ~br_ltu) || (funct3 == 3'b100 && br_lt)
                || (funct3 == 3'b110 && br_ltu) || (funct3 == 3'b001 && ~br_eq)) pcS = 2;
            else pcS = 0;*/
            REGWRITE = 0;
            end
    
            7'b0110111: begin //lui (U-Type)
            aluA = 1; /*pcS = 0;*/ wr_sel = 3; alu_sel = 4'b1001;
            end
    
            7'b0010111: begin //auipc (U-Type)
            aluA = 1; /*pcS = 0;*/ wr_sel = 3; aluB = 3; alu_sel = 4'b0000;
            end
    
            7'b1101111: begin //jal (J-Type)
            /*pcS = 3;*/
            end
    
            7'b1110011: begin  //csr related instructions
                if(funct3 /*==*/ != 3'b000) /*pcS = 5;*/
                /*else*/ wr_sel = 1;
            end
    
            default:;
    
    endcase
    end
    end
    
endmodule
