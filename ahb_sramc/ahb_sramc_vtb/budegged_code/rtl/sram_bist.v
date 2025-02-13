//============================================================================
//  FileName    : sram_bist.v                                                 
//  Function    : 8kx8 sram which instance a bist module and dft.             
//                Memory on the chip for recoding data, and it provides       
//                with BIST and DFT functions.                                
//  Author      : zhaoql                                                      
//  Date        : 2010-8-8                                                    
//  Version     : 1.0                                                         
//----------------------------------------------------------------------------
//  Modify      : Modify the clk, when BIST or DFT not word,		          
//		            the BIST logic has no clock.			     	              
//  Data        : 2011-02-22                                                  
//============================================================================

module sram_bist(
  //input signals
  input         hclk,
  input         sram_clk,
  input         sram_rst_n,
  input         sram_csn_in,   //chip select enable 
  input         sram_wen_in,   //sram write or read enable; 0:write; 1:read
  input[12:0]   sram_addr_in, 
  input[7:0 ]   sram_wdata_in,
  input         bist_en,       // MBIST mode
	input         dft_en,        // DFT mode
  
  //output signals
  output[7:0 ]  sram_data_out, 
  output        bist_done,     // 1: test over
  output        bist_fail      // high: MBIST Fail
  );
				
  //----------------------------------------------------
  //Internal signals connected the sram with bist module 
  //when "bist_en" active high.
  //----------------------------------------------------
  wire sram_csn;
  wire sram_wen;
  wire sram_oen;
  wire [12:0] sram_a;
  wire [7:0]  sram_d;
  wire [7:0]  data_out;

  //Sram output data when "dft_en" active high.
  wire [7:0] dft_data;
  reg [7:0]  dft_data_r;
 
  wire [12:0] sram_addr;
  wire [7:0]  sram_wdata;

  //clock for bist logic, when bist is not work, clock should be 0.
  wire bist_clk;

  genvar K;
  
  //block sram input when cs is diable for low power design 
  assign sram_addr = sram_csn_in ? 0 : sram_addr_in;
  assign sram_wdata = sram_csn_in ? 0 : sram_wdata_in;

  //dft test result
  assign dft_data = (sram_d ^ sram_a[7:0]) ^ {sram_csn, sram_wen, sram_oen, sram_a[12:8]}; 

  always @(posedge hclk or negedge sram_rst_n) begin
    if(!sram_rst_n)
      dft_data_r <= 0;
    else if(dft_en)
      dft_data_r <= dft_data;
  end

  //sram data output
  assign sram_data_out = dft_en ? dft_data_r : data_out;
/*
  generate for(K = 0; K < 8; K = K+1 )
  begin :hold
    //BHDBWP7T holdQ (.Z(data_out[K]));
  end endgenerate*/

  //clock for bist logic, when bist is not work, clock should be 0.
  //CKMUX2D2BWP7T U_bist_clk_mux (.I0(1'b0), .I1(hclk), .S(bist_en), .Z(bist_clk));

  // One sram with BIST and DFT function
  RA1SH u_RA1SH(
        .Q      (data_out),
        .CLK    (sram_clk),
        .CEN    (sram_csn),
        .WEN    (sram_wen),
        .A      (sram_a),
        .D      (sram_d),
        .OEN    (sram_oen)
       );

  mbist_8kx8 u_mbist_8kx8(
        .b_clk   (bist_clk),
        .b_rst_n (sram_rst_n),
        .b_te    (bist_en),
		     //--------------------------------------------------------
		     //All the input signals will be derectly connected to
		     //the sram input when in normal operation; and when in
		     //BIST TEST mode, there are some mux in BIST module
		     //selcting all sram input signals which generated by itself:
		     //sram controll signals, sram write data, etc.
		     //--------------------------------------------------------
         .addr_fun     (sram_addr),
         .wen_fun      (sram_wen_in),
         .cen_fun      (sram_csn_in),
         .oen_fun      (1'b0),
         .data_fun     (sram_wdata),

         .ram_read_out (sram_data_out),
         .data_test    (sram_d),
         .addr_test    (sram_a),
         .wen_test     (sram_wen),
         .cen_test     (sram_csn),
         .oen_test     (sram_oen),

         .b_done       (bist_done),
         .b_fail       (bist_fail)
       );

endmodule
