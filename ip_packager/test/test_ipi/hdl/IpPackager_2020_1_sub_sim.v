///////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022 by XTools, Switzerland
///////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module IpPackager_2020_1_sub
    // Parameters
    #(
        parameter   Clk_FreqHz_g        = 100000000
    )
    // Ports
    (
        input       Clk,
        input       Rst,
        input       Uart_Rx,
        output      Uart_Tx
    );
    
    // Constant Declaration
    
    // Register Declaration
    reg UartTx_Reg;
    
    // Registered Circuits
    always @ (posedge Clk, posedge Rst)
        if (Rst)
            UartTx_Reg <= 1;
        else
            UartTx_Reg <= Uart_Rx;
            
    // Combinatorical Circuits
    //always @ *
    
    // Output Assignments
    assign Uart_Tx = UartTx_Reg;
    
endmodule
