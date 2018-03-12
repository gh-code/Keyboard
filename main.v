/**
 *  TungHai University
 *  Electrical Engineering
 *
 *  Author: Gary Huang (gh.thuee+code@gmail.com)
 *  Version: 1.0.4 (2010/01/11 updated)
 *  Licence: BSD
 *
 *  Copyright (c) 2010, hkc
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with 
 *  or without modification, are permitted provided that the 
 *  following conditions are met:
 *
 *  * Redistributions of source code must retain the above 
 *    copyright notice, this list of conditions and the 
 *    following disclaimer.
 *  * Redistributions in binary form must reproduce the 
 *    above copyright notice, this list of conditions and 
 *    the following disclaimer in the documentation and/or 
 *    other materials provided with the distribution.
 *  * Neither the name of the TungHai University nor the 
 *    names of its contributors may be used to endorse or 
 *    promote products derived from this software without 
 *    specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
 *  CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
 *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
 *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
 *  TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY 
 *  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
 *  THE POSSIBILITY OF SUCH DAMAGE.
 */

 /* 定義常數 */
`define Do  3'd1
`define Re  3'd2
`define Mi  3'd3
`define Fa  3'd4
`define Sol 3'd5
`define La  3'd6
`define Si  3'd7

/* 主模組 */
module subject(bz1, select, green, red, clock, reset, C, R);

    input   clock, reset;
    input   [3:0] C, R;
    output  bz1;
    output  [2:0] select;
    output  [7:0] green, red;
    wire    clock2;         // 除頻後的 clock
    reg     [2:0] solfa;    // 唱名

    /* KEY BOARD 8 * 8 控制 */
    always @ (C or R)
    begin
        case (C)
            4'b0001:
                case (R)
                    4'b0001: solfa <= `Sol;
                    4'b0010: solfa <= `La;
                    4'b0100: solfa <= `Si;
                    default: solfa <= 3'd0;
				endcase

            4'b0010:
                case (R)
                    4'b0001: solfa <= `Do;
                    4'b0010: solfa <= `Re;
                    4'b0100: solfa <= `Mi;
                    4'b1000: solfa <= `Fa;
                    default: solfa <= 3'd0;
                endcase

            default:
                solfa <= 3'd0;

        endcase
    end

    /* 除頻 (除 2^10 = 1024，所得的頻率為 20MHz / 1024 ~= 20kHz) */
    freqdiv #(.exp(10)) FD (clock2, clock, reset, 10'd0);

    /* 蜂鳴器發出對應唱名的聲音 */
    buzz    BZ (bz1, clock, reset, solfa);
    /* 在 8 * 8 LED 上顯示唱名 */
    display DP (select, green, red, clock2, reset, solfa);

endmodule

