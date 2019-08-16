/*时钟切换逻辑 glitch free
*时钟切换逻辑避免产生glitch的原理:先关闭当前时钟，再打开目标时钟。
*而不管关闭还是使能，都必须保证当前时钟或目标时钟的使能信号的
*跳变都分别在时钟为低电平期间进行的，防止产生时钟glitch。
*在时钟切换时就必然要经历4个阶段：
***(1)选择信号改变
***(2)在clk1为低时停掉clk1的选择 
***(3)在clk2为低时打开clk2的选择端
***(4)正常工作，完成切换。
*无缝切换需要解决两个问题:
***(1)异步切换信号的跨时钟域同步问题
***(2)同步好了的切换信号与时钟信号如何做逻辑，才能实现无毛刺
*
*输入 clka clkb 
*sel为1输出clka,为0输出clkb
*/
module clk_switch(
	input clk_a,
	input clk_b,
	input sel_clk,
	input rst_n,
	output  clk_o
);

/*若两个时钟为倍数关系*/
/***************
reg out_a_r;
reg out_b_r;

always @(negedge clk_a or negedge rst_n) begin
	if(!rst_n) begin
		out_a_r <= 'b0; 
	end
	else begin
		out_a_r <= (~out_b_r) & sel_clk;
	end 
end
always @(negedge clk_b or negedge rst_n) begin
	if(!rst_n) begin
		out_b_r <= 'b0;
	end
	else begin
		out_b_r <= (~out_a_r) & (~sel_clk) ;
	end
end
assign clk_o = (out_a_r & clk_a) | (out_b_r & clk_b);
****************/

/*若两个时钟为异步时钟关系
*D触发器需要多打一拍
*/
reg clk_a_r0;
reg clk_a_r1;
reg clk_b_r0;
reg clk_b_r1;

reg out_a_r;
reg out_b_r;

always @(negedge clk_a or negedge rst_n) begin
	if(!rst_n) begin
		clk_a_r0 <= 'b0;
		clk_a_r1 <= 'b0;
	end
	else begin
		clk_a_r0 <= (~clk_b_r1) & sel_clk;
		clk_a_r1 <= clk_a_r0;
		
//		out_a_r  <= clk_a_r1 & clk_a;
	end 
end 

always @(negedge clk_b or negedge rst_n) begin
	if(!rst_n) begin
		clk_b_r0 <= 'b0;
		clk_b_r1 <= 'b0;
	end
	else begin
		clk_b_r0 <= -(~clk_a_r1) & (~sel_clk);
		clk_b_r1 <= clk_b_r0;
		
//		out_b_r <= clk_b_r1 & clk_b;
	end 
end 

//assign clk_o = out_a_r | out_b_r;
assign clk_o = (clk_a_r1 & clk_a) | (clk_b_r1 & clk_b)  ;
endmodule