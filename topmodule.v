module topmodule();
  
  // defining Instruction register (IR) bit segments.
  `define oper IR[31:27];
  `define drg IR[26:22];
  `define srg1 IR[21:17];
  `define mode IR[16];
  `define srg2 IR[15:11];
  `define imm_data IR[10:0];

  // defining different operations.
  `define movsgpr 5'b00000;
  `define mov     5'b00001;
  `define add     5'b00010;
  `define sub     5'b00011;
  `define mul     5'b00100;

  //define general purpose registers
  reg [15:0]GPR[31:0]; 

  //define special general purpose register for multiplication.
  reg [15:0] SGPR;

  //temp variable to store 32 bit multiplication result.
  reg [31:0] mul_temp;


  always@(*) begin
    case (`oper)
      `movsgpr: begin
        GPR[`drg]= SGPR;
      end
      `mov: begin
        if(mode)
          GPR[`drg]=`imm_data;
        else
          GPR[`drg]=`srg1;
      end
      `add: begin
        if(mode)
          GPR[`drg]=`srg1+`imm_data;
        else
          GPR[`drg]=`srg1+`srg2;
      end
      `sub: begin
        if(mode)
          GPR[`drg]=`srg1-`imm_data;
        else
          GPR[`drg]=`srg1-`srg2;
      end
      `mul: begin
        if(mode)
          mul_temp=`srg1*`imm_data;
        else
          mul_temp=`srg1*`srg2;

        SGPR=mul_temp[31:16];
        GPR[`rdrg]=mul_temp[15:0];
      end
    endcase

    
      

    
  end
  
  






  
endmodule
