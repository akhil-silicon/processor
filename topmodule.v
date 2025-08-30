`timescale 1ns / 1ps

`define oper IR[31:27]
`define rdst IR[26:22]
`define rsrc1 IR[21:17]
`define mode IR[16]
`define rsrc2 IR[15:11]
`define imm_data IR[15:0]

`define movsgpr 5'b00000
`define mov 5'b00001
`define add 5'b00010
`define sub 5'b00011
`define mul 5'b00100





module top ();

reg [31:0] IR ; // Instruction register for storing 32 bits instruction.

reg [15:0] GPR[31:0] ; // 16bit wide 32 general purpose registers.
reg [15:0] SGPR ;
reg [31:0] mul_temp ;

always @ (*)
    begin
        case(`oper)
        `movsgpr: begin 
            GPR[`rdst]=SGPR ;
        end
        
        `mov: begin
            if(`mode)
                begin
                    GPR[`rdst]=`imm_data ;
                end
             else
                begin
                    GPR[`rdst]=GPR[`rsrc1] ;
                end    
        end
        
        `add: begin
            if(`mode)
                begin
                    GPR[`rdst]=GPR[`rsrc1] +`imm_data ;
                end
             else
                begin
                    GPR[`rdst]=GPR[`rsrc1] + GPR[`rsrc2] ;
                end  
        
        end
        
         `sub: begin
            if(`mode)
                begin
                    GPR[`rdst]=GPR[`rsrc1] - `imm_data ;
                end
             else
                begin
                    GPR[`rdst]=GPR[`rsrc1] - GPR[`rsrc2] ;
                end  
        
        end
        
        `mul: begin
            if(`mode)
                begin
                    {SGPR,GPR[`rdst]}=GPR[`rsrc1] * `imm_data ;
                end
             else
                begin
                    {SGPR,GPR[`rdst]}=GPR[`rsrc1] * GPR[`rsrc2] ;
                end  
        
        end
       endcase
    end


endmodule
