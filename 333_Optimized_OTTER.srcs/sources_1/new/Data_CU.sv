`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2021 10:35:42 AM
// Design Name: 
// Module Name: Data_CU
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


module Data_CU(
    input [4:0] EM_RD_ADDR, MW_RD_ADDR, RS1_ADDR, RS2_ADDR,
    input [6:0] EM_OPCODE, MW_OPCODE, DE_OPCODE,
    input EM_VALID, MW_VALID,
    output logic [1:0] SEL_A, SEL_B,
    output logic LOAD_FLAG
    );
  typedef enum logic [6:0] {
           LUI      = 7'b0110111,
           AUIPC    = 7'b0010111,
           JAL      = 7'b1101111,
           JALR     = 7'b1100111,
           BRANCH   = 7'b1100011,
           LOAD     = 7'b0000011,
           STORE    = 7'b0100011,
           OP_IMM   = 7'b0010011,
           OP       = 7'b0110011,
           SYSTEM   = 7'b1110011
 } opcode_t;
 
opcode_t em_opcode, mw_opcode, de_opcode;
     
assign em_opcode = opcode_t'(EM_OPCODE); //most recent instr
assign mw_opcode = opcode_t'(MW_OPCODE); //two instr. prior
assign de_opcode = opcode_t'(DE_OPCODE); //current instr

logic em_rd_used, mw_rd_used;
logic de_rs1_used, de_rs2_used;
//not branch and store
assign em_rd_used = EM_RD_ADDR != 0 && em_opcode != BRANCH && em_opcode != STORE;
assign mw_rd_used = MW_RD_ADDR != 0 && mw_opcode != BRANCH && mw_opcode != STORE;


    assign de_rs1_used=    RS1_ADDR != 0
                                && de_opcode != LUI
                                && de_opcode != AUIPC
                                && de_opcode != JAL;
    assign de_rs2_used=    RS2_ADDR != 0
                                && (de_opcode == BRANCH
                                || de_opcode == STORE
                                || de_opcode == OP);
                                

/* Mux choices
    0: whatever is chosen in decode stage
    1: ex-mem stage (most recent instr.)
    2: mem-wb stage (2nd prev. instr.)
*/
always_comb
    begin
        //SEL A
        if (EM_VALID && em_rd_used && de_rs1_used && EM_RD_ADDR == RS1_ADDR)//rd used oin EM and rs1 used in de and rd == rs1 then set sel to forward from em to now
            SEL_A = 1; //execute/mem forwarded to rs1
        else if (MW_VALID && mw_rd_used && de_rs1_used && MW_RD_ADDR == RS1_ADDR)
            SEL_A = 2; //mem/wb aluout forwarded to rs1
        else 
            SEL_A = 0;
           
        
        //SEL B
        if (EM_VALID && em_rd_used && de_rs2_used && EM_RD_ADDR == RS2_ADDR)//rd used oin EM and rs1 used in de and rd == rs1 then set sel to forward from em to now
            SEL_B = 1; //execute/mem forwarded to rs1
        else if (MW_VALID && mw_rd_used && de_rs2_used && MW_RD_ADDR == RS2_ADDR)
            SEL_B = 2; //mem/wb aluout forwarded to rs1
        else
            SEL_B = 0;
            
        //If current instr. is a load
        if (EM_OPCODE == LOAD)
            LOAD_FLAG = 1;
        else
            LOAD_FLAG = 0;
       
    end           
endmodule