`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jenna Whilden
// 
// Create Date: 02/14/2020 10:28:48 AM
// Module Name: CU_FSM
// Description: Encapsulated microcontroller
//////////////////////////////////////////////////////////////////////////////////

module MCU(
    input[31:0] IOBUS_IN,
    input RST, INTR, CLK,
    output[31:0] IOBUS_OUT, IOBUS_ADDR,
    output IOBUS_WR
    );
    
    // Declare all interconnections
    wire[31:0] jalr, branch, jal, mtvec, mepc, pc, rs1, rs2, ir,
                j_type, b_type, u_type, i_type, s_type,
                alu_muxa, alu_muxb, alu_out, mem_dout2;
    wire br_eq, br_lt, br_ltu, pc_write, reg_write, mem_we2,
            mem_rden1, mem_rden2, pc_rst, alu_srca, int_taken,
            csr_we, mie;
    wire[1:0] alu_srcb, rf_wr_sel;
    wire[2:0] pc_source;
    wire[3:0] alu_fun;
    logic [31:0] wd_mux, pc_mux;
    
    // Under Construction
    logic[31:0] CSR_reg;
    
    // Assignments
    assign IOBUS_ADDR = alu_out;
    assign IOBUS_OUT = rs2;
    
    // MUXs
    always_comb begin
        // wd_mux
        case(rf_wr_sel)
            2'b00: begin
                wd_mux = pc+4;
                end
            2'b01: begin
                wd_mux = CSR_reg;
                end
            2'b10: begin
                wd_mux = mem_dout2;
                end
            2'b11: begin
                wd_mux = alu_out;
                end
        endcase
        
        // pc_mux
        case(pc_source)
            3'b001: begin
                pc_mux = jalr;
                end
            3'b010: begin
                pc_mux = branch;
                end
            3'b011: begin
                pc_mux = jal;
                end
            3'b100: begin
                pc_mux = mtvec;
                end
            3'b101: begin
                pc_mux = mepc;
                end
            default: begin
                pc_mux = pc+4;
                end
        endcase
    end
    
    // Subcomponents
    ALU_MUX_A _ALUma(.ALU_SRCA(alu_srca), .RS1(rs1), .U_TYPE(u_type), .A(alu_muxa));
    ALU_MUX_B _ALUmb(.ALU_SRCB(alu_srcb), .RS2(rs2), .I_TYPE(i_type), .S_TYPE(s_type),
                        .PC(pc), .B(alu_muxb));
    ALU _ALU(.A(alu_muxa), .B(alu_muxb), .alu_fun(alu_fun), .alu_out(alu_out));
    Branch_Address_Generator _BAG(.*);
    Branch_Condition_Generator _BCG(.*);
    CSR _CSR(.*, .ADDR(ir[31:20]), .PC(pc), .WD(rs1), .CSR_MEPC(mepc), .CSR_MTVEC(mtvec), .CSR_MIE(mie),
                        .RD(CSR_reg), .WR_EN(csr_we));
    CU_DCDR _CU_DCDR(.*, .alu_srcA(alu_srca), .alu_srcB(alu_srcb), .pcSource(pc_source), .opcode(ir[6:0]),
                        .funct3(ir[14:12]), .funct7(ir[31:25]), .regWrite(reg_write), .memWrite(mem_we2), 
                        .memRead2(mem_rden2));
    assign pc_write = 1; assign mem_rden1 = 1;
    /*CU_FSM _CU_FSM(.*, .RST_IN(RST), .OPCODE(ir[6:0]), .funct3(ir[14:12]), .PCWRITE(pc_write), .REGWRITE(reg_write),
                        .MEMWE2(mem_we2), .MEMRDEN1(mem_rden1), .MEMRDEN2(mem_rden2),
                        .RST_OUT(pc_rst), .INT_TAKEN(int_taken), .CSR_WE(csr_we), .INTR(mie&&INTR)); */
    Immed_Gen _Immed_Gen(.*, .ir(ir[31:7]));
    Memory _Memory(.MEM_CLK(CLK), .MEM_RDEN1(mem_rden1), .MEM_RDEN2(mem_rden2), .MEM_WE2(mem_we2),
                        .MEM_ADDR1(pc[15:2]), .MEM_ADDR2(alu_out), .MEM_WD(rs2), .MEM_SIZE(ir[13:12]),
                        .MEM_SIGN(ir[14]), .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_DOUT1(ir),
                        .MEM_DOUT2(mem_dout2));
    Program_Counter _PC(.*, .PC_WRITE(pc_write), .PC_RST(pc_rst), .PC_DIN(pc_mux),
                        .PC_COUNT(pc));
    Reg_File _Reg_File(.*, .RF_ADR1(ir[19:15]), .RF_ADR2(ir[24:20]), .RF_WA(ir[11:7]),
                        .RF_WD(wd_mux), .RF_EN(reg_write), .RF_RS1(rs1), .RF_RS2(rs2) );
    
                          
endmodule