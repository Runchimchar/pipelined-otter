`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Daniel Munic
// 
// Create Date: 03/02/2020
// Module Name: CSR
// Description: A set of special purpose registers
//////////////////////////////////////////////////////////////////////////////////


module CSR(
    input RST,
    input CLK,
    input int_taken,
    input WR_EN,
    input[11:0] ADDR,
    input[31:0] PC,
    input[31:0] WD,
    output reg CSR_MIE,
    output reg[31:0] CSR_MEPC,
    output reg[31:0] CSR_MTVEC,
    output[31:0] RD
    );
    
    //Register addresses
    const logic[11:0] mie_reg = 'h304;
    const logic[11:0] mepc_reg = 'h341;
    const logic[11:0] mtvec_reg = 'h305;
    
    logic[31:0] rd_out;
    assign RD = rd_out;
    
    always_ff@(posedge CLK) begin
        if(RST == 1) //Reset, clear the csr registers
        begin 
            CSR_MIE <= 0;
            CSR_MEPC <= 0;
            CSR_MTVEC <= 0;
        end
        else if(int_taken == 1 && CSR_MIE == 1) //Interrupt
        begin
            CSR_MEPC <= PC; //Save the current PC in MEPC when an interrupt occurs
            CSR_MIE <= 0;
        end
        else if(WR_EN == 1)
        begin
            case(ADDR) //save the current csr register value, and write the new one to the csr register
                mie_reg: begin rd_out <= CSR_MIE; CSR_MIE <= WD[0]; end
                mepc_reg: begin rd_out <= CSR_MEPC; CSR_MEPC <= WD; end
                mtvec_reg: begin rd_out <= CSR_MTVEC; CSR_MTVEC <= WD; end
                default: rd_out <= 0; //not a valid csr address
            endcase
        end
           
    end
endmodule
