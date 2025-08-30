`timescale 1ns / 1ps

module processor_tb( );

top proc ();

integer i ;
initial begin
    for (i=0;i<32;i=i+1)
        begin
            proc.GPR[i]=2 ;
        end
end

initial begin
proc.IR=0;
proc.SGPR=0;
proc.`oper= 2;
proc.`rdst=1;
proc.`mode=0;
proc.`rsrc1=3;
proc.`rsrc2=2;
#10 ;
$display("OPERATION= MUL NUM1=%0d NUM2=%0d RESULT= %0d",proc.GPR[3],proc.GPR[2],proc.GPR[1]);
$display("---------------------------------------------------------------------------------------------------------------");

end



endmodule
