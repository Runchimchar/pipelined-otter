`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jenna Whilden
// 
// Create Date: 02/14/2020 10:28:48 AM
// Module Name: CU_FSM
// Description: Control Unit FSM
//////////////////////////////////////////////////////////////////////////////////


module CU_FSM(
    input RST_IN, INTR, CLK, 
    input[6:0] OPCODE,
    input[2:0] funct3,
    output logic PCWRITE, REGWRITE, MEMWE2, MEMRDEN1, MEMRDEN2, RST_OUT, INT_TAKEN, CSR_WE
    );
    
    typedef enum {ST_FETCH, ST_EXEC, ST_WRITEBACK, ST_INTRPT} STATE;
    STATE NS, PS;
    
    assign RST_OUT = RST_IN; // Quick reset
    
    always_ff@(posedge CLK) begin
        if (RST_IN==1) begin 
            PS <= ST_FETCH;
            //RST_OUT <= 1; // Reset PC
        end 
        else begin 
            PS <= NS;
            //RST_OUT <= 0; // Don't reset PC 
        end
    end
    
    always_comb begin 
        REGWRITE = 0; MEMWE2 = 0; MEMRDEN1 = 0; MEMRDEN2 = 0; INT_TAKEN = 0; CSR_WE = 0;
        PCWRITE = 1; // Increment by default
        case (PS)
            ST_FETCH: begin // Get instruction
                PCWRITE = 0;
                MEMRDEN1 = 1;
                NS = ST_EXEC;
                end
                
            ST_EXEC: begin
                NS = ST_FETCH; // MOST of these will go onto fetch
                if(INTR) NS = ST_INTRPT;
                else
                begin
                case (OPCODE)
                    7'b0000011: begin // LOADS
                        PCWRITE = 0;
                        MEMRDEN2 = 1; // Read data from mem
                        NS = ST_WRITEBACK;
                        end
                        
                    7'b0100011: // SAVES
                        MEMWE2 = 1; // Write to mem
                        
                    7'b1100011: REGWRITE = 0; // BRANCHES
                    
                    7'b1110011: begin if(funct3 != 3'b000) CSR_WE = 1; end //Write to CSR Register
                        
                    default: // R, J, U types
                        REGWRITE = 1; // MOST things just write to the registers 
                endcase
                end
                end
                
            ST_WRITEBACK: begin // Change based on instruction
                REGWRITE = 1; // Write to reg
                if(INTR) NS = ST_INTRPT;
                else NS = ST_FETCH;
                end
                
            ST_INTRPT: begin
                INT_TAKEN = 1; //interupt
                NS = ST_FETCH;
            end
                
            default: begin // For latches and such
                NS = ST_FETCH;
                end
        endcase
    end
    
endmodule
