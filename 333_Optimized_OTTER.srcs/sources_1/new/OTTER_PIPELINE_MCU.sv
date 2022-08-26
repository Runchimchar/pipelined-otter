`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jenna Whilden, Nayana Tiwari, Annie Joss
// 
// Create Date: 04/14/2021 04:47:36 PM
// Module Name: OTTER_PIPELINE_MCU
// Description: OTTER MCU with 5-stage pipeline.
//////////////////////////////////////////////////////////////////////////////////
  
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
        
typedef struct packed{
    logic isValid;
    logic [31:0] pc;
} RegFD;

typedef struct packed{
    logic isValid;
    logic [31:0] pc;
    logic [31:0] ir;
    logic [31:0] rs1;
    logic [31:0] rs2;
    logic [31:0] aluA;
    logic [31:0] aluB;
    logic [31:0] j_type;
    logic [31:0] b_type;
    logic [31:0] i_type;
    logic regWrite;
    logic memWrite;
    logic memRead2;
    logic[1:0] rfWrSel;
    logic[3:0] aluFun;
    opcode_t OPCODE;
} RegDE;

typedef struct packed{
    logic isValid;
    logic [31:0] pc;
    logic [31:0] ir;
    logic [31:0] rs2;
    logic regWrite;
    logic memWrite;
    logic memRead2;
    logic[1:0] rfWrSel;
    logic[31:0] aluOut;
} RegEM;

typedef struct packed{
    logic isValid;
    logic [31:0] pc;
    logic [31:0] ir;
    logic regWrite;
    logic[1:0] rfWrSel;
    logic[31:0] aluOut;
} RegMW;

module OTTER_PIPELINE_MCU(
    input[31:0] IOBUS_IN,
    input RST, INTR, CLK,
    output[31:0] IOBUS_OUT, IOBUS_ADDR,
    output IOBUS_WR
    );
        
    // Under Construction
    logic[31:0] CSR_reg;
    assign CSR_reg = 0;

    //Global connections    
    logic load_flag; 
    logic [31:0] memOut;
    logic[31:0] regData;
    logic branch_squash;
   
    //==== Instruction Fetch ===========================================
    
    // Wire
    logic[31:0] pcOutF = 0, pcIn = 0, jalr, branch, jal;
    logic[2:0] pcSource;
    logic memRead1F, pcRst, pcWr;
    
    // Assign constants
    assign memRead1F = 1; assign pcRst = RST;
    
    assign pcWr = !load_flag;

    // pc_mux    
    always_comb begin
        case(pcSource)
              3'b001: begin
                  pcIn = jalr;
                  end
              3'b010: begin
                  pcIn = branch;
                  end
              3'b011: begin
                  pcIn = jal;
                  end
             /* 3'b100: begin // Interupt stuff
                  pcIn = mtvec;
                  end
              3'b101: begin
                  pcIn = mepc; 
                  end */
              default: begin
                  pcIn = pcOutF+4;
                  end
          endcase
    end
    
    
    // PC
    Program_Counter _PC(.CLK(CLK), .PC_WRITE(pcWr), .PC_RST(pcRst), .PC_DIN(pcIn),
                        .PC_COUNT(pcOutF));
    
    // Reg_FD            
    RegFD regFD;
   
    always_ff @(posedge CLK) begin
        if (load_flag) begin
            regFD.isValid <= 1'b1;
            regFD.pc <= pcOutF;
        end
    end
         
    //==== Instruction Decode ===========================================
        
    // connections
    logic [31:0] irD, aluAD, aluBD, rs1D, rs2D;
    logic [31:0] u_type, i_type, s_type, j_type, b_type;
    logic [3:0] aluFunD;
    logic [1:0] aluSrcB, rfWrSelD;
    logic aluSrcA, regWriteD, memWriteD, memRead2D;

    // Decoder (NEED TO ADD BRANCH STUFF)
    CU_DCDR _CU_DCDR(   .alu_srcA(aluSrcA), .alu_srcB(aluSrcB), .opcode(irD[6:0]),
                        .funct3(irD[14:12]), .funct7(irD[31:25]), .regWrite(regWriteD), .memWrite(memWriteD), 
                        .memRead2(memRead2D), .rf_wr_sel(rfWrSelD), .alu_fun(aluFunD));
    
    // Reg file
    /*Reg_File _Reg_File(.CLK(CLK), .RF_ADR1(irD[19:15]), .RF_ADR2(irD[24:20]), .RF_RS1(rs1D), .RF_RS2(rs2D), // D
                        .RF_WA(regMW.ir[11:7]), .RF_WD(regData), .RF_EN(regMW.regWrite)); // W*/
        
    //Immediate generator
    Immed_Gen _Immed_Gen(.*, .ir(irD[31:7]));
    
    // MUXs
    always_comb begin
        // aluMuxA
        case(aluSrcA)
            1'b0: begin
                aluAD = rs1D;
                end
            1'b1: begin
                aluAD = u_type;
                end
        endcase
        
        // aluMuxB
        case(aluSrcB)
            2'b00: begin
                aluBD = rs2D;
                end
            2'b01: begin
                aluBD = i_type;
                end
            2'b10: begin
                aluBD = s_type;
                end
            2'b11: begin
                aluBD = regFD.pc;
                end
        endcase
    end
    
    // Register
    RegDE regDE;
    always_ff @(posedge CLK) begin
        if (!load_flag) begin
            if (branch_squash)
                regDE.isValid <= 1'b0;
            else
                regDE.isValid <= regFD.isValid;
            regDE.pc <= regFD.pc;
            regDE.ir <= irD;
            regDE.rs1 <= rs1D;
            regDE.rs2 <= rs2D;
            regDE.b_type <= b_type;
            regDE.j_type <= j_type;
            regDE.i_type <= i_type;
            regDE.regWrite <= regWriteD;
            regDE.memWrite <= memWriteD;
            regDE.memRead2 <= memRead2D;
            regDE.rfWrSel <= rfWrSelD;
            regDE.aluA <= aluAD;
            regDE.aluB <= aluBD;
            regDE.aluFun <= aluFunD;
            regDE.OPCODE <= opcode_t'(irD[6:0]);
        end
    end
    //==== Execute ======================================================
         
    // connections
    logic [31:0] aluOutE;
    logic [1:0] data_sel_A, data_sel_B;
    logic [31:0] aluA_E, aluB_E, rs1_E, rs2_E;
    
    //Data Hazard Control Unit
    Data_CU _DATACU(.EM_RD_ADDR(regEM.ir[11:7]), .MW_RD_ADDR(regMW.ir[11:7]), .RS1_ADDR(regDE.ir[19:15]),
    .RS2_ADDR(regDE.ir[24:20]), .EM_OPCODE(regEM.ir[6:0]),.MW_OPCODE(regMW.ir[6:0]), 
    .EM_VALID(regEM.isValid), .MW_VALID(regMW.isValid),
    .DE_OPCODE(regDE.ir[6:0]), .SEL_A(data_sel_A), .SEL_B(data_sel_B), .LOAD_FLAG(load_flag));
    
    
    
    always_comb begin
        // Data Hazard Mux A
        case(data_sel_A)
            2'b00: begin
                aluA_E = regDE.aluA;
                rs1_E = regDE.rs1;
                end
            2'b01: begin
                aluA_E = regEM.aluOut;
                rs1_E = regEM.aluOut;
                end
            2'b10: begin
                aluA_E = regData;
                rs1_E = regData;
                end
        endcase
        
        // Data Hazard Mux B
        case(data_sel_B)
            2'b00: begin
                aluB_E = regDE.aluB;
                rs2_E = regDE.rs2;
                end
            2'b01: begin
                aluB_E = regEM.aluOut;
                rs2_E = regEM.aluOut;
                end
            2'b10: begin
                aluB_E = regData;
                rs2_E = regData;
                end
        endcase
        
        // Make sure that loads and stores get the i-type immed
        if (regDE.ir[6:0] == LOAD || regDE.ir[6:0] == STORE)
            aluB_E = regDE.aluB;
    end

    // Target generator
    Branch_Address_Generator _BAG(.pc(regDE.pc), .j_type(regDE.j_type), .b_type(regDE.b_type), 
                        .i_type(regDE.i_type), .rs1(rs1_E),
                        .jal(jal), .jalr(jalr), .branch(branch));
    
    // Branch Condition Generator
    Branch_Condition_Generator _BCG(.rs1(rs1_E), .rs2(rs2_E), .opcode(regDE.ir[6:0]), 
                        .funct3(regDE.ir[14:12]), .isValid(regDE.isValid), .pcSource(pcSource));
    
    //Control Hazard Control Unit
    //on jump or on taken branch - squash two instruction
    always_comb begin
       case (pcSource)
       2'b00: begin
            branch_squash = 1'b0;
            //regFD.isValid = 1;
            //regDE.isValid = 1;
            end
       default: begin
            branch_squash = 1'b1;
            //regFD.isValid = 0;
            //regDE.isValid = 0;
            end
        endcase
    end
        
    
    // ALU
    ALU _ALU(.A(aluA_E), .B(aluB_E), .alu_fun(regDE.aluFun), .alu_out(aluOutE));
    
    // Register
    RegEM regEM;
    always_ff @(posedge CLK) begin
        //push no-op to execute stage so data hazard unit clears load flag.
        if (load_flag)
            regDE.ir <= 32'b0;
            
        regEM.isValid <= regDE.isValid;
        regEM.pc <= regDE.pc;
        regEM.ir <= regDE.ir;
        regEM.rs2 <= rs2_E;
        regEM.regWrite <= regDE.regWrite;
        regEM.memWrite <= regDE.memWrite;
        regEM.memRead2 <= regDE.memRead2;
        regEM.rfWrSel <= regDE.rfWrSel;
        regEM.aluOut <= aluOutE;
    end
    
    //==== Memory ======================================================
         
    // Connections
    //logic [31:0] memOut; - moved to top
         
    // Assignments
    assign IOBUS_ADDR = regEM.aluOut;
    assign IOBUS_OUT = regEM.rs2;
    
    always_comb begin
        if (regEM.isValid == 0) begin
            regEM.memWrite = 0;
        end
    end
    
    // Pipeline memory
    OTTER_mem_byte _BRAM_Memory(.MEM_CLK(CLK),.MEM_READ1(memRead1F),.MEM_ADDR1(pcOutF), //F
                        .MEM_DOUT1(irD), //D
                        .MEM_READ2(regEM.memRead2),.MEM_WRITE2(regEM.memWrite),
                        .MEM_ADDR2(regEM.aluOut),.MEM_DIN2(regEM.rs2),.MEM_SIZE(regEM.ir[13:12]),
                        .MEM_SIGN(regEM.ir[14]),.IO_IN(IOBUS_IN),.IO_WR(IOBUS_WR),
                        .MEM_DOUT2(memOut));
    
    // Register
    RegMW regMW;
    always_ff @(posedge CLK) begin
        regMW.isValid <= regEM.isValid;
        regMW.pc <= regEM.pc;
        regMW.ir <= regEM.ir;
        regMW.regWrite <= regEM.regWrite;
        regMW.rfWrSel <= regEM.rfWrSel;
        regMW.aluOut <= regEM.aluOut;
    end
    
    //==== Write Back ==================================================
         
    
    
    always_comb begin
        if (regMW.isValid == 0) begin
            regMW.regWrite = 0;
        end
    end
         
    // Reg file
    Reg_File _Reg_File(.CLK(CLK), .RF_ADR1(irD[19:15]), .RF_ADR2(irD[24:20]), .RF_RS1(rs1D), .RF_RS2(rs2D), // D
                        .RF_WA(regMW.ir[11:7]), .RF_WD(regData), .RF_EN(regMW.regWrite)); // W
                        
    // MUXs
    always_comb begin
        case(regMW.rfWrSel)
            2'b00: begin
                regData = regMW.pc + 4;
                end
            2'b01: begin
                regData = CSR_reg;
                end
            2'b10: begin
                regData = memOut;
                end
            2'b11: begin
                regData = regMW.aluOut;
                end
        endcase
    end
    
endmodule