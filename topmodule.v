`timescale 1ns / 1ps

//---------------------------Declaring Instruction register-----------------------------------//

`define oper IR[31:27]
`define rdst IR[26:22]
`define rsrc1 IR[21:17]
`define mode IR[16]
`define rsrc2 IR[15:11]
`define imm_data IR[15:0]

//---------------------------Declaring operation-----------------------------------//

`define movsgpr     5'b00000
`define mov         5'b00001
`define add         5'b00010
`define sub         5'b00011
`define mul         5'b00100

`define oper_or     5'b00101
`define oper_and    5'b00110
`define oper_xor    5'b00111
`define oper_xnor   5'b01000
`define oper_nand   5'b01001
`define oper_nor    5'b01010
`define oper_not    5'b01011



//-------------------------------module declaration---------------------------------//

module top (
input clk,sysreset,
input [15:0] din,
output reg [15:0] dout

);

//--------------------------------creating memory(harvard)--------------------------//

reg [31:0] progmem [7:0]; // Program memory :- 32 bit wide and 8 bit depth
reg [15:0] datamem [7:0]; // Data memory    :- 16 bit wide and 8 bit depth

//------------------------------declaring instruction register----------------------//

reg [31:0] IR ; // Instruction register for storing 32 bits instruction.
reg [15:0] GPR[31:0] ; // 16bit wide 32 general purpose registers.
reg [15:0] SGPR ;
reg [31:0] mul_temp ;

//------------------------------flags----------------------------------------------//

reg sign_flag=0,zero_flag=0,carry_flag=0,overflow_flag=0;
reg [16:0] add_temp;

//---------------------------Arithmetic logic operation----------------------------//
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

//--------------------------bitwise operation----------------------------//
        
        //bitwise OR operation
        `oper_or: begin
            if(`mode)
                begin
                    GPR[`rdst]=GPR[`rsrc1] | `imm_data ;
                end
             else
                begin
                    GPR[`rdst]=GPR[`rsrc1] | GPR[`rsrc2] ;
                end  
        
        end
        
        //bitwise AND operation
        `oper_and: begin
            if(`mode)
                begin
                    GPR[`rdst]=GPR[`rsrc1] & `imm_data ;
                end
             else
                begin
                    GPR[`rdst]=GPR[`rsrc1] & GPR[`rsrc2] ;
                end  
        
        end
        
        //bitwise XOR operation
        `oper_xor: begin
            if(`mode)
                begin
                    GPR[`rdst]=GPR[`rsrc1] ^ `imm_data ;
                end
             else
                begin
                    GPR[`rdst]=GPR[`rsrc1] ^ GPR[`rsrc2] ;
                end  
        
        end
        
        //bitwise XNOR operation
        `oper_xnor: begin
            if(`mode)
                begin
                    GPR[`rdst]=GPR[`rsrc1] ~^ `imm_data ;
                end
             else
                begin
                    GPR[`rdst]=GPR[`rsrc1] ~^ GPR[`rsrc2] ;
                end  
        
        end
        
        //bitwise NAND operation
        `oper_nand: begin
            if(`mode)
                begin
                    GPR[`rdst]=~(GPR[`rsrc1] & `imm_data) ;
                end
             else
                begin
                    GPR[`rdst]=~(GPR[`rsrc1] & GPR[`rsrc2]) ;
                end  
        
        end
        
        //bitwise NOR operation
        `oper_nor: begin
            if(`mode)
                begin
                    GPR[`rdst]=~(GPR[`rsrc1] | `imm_data) ;
                end
             else
                begin
                    GPR[`rdst]=~(GPR[`rsrc1] | GPR[`rsrc2]) ;
                end  
        
        end
        
        //bitwise NOT operation
        
        `oper_not: begin
            if(`mode)
                begin
                    GPR[`rdst]=~(`imm_data) ;
                end
             else
                begin
                    GPR[`rdst]=~(GPR[`rsrc1]) ;
                end  
        
        end
        
       endcase
    end
    
//--------------------------------------------- FLAGS-----------------------------------------------------



always @(*)
begin
    // ---sign flag ---
   if (`oper == `mul )
    sign_flag = SGPR[15];
    else
    sign_flag = GPR[`rdst][15];
    
    // ---zero flag ---
    zero_flag = ~(|(GPR[`rdst]));
    
    // ---carry_flag ---
    if (`oper == `add)
        begin
            if (`mode)           
                add_temp = GPR[`rsrc1] + `imm_data; 
                else
                add_temp = GPR[`rsrc1] + GPR[`rsrc2];           
        end
    carry_flag = add_temp[16];
    
    // --overflow flag --
    if(`oper == `add)
    begin
        if(`mode)
            overflow_flag = (~GPR[`rsrc1][15] & ~(IR[15]) & GPR[`rdst][15]) | (GPR[`rsrc1][15] & (IR[15]) & ~GPR[`rdst][15]);
        else
            overflow_flag = (~GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & GPR[`rsrc2][15] & ~GPR[`rdst][15]);   
    end
    else
    if(`oper == `sub)
     begin
        if(`mode)
            overflow_flag = (~GPR[`rsrc1][15] & (IR[15]) & GPR[`rdst][15]) | (GPR[`rsrc1][15] & (IR[15]) & ~GPR[`rdst][15]);
        else
            overflow_flag = (~GPR[`rsrc1][15] & GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & GPR[`rsrc2][15] & ~GPR[`rdst][15]);   
    end
    
    
    
end
    
    
   
  


endmodule
