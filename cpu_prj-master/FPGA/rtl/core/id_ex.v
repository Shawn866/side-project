`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/15 14:15:46
// Design Name: 
// Module Name: id_ex
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

`include "defines.v"

// 将译码结果打一拍后向EX模块传递
module id_ex(

    input   wire                     clk               ,
    input   wire                     rst_n             ,
                                                       
    input   wire[2:0]                hold_flag_i       ,
    input   wire                     mem_rd_flag_i     ,
    
    input   wire[`INST_DATA_BUS]     ins_i             , 
    input   wire[`INST_ADDR_BUS]     ins_addr_i        ,
    input   wire[`INST_REG_DATA]     reg1_rd_data_i    , 
    input   wire[`INST_REG_DATA]     reg2_rd_data_i    ,
    input   wire[`INST_REG_ADDR]     reg_wr_addr_i     ,
    input   wire[`INST_REG_DATA]     imm_i             ,
    input   wire[`INST_REG_DATA]     csr_rd_data_i     ,
    input   wire[`INST_ADDR_BUS]     csr_rw_addr_i     ,
    input   wire[`INST_REG_DATA]     csr_zimm_i        ,    
    
    output  reg [`INST_DATA_BUS]     ins_o             ,      
    output  reg [`INST_ADDR_BUS]     ins_addr_o        ,
    output  reg [`INST_REG_DATA]     reg1_rd_data_o    , 
    output  reg [`INST_REG_DATA]     reg2_rd_data_o    ,    
    output  reg [`INST_REG_ADDR]     reg_wr_addr_o     ,
    output  reg [`INST_REG_DATA]     imm_o             ,
    output  reg [`INST_REG_DATA]     csr_rd_data_o     ,
    output  reg [`INST_ADDR_BUS]     csr_rw_addr_o     ,
    output  reg [`INST_REG_DATA]     csr_zimm_o        ,
                                                       
    output  reg                      mem_rd_rib_req_o  ,
    output  reg [`INST_ADDR_BUS]     mem_rd_addr_o       
    
    );
    
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ins_o <= `INS_NOP;
            ins_addr_o <= `RESET_ADDR;
            reg1_rd_data_o <= `ZERO_WORD;
            reg2_rd_data_o <= `ZERO_WORD;   
            reg_wr_addr_o <= `ZERO_REG_ADDR;   
            imm_o <= `ZERO_WORD;
            csr_rw_addr_o <= `ZERO_WORD;
            csr_zimm_o <= `ZERO_WORD;
            csr_rd_data_o <= `ZERO_WORD;
        end
        else if(hold_flag_i >= `HOLD_ID_EX) begin
            ins_o <= `INS_NOP;
            ins_addr_o <= `RESET_ADDR;
            reg1_rd_data_o <= `ZERO_WORD;
            reg2_rd_data_o <= `ZERO_WORD;   
            reg_wr_addr_o <= `ZERO_REG_ADDR;   
            imm_o <= `ZERO_WORD;   
            csr_rw_addr_o <= `ZERO_WORD;
            csr_zimm_o <= `ZERO_WORD;
            csr_rd_data_o <= `ZERO_WORD;
        end
        else begin
            ins_o <= ins_i;
            ins_addr_o <= ins_addr_i;
            reg1_rd_data_o <= reg1_rd_data_i;
            reg2_rd_data_o <= reg2_rd_data_i;
            reg_wr_addr_o <= reg_wr_addr_i;
            imm_o <= imm_i;
            csr_rw_addr_o <= csr_rw_addr_i;
            csr_zimm_o <= csr_zimm_i;
            csr_rd_data_o <= csr_rd_data_i;
        end
    end
    
    always @ (*) begin
        if(mem_rd_flag_i == 1'b1) begin
            mem_rd_rib_req_o = 1'b1;
            mem_rd_addr_o = $signed(reg1_rd_data_i) + $signed(imm_i);
            //执行了两个操作数的符号扩展和它们的加法操作，计算出用于内存读操作的地址
        end
        else begin
            mem_rd_rib_req_o = 1'b0;
            mem_rd_addr_o = `ZERO_WORD;
        end
    end
    
endmodule