module display(column, green, red, clock, reset, solfa);

    input   clock, reset;
    input   [2:0] solfa;
    output  [2:0] column;
    output  [7:0] green, red;
    reg     [7:0] green0, green1, green2, green3; // 暫存每列以便送入
    reg     [7:0] green4, green5, green6, green7; // 掃描器掃出圖形
    reg     [9:0] count; // 讓圖形右移緩慢
    reg     clock2; // 一段時間打一個方波

    /* 建立對應唱名的整幅圖形並暫存，以便掃描器繪圖 */
    always @ (posedge clock)
    begin
        case (solfa)
            `Do:
                begin
                    green0 <= 8'b10000000;
                    green1 <= 8'b10111110;
                    green2 <= 8'b10111110;
                    green3 <= 8'b11000001;
                    green4 <= 8'b11111001;
                    green5 <= 8'b11110110;
                    green6 <= 8'b11110110;
                    green7 <= 8'b11111001;
                    count <= 10'b0;
                end

            `Re:
                begin
                    green0 <= 8'b10000000;
                    green1 <= 8'b10110111;
                    green2 <= 8'b10110111;
                    green3 <= 8'b11001000;
                    green4 <= 8'b11110001;
                    green5 <= 8'b11101010;
                    green6 <= 8'b11101010;
                    green7 <= 8'b11110011;
                    count <= 10'b0;
                end

            `Mi:
                begin
                    green0 <= 8'b10000000;
                    green1 <= 8'b11011111;
                    green2 <= 8'b11100111;
                    green3 <= 8'b11011111;
                    green4 <= 8'b10000000;
                    green5 <= 8'b11111111;
                    green6 <= 8'b11101000;
                    green7 <= 8'b11111111;
                    count <= 10'b0;
                end

            `Fa:
                begin
                    green0 <= 8'b10000000;
                    green1 <= 8'b10110111;
                    green2 <= 8'b10110111;
                    green3 <= 8'b10111111;
                    green4 <= 8'b11111101;
                    green5 <= 8'b11101010;
                    green6 <= 8'b11101010;
                    green7 <= 8'b11110000;
                    count <= 10'b0;
                end

            `Sol:
                begin
                    green0 <= 8'b11001110;
                    green1 <= 8'b10110110;
                    green2 <= 8'b10111001;
                    green3 <= 8'b11111001;
                    green4 <= 8'b11110110;
                    green5 <= 8'b11110110;
                    green6 <= 8'b11111001;
                    green7 <= 8'b10000000;
                    count <= 10'b0;
                end

            `La:
                begin
                    green0 <= 8'b10000000;
                    green1 <= 8'b11111110;
                    green2 <= 8'b11111110;
                    green3 <= 8'b11111110;
                    green4 <= 8'b11111101;
                    green5 <= 8'b11101010;
                    green6 <= 8'b11101010;
                    green7 <= 8'b11110000;
                    count <= 10'b0;
                end

            `Si:
                begin
                    green0 <= 8'b11001110;
                    green1 <= 8'b10110110;
                    green2 <= 8'b10110110;
                    green3 <= 8'b10111001;
                    green4 <= 8'b11111111;
                    green5 <= 8'b11111111;
                    green6 <= 8'b11101000;
                    green7 <= 8'b11111111;
                    count <= 10'b0;
                end

            default:
                begin
                    /* 例外處理，當放輸入並非唱名
                                或沒動作時，將圖案右移出 */
                    clock2 = (count == 10'b0) ? 1'b1 : 1'b0;

                    if (clock2)
                    begin
                        green7 <= green6;
                        green6 <= green5;
                        green5 <= green4;
                        green4 <= green3;
                        green3 <= green2;
                        green2 <= green1;
                        green1 <= green0;
                        green0 <= 8'b11111111;
                    end

                    count <= (reset) ? 10'b0 : count + 10'b1;
                end

        endcase
    end

    assign red = 8'b11111111; // 紅色沒用到，永遠不亮

    /* 將暫存的圖形送到掃描器繪在 8 * 8 LED */
    sweep8x8   SW (green, column, clock, reset,
                   green0, green1, green2, green3,
                   green4, green5, green6, green7);

endmodule

module sweep8x8(col, sel, clk, rst,
                col0, col1, col2, col3,
                col4, col5, col6, col7);

    input   clk, rst;
    input   [7:0] col0, col1, col2, col3;
    input   [7:0] col4, col5, col6, col7;
    output  [7:0] col;
    output  [2:0] sel;
    reg     [7:0] col;
    reg     [2:0] sel;

    always @ (posedge clk)
    begin
        sel <= (rst) ? 3'b0 : sel + 3'b1;
    end

    always @ (sel or
              col0 or col1 or col2 or col3 or
              col4 or col5 or col6 or col7)
    begin
        case (sel)
            3'd0:   col <= col0;
            3'd1:   col <= col1;
            3'd2:   col <= col2;
            3'd3:   col <= col3;
            3'd4:   col <= col4;
            3'd5:   col <= col5;
            3'd6:   col <= col6;
            3'd7:   col <= col7;
            default:
                    col <= ~8'd0;
        endcase
    end

endmodule

module buzz(buzzer, clock, reset, solfa);

    input   clock, reset;
    input   [2:0] solfa;
    output  buzzer;
    reg     [15:0] div;

    /* 記錄每個唱名的除頻半波 */
    always @ (solfa)
    begin
        case (solfa)
            `Do:    div <= 16'd38221;
            `Re:    div <= 16'd34052;
            `Mi:    div <= 16'd30336;
            `Fa:    div <= 16'd28629;
            `Sol:   div <= 16'd25509;
            `La:    div <= 16'd22727; // 20MHz / 440 / 2 - 1
            `Si:    div <= 16'd20247;
            default:
                    div <= 16'd1; // 不除頻。也可以用 reset
        endcase
    end

    freqdiv #(.exp(16)) FD (buzzer, clock, reset, div);

endmodule

module freqdiv(clk2, clk, rst, div);

    parameter exp = 20;

    input   clk, rst;
    input   [exp-1:0] div;
    output  clk2;
    reg     clk2;
    reg     [exp-1:0] cnt;

    integer i;

    always @ (posedge clk)
    begin
        if (rst)
            for (i = 0; i < exp; i = i+1)
                cnt[i] <= 1'b0;
        else
        begin
            if (div)
            begin
                if ((div != 1) && (cnt == 0))
                begin
                    clk2 <= ~clk2;
                    cnt <= div;
                end
            end
            else
                clk2 <= cnt[exp-1];

            cnt <= cnt - 1'b1;
        end
    end

endmodule
