//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 	2018 IC CONTEST
// 	Project	:	Huffman Coding
// 	Author	: 	Zheng-Wei Hong (td2100106@gmail.com)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 	File Name	:	huffman.v
// 	Module Name	:	huffman
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module huffman(clk, reset, gray_valid, gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg code_valid;
output reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output reg [7:0] M1, M2, M3, M4, M5, M6;

reg			in_valid;
reg			sort_flag;
reg			sort_index;
reg			comb_flag;

reg [2:0]   read_cnt;
reg	[2:0]	comb_cnt;
reg	[2:0]	sort_cnt;
reg	[2:0]	spilt_cnt;
reg	[6:0]	num_cnt;

reg	[6:0]	A1_cnt;
reg	[6:0]	A2_cnt;
reg	[6:0]	A3_cnt;
reg	[6:0]	A4_cnt;
reg	[6:0]	A5_cnt;
reg	[6:0]	A6_cnt;

reg	[7:0]	Queue		[0:5];	
reg	[7:0]	Out_Queue	[0:5];
reg	[2:0]	R_Queue		[0:5];
reg	[7:0]	C_Queue		[0:9];

reg	[2:0]	current_state;
reg	[2:0]	next_state;

integer i;

parameter	IDLE	=	3'd0;
parameter	READ	=	3'd1;
parameter	SORT 	=	3'd2;
parameter	COMB 	=	3'd3;
parameter	SPLIT 	=	3'd4;
parameter	FINISH 	=	3'd5; 

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//FSM
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				current_state <= IDLE;
			end
		else 
			begin
				current_state <= next_state;
			end
	end

always @(*) 
	begin
		case(current_state)
				IDLE:	next_state = (gray_valid) ? READ : IDLE;
				READ:	next_state = ( (num_cnt == 7'd101) ) ? SORT : READ;
				SORT:	next_state = (sort_cnt == 3'd4) ? COMB : SORT;
				COMB:	next_state = (comb_cnt == 3'd3) ? SPLIT : /*(comb_cnt > 3'd0) ?*/ SORT/* : COMB*/;
				SPLIT:	next_state = (spilt_cnt == 3'd6) ? FINISH : SPLIT;
				FINISH:	next_state = FINISH;
		default:
			begin
				next_state = IDLE;
			end
		endcase
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//NUM_CNT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				num_cnt <= 7'd0;
			end
		else 
			begin
				case(current_state)
					IDLE:
						begin
							num_cnt <= (next_state == READ) ? num_cnt + 7'd1 : num_cnt;
						end
					READ:
						begin
							num_cnt <= (num_cnt == 7'd101) ? num_cnt : num_cnt + 7'd1;
						end
				default:
					begin
						num_cnt <= num_cnt;
					end
				endcase
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//A_CNT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				A1_cnt <= 7'd0;
				A2_cnt <= 7'd0;
				A3_cnt <= 7'd0;
				A4_cnt <= 7'd0;
				A5_cnt <= 7'd0;
				A6_cnt <= 7'd0;
			end
		else 
			begin
				case(current_state)
					IDLE:
						begin
							A1_cnt <= ( (gray_data == 8'd1) && (gray_valid) )  ? A1_cnt + 7'd1 : A1_cnt;
							A2_cnt <= ( (gray_data == 8'd2) && (gray_valid) )  ? A2_cnt + 7'd1 : A2_cnt;
							A3_cnt <= ( (gray_data == 8'd3) && (gray_valid) )  ? A3_cnt + 7'd1 : A3_cnt;
							A4_cnt <= ( (gray_data == 8'd4) && (gray_valid) )  ? A4_cnt + 7'd1 : A4_cnt;
							A5_cnt <= ( (gray_data == 8'd5) && (gray_valid) )  ? A5_cnt + 7'd1 : A5_cnt;
							A6_cnt <= ( (gray_data == 8'd6) && (gray_valid) )  ? A6_cnt + 7'd1 : A6_cnt;
						end
					READ:
						begin
							A1_cnt <= (gray_data == 8'd1) ? A1_cnt + 7'd1 : A1_cnt;
							A2_cnt <= (gray_data == 8'd2) ?	A2_cnt + 7'd1 : A2_cnt;
							A3_cnt <= (gray_data == 8'd3) ?	A3_cnt + 7'd1 : A3_cnt;
							A4_cnt <= (gray_data == 8'd4) ?	A4_cnt + 7'd1 : A4_cnt;
							A5_cnt <= (gray_data == 8'd5) ?	A5_cnt + 7'd1 : A5_cnt;
							A6_cnt <= (gray_data == 8'd6) ?	A6_cnt + 7'd1 : A6_cnt;
						end
				default:
					begin
						A1_cnt <= A1_cnt;
						A2_cnt <= A2_cnt;
						A3_cnt <= A3_cnt;
						A4_cnt <= A4_cnt;
						A5_cnt <= A5_cnt;
						A6_cnt <= A6_cnt;
					end
				endcase
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//CNT1~CNT6
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				CNT1 <= 8'd0;
				CNT2 <= 8'd0;
				CNT3 <= 8'd0;
				CNT4 <= 8'd0;
				CNT5 <= 8'd0;
				CNT6 <= 8'd0;
			end
		else
			begin
				case(current_state)
					READ:
						begin
							CNT1 <= A1_cnt;
							CNT2 <= A2_cnt;
							CNT3 <= A3_cnt;
							CNT4 <= A4_cnt;
							CNT5 <= A5_cnt;
							CNT6 <= A6_cnt;								
						end
					SORT:
						begin
							CNT1 <= CNT1;
							CNT2 <= CNT2;
							CNT3 <= CNT3;
							CNT4 <= CNT4;
							CNT5 <= CNT5;
							CNT6 <= CNT6;
						end
				default:
						begin
							CNT1 <= CNT1;
							CNT2 <= CNT2;
							CNT3 <= CNT3;
							CNT4 <= CNT4;
							CNT5 <= CNT5;
							CNT6 <= CNT6;									
						end
				endcase							
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//SORT_INDEX
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always@(posedge clk or posedge reset)
	begin
        if(reset)
        	begin
        		sort_index <= 0;
        	end
        else
        	begin
        		sort_index <= ~sort_index;
        	end
     end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//COMB_FLAG
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				comb_flag <= 1'd0;
			end
		else
			begin
				comb_flag <= ( C_Queue[5] == 8'd0 ) ? 1'd0 : 1'd1;																	
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//IN_VALID
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always@(posedge clk or posedge reset)
	begin
        if(reset)
        	begin
        		in_valid <= 1'd0;
        	end
        else
        	begin
        		case(current_state)
        			READ:
        				begin
        					in_valid <= (next_state == SORT) ? 1'd1 : 1'd0;
        				end
        			SORT:
        				begin
        					in_valid <= in_valid;
        				end
        			COMB:
        				begin
        				 	in_valid <= (next_state == SPLIT) ? 1'd0 : 1'd1;
        				 end 
        		default:
        			begin
        				in_valid <= in_valid;
        			end
        		endcase
        	end
       end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//SORT_CNT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
		    begin
				sort_cnt <= 3'd0;
			end
		else 
			begin
				case(current_state)
					SORT:
						begin
							sort_cnt <= (sort_cnt == 3'd4) ? sort_cnt : sort_cnt + 3'd1;
						end
					COMB:
						begin
							sort_cnt <= (next_state == SORT) ? 3'd0 : sort_cnt;
						end
				default:
					begin
						sort_cnt <= sort_cnt;
					end
				endcase
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//READ_CNT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				read_cnt <= 3'd0;
			end
		else
			begin
				case(current_state)
					IDLE:
						begin
							read_cnt <= (next_state == SORT) ? read_cnt + 3'd1 : read_cnt;									
						end
					READ:
						begin
							read_cnt <= (read_cnt == 3'd5) ? read_cnt : read_cnt + 3'd1;																	
						end
				default:
						begin
							read_cnt <= read_cnt;																			
						end						
				endcase											
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//R_QUEUE
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				R_Queue[0] <= 3'd1 - 3'd1;
				R_Queue[1] <= 3'd2 - 3'd1;
				R_Queue[2] <= 3'd3 - 3'd1;
				R_Queue[3] <= 3'd4 - 3'd1;
				R_Queue[4] <= 3'd5 - 3'd1;
				R_Queue[5] <= 3'd6 - 3'd1;
			end
		else
			begin
				case(current_state)
					SORT:
						begin
							if( (sort_index == 1'd0) && (in_valid) )
								begin
    								for(i=0 ; i<6 ; i=i+2)
    									begin
    										R_Queue[i] <= ( (Queue[i] > Queue[i+1])	||	( (Queue[i] == Queue[i+1]) && (R_Queue[i] < R_Queue[i+1]) ) ) ? R_Queue[i+1] : R_Queue[i]; 
    										R_Queue[i+1] <= ( (Queue[i] > Queue[i+1])	||	( (Queue[i] == Queue[i+1]) && (R_Queue[i] < R_Queue[i+1]) ) ) ? R_Queue[i] : R_Queue[i+1];
    									end
								end
							else if( (sort_index == 1'd1) && (in_valid) )
								begin
    								for(i=1 ; i<4 ; i=i+2)
    									begin
    										R_Queue[i] <= ( (Queue[i] > Queue[i+1]) || ( (Queue[i] == Queue[i+1]) && (R_Queue[i] < R_Queue[i+1]) ) ) ? R_Queue[i+1] : R_Queue[i]; 
    										R_Queue[i+1] <= ( (Queue[i] > Queue[i+1]) || ( (Queue[i] == Queue[i+1]) && (R_Queue[i] < R_Queue[i+1]) ) ) ? R_Queue[i] : R_Queue[i+1];
    									end
 								end
						end
				default:
					begin
						R_Queue[0] <= R_Queue[0];
						R_Queue[1] <= R_Queue[1];
						R_Queue[2] <= R_Queue[2];
						R_Queue[3] <= R_Queue[3];
						R_Queue[4] <= R_Queue[4];
						R_Queue[5] <= R_Queue[5];
					end	
				endcase		
			end
	end


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//QUEUE
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				for(i=0 ; i<6 ; i=i+1)
					begin
						Queue[i] <= 8'd0;
					end
			end
		else 
			begin
				case(current_state)
					READ:
						begin
							Queue[0] <= (next_state == SORT) ? CNT1 : Queue[0];
							Queue[1] <= (next_state == SORT) ? CNT2 : Queue[1];
							Queue[2] <= (next_state == SORT) ? CNT3 : Queue[2];
							Queue[3] <= (next_state == SORT) ? CNT4 : Queue[3];
							Queue[4] <= (next_state == SORT) ? CNT5 : Queue[4];
							Queue[5] <= (next_state == SORT) ? CNT6 : Queue[5];
						end
					SORT:
						begin
							if( (sort_index == 1'd0) && (in_valid) )
								begin
    								for(i=0 ; i<6 ; i=i+2)
    									begin
    										Queue[i] <= ( (Queue[i] > Queue[i+1])	||	( (Queue[i] == Queue[i+1]) && (i < i+1) ) ) ? Queue[i+1] : Queue[i]; 
    										Queue[i+1] <= ( (Queue[i] > Queue[i+1])	||	( (Queue[i] == Queue[i+1]) && (i < i+1) ) ) ? Queue[i] : Queue[i+1];
    									end
								end
							else if( (sort_index == 1'd1) && (in_valid) )
								begin
    								for(i=1 ; i<4 ; i=i+2)
    									begin
    										Queue[i] <= ( (Queue[i] > Queue[i+1])	||	( (Queue[i] == Queue[i+1]) && (i < i+1) ) ) ? Queue[i+1] : Queue[i]; 
    										Queue[i+1] <= ( (Queue[i] > Queue[i+1])	||	( (Queue[i] == Queue[i+1]) && (i < i+1) ) ) ? Queue[i] : Queue[i+1];
    									end
 								end
						end
					COMB:
						begin
							
						end
				default:
					begin
						for(i=0 ; i<6 ; i=i+1)
							begin
								Queue[i] <= Queue[i];
							end	
					end
				endcase
			end

	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//COMBINATION_CNT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				comb_cnt <= 3'd0;
			end
		else 
			begin
				case(current_state)
					COMB:
						begin
							comb_cnt <= (comb_cnt == 3'd3) ? comb_cnt : comb_cnt + 3'd1;
						end
				default:
					begin
						comb_cnt <= comb_cnt;
					end
				endcase
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//C_QUEUE
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				for(i=0 ; i<10 ; i=i+1)
					begin
						C_Queue[i] <= 8'd0;
					end																
			end
		else
			begin
				case(current_state)
					READ:
						begin
							C_Queue[0] <= (next_state == SORT) ? CNT1 : C_Queue[0];
							C_Queue[1] <= (next_state == SORT) ? CNT2 : C_Queue[1];
							C_Queue[2] <= (next_state == SORT) ? CNT3 : C_Queue[2];
							C_Queue[3] <= (next_state == SORT) ? CNT4 : C_Queue[3];
							C_Queue[4] <= (next_state == SORT) ? CNT5 : C_Queue[4];
							C_Queue[5] <= (next_state == SORT) ? CNT6 : C_Queue[5];
							C_Queue[6] <=  C_Queue[6];
							C_Queue[7] <=  C_Queue[7];
							C_Queue[8] <=  C_Queue[8];
							C_Queue[9] <=  C_Queue[9];
						end
					SORT:
						begin
							if( (sort_index == 1'd0) && (in_valid) )
								begin
    								for(i=0 ; i<6 ; i=i+2)
    									begin
    										C_Queue[i] <= ( C_Queue[i] > C_Queue[i+1] ) ? C_Queue[i+1] : C_Queue[i]; 
    										C_Queue[i+1] <= ( C_Queue[i] > C_Queue[i+1] ) ? C_Queue[i] : C_Queue[i+1];
    									end
								end
							else if( (sort_index == 1'd1) && (in_valid) )
								begin
    								for(i=1 ; i<4 ; i=i+2)
    									begin
    										C_Queue[i] <= ( C_Queue[i] > C_Queue[i+1] ) ? C_Queue[i+1] : C_Queue[i]; 
    										C_Queue[i+1] <= ( C_Queue[i] > C_Queue[i+1] ) ? C_Queue[i] : C_Queue[i+1];
    									end
 								end
						end
					COMB:
						begin
							case(comb_cnt)
								0:
									begin
										C_Queue[0] <= C_Queue[comb_cnt] + C_Queue[comb_cnt + 3'd1];
										C_Queue[6] <= C_Queue[comb_cnt] + C_Queue[comb_cnt + 3'd1];
									end
								1:
									begin
										C_Queue[1] <= C_Queue[comb_cnt] + C_Queue[comb_cnt + 3'd1];
										C_Queue[7] <= C_Queue[comb_cnt] + C_Queue[comb_cnt + 3'd1];
									end
								2:
									begin
										C_Queue[1] <= C_Queue[comb_cnt] + C_Queue[comb_cnt + 3'd1];
										C_Queue[8] <= C_Queue[comb_cnt] + C_Queue[comb_cnt + 3'd1];
									end
								3:
									begin
										C_Queue[5] <= C_Queue[comb_cnt] + C_Queue[comb_cnt + 3'd1];
										C_Queue[9] <= C_Queue[comb_cnt] + C_Queue[comb_cnt + 3'd1];
									end
							default:
								begin
									C_Queue[comb_cnt] <= C_Queue[comb_cnt] + C_Queue[comb_cnt + 3'd1];				
								end
							endcase
						end
					default:
						begin
							for(i=0 ; i<5 ; i=i+1)
								begin
									C_Queue[i] <= C_Queue[i];
								end			
						end
					endcase
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//SPILT_CNT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				spilt_cnt <= 3'd0;
			end
		else
			begin
				case(current_state)
					SPLIT:
						begin
							spilt_cnt <= (spilt_cnt == 3'd6) ? spilt_cnt : spilt_cnt + 3'd1;										
						end
				default:
					begin
						spilt_cnt <= spilt_cnt;									 	
					end
				endcase									 	
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//OUT_QUEUE
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				for(i=0 ; i<6 ; i=i+1)
					begin
						Out_Queue[i] <= 8'd0;		
					end		
			end
		else
			begin
				case(current_state)
					SPLIT:
						begin
							case(spilt_cnt) 
								0:
									begin
										Out_Queue[0][0] <= (Queue[5] < C_Queue[9]) ? 1'd1 : (Queue[5] == C_Queue[9]) ? 1'd0 : 1'd0; //4
										Out_Queue[1][1] <= (Queue[5] < C_Queue[9]) ? 1'd0 : (Queue[5] == C_Queue[9]) ? 1'd1 : 1'd1; //6
										Out_Queue[2][2] <= (Queue[5] < C_Queue[9]) ? 1'd0 : (Queue[5] == C_Queue[9]) ? 1'd1 : 1'd1; //5
										Out_Queue[3][3] <= (Queue[5] < C_Queue[9]) ? 1'd0 : (Queue[5] == C_Queue[9]) ? 1'd1 : 1'd1; //2
										Out_Queue[4][4] <= (Queue[5] < C_Queue[9]) ? 1'd0 : (Queue[5] == C_Queue[9]) ? 1'd1 : 1'd1; //1
										Out_Queue[5][4] <= (Queue[5] < C_Queue[9]) ? 1'd0 : (Queue[5] == C_Queue[9]) ? 1'd1 : 1'd1; //3
									end
								1:
									begin
										//HC1[1] <= (Queue[4] < C_Queue[3]) ? 1'd0 : (Queue[4] == C_Queue[3]) ? 1'd1 : 1'd1;
										Out_Queue[1][0] <= (Queue[4] < C_Queue[8] && (Queue[4] + C_Queue[8] == C_Queue[9])) ? 1'd1 : (Queue[4] == C_Queue[3]) ? 1'd0 : 1'd0;
										Out_Queue[2][1] <= (Queue[4] < C_Queue[8] && (Queue[4] + C_Queue[8] == C_Queue[9])) ? 1'd0 : (Queue[4] == C_Queue[3]) ? 1'd1 : 1'd1;
										Out_Queue[3][2] <= (Queue[4] < C_Queue[8] && (Queue[4] + C_Queue[8] == C_Queue[9])) ? 1'd0 : (Queue[4] == C_Queue[3]) ? 1'd1 : 1'd1;
										Out_Queue[4][3] <= (Queue[4] < C_Queue[8] && (Queue[4] + C_Queue[8] == C_Queue[9])) ? 1'd0 : (Queue[4] == C_Queue[3]) ? 1'd1 : 1'd1;
										Out_Queue[5][3] <= (Queue[4] < C_Queue[8] && (Queue[4] + C_Queue[8] == C_Queue[9])) ? 1'd0 : (Queue[4] == C_Queue[3]) ? 1'd1 : 1'd1;
									end
								2:	begin
										//HC1[2] <= (Queue[3] < C_Queue[2]) ? 1'd0 : (Queue[3] == C_Queue[2]) ? 1'd1 : 1'd1;
										//HC2[2] <= (Queue[3] < C_Queue[2]) ? 1'd0 : (Queue[3] == C_Queue[2]) ? 1'd1 : 1'd1;
										if( (Queue[3] + C_Queue[7] == C_Queue[8]) )
											begin
												Out_Queue[2][0] <= (Queue[3] < C_Queue[7] && (Queue[3] + C_Queue[7] == C_Queue[8])) ? 1'd1 : (Queue[3] == C_Queue[2]) ? 1'd0 : 1'd0;
												Out_Queue[3][1] <= (Queue[3] < C_Queue[7] && (Queue[3] + C_Queue[7] == C_Queue[8])) ? 1'd0 : (Queue[3] == C_Queue[2]) ? 1'd1 : 1'd0;
												Out_Queue[4][2] <= (Queue[3] < C_Queue[7] && (Queue[3] + C_Queue[7] == C_Queue[8])) ? 1'd0 : (Queue[3] == C_Queue[2]) ? 1'd1 : 1'd1;
												Out_Queue[5][2] <= (Queue[3] < C_Queue[7] && (Queue[3] + C_Queue[7] == C_Queue[8])) ? 1'd0 : (Queue[3] == C_Queue[2]) ? 1'd1 : 1'd1;
											end
										else
											begin
												//Out_Queue[2][0] <= (Queue[3] < C_Queue[7] && (Queue[3] + C_Queue[2] == C_Queue[3])) ? 1'd1 : (Queue[3] == C_Queue[2]) ? 1'd0 : 1'd0;
												Out_Queue[2][3] <= Out_Queue[2][2]; 
												Out_Queue[2][2] <= Out_Queue[2][1];
												Out_Queue[2][1] <= (Queue[3] < C_Queue[7] && (Queue[3] + C_Queue[7] == C_Queue[8])) ? 1'd1 : (Queue[3] == C_Queue[2]) ? 1'd0 : 1'd0;
												Out_Queue[3][1] <= (Queue[3] < C_Queue[7] && (Queue[3] + C_Queue[7] == C_Queue[8])) ? 1'd0 : (Queue[3] == C_Queue[2]) ? 1'd1 : 1'd0;
												Out_Queue[4][2] <= (Queue[3] < C_Queue[7] && (Queue[3] + C_Queue[7] == C_Queue[8])) ? 1'd0 : (Queue[3] == C_Queue[2]) ? 1'd1 : 1'd1;
												Out_Queue[5][2] <= (Queue[3] < C_Queue[7] && (Queue[3] + C_Queue[7] == C_Queue[8])) ? 1'd0 : (Queue[3] == C_Queue[2]) ? 1'd1 : 1'd1;																	
											end
									end
								3:	begin
										//HC1[3] <= (Queue[2] < C_Queue[1]) ? 1'd0 : (Queue[2] == C_Queue[1]) ? 1'd1 : 1'd1;
										//HC2[3] <= (Queue[2] < C_Queue[1]) ? 1'd0 : (Queue[2] == C_Queue[1]) ? 1'd1 : 1'd1;
										//HC3[3] <= (Queue[2] < C_Queue[1]) ? 1'd0 : (Queue[2] == C_Queue[1]) ? 1'd1 : 1'd1;
										if( (Queue[2] + C_Queue[6] == C_Queue[7]) )
											begin
												Out_Queue[3][0] <= (Queue[2] < C_Queue[6] && (Queue[2] + C_Queue[6] == C_Queue[7])) ? 1'd1 : (Queue[2] == C_Queue[1]) ? 1'd0 : 1'd0;
												Out_Queue[4][1] <= (Queue[2] < C_Queue[6] && (Queue[2] + C_Queue[6] == C_Queue[7])) ? 1'd0 : (Queue[2] == C_Queue[1]) ? 1'd1 : 1'd1;
												Out_Queue[5][1] <= (Queue[2] < C_Queue[6] && (Queue[2] + C_Queue[6] == C_Queue[7])) ? 1'd0 : (Queue[2] == C_Queue[1]) ? 1'd1 : 1'd1;
											end
										else
											begin
												Out_Queue[2][0] <= (Queue[2] < C_Queue[6] && (Queue[2] + C_Queue[6] == C_Queue[7])) ? 1'd0 : (Queue[2] == C_Queue[1]) ? 1'd0 : 1'd0;
												Out_Queue[3][0] <= (Queue[2] < C_Queue[6] && (Queue[2] + C_Queue[6] == C_Queue[7])) ? 1'd1 : (Queue[2] == C_Queue[1]) ? 1'd0 : 1'd1;
												Out_Queue[4][1] <= (Queue[2] < C_Queue[6] && (Queue[2] + C_Queue[6] == C_Queue[7])) ? 1'd0 : (Queue[2] == C_Queue[1]) ? 1'd1 : 1'd0;
												Out_Queue[5][1] <= (Queue[2] < C_Queue[6] && (Queue[2] + C_Queue[6] == C_Queue[7])) ? 1'd0 : (Queue[2] == C_Queue[1]) ? 1'd1 : 1'd1;																
											end

									end
								4:	begin
										//HC1[4] <= (Queue[1] < C_Queue[0]) ? 1'd0 : (Queue[1] == C_Queue[0]) ? 1'd1 : 1'd1;
										//HC2[4] <= (Queue[1] < C_Queue[0]) ? 1'd0 : (Queue[1] == C_Queue[0]) ? 1'd1 : 1'd1;
										//HC3[4] <= (Queue[1] < C_Queue[0]) ? 1'd0 : (Queue[1] == C_Queue[0]) ? 1'd1 : 1'd1;
										//HC4[4] <= (Queue[1] < C_Queue[0]) ? 1'd0 : (Queue[1] == C_Queue[0]) ? 1'd1 : 1'd1;
										if((Queue[2] + C_Queue[6] == C_Queue[7]))
											begin
												Out_Queue[4][0] <= (C_Queue[1] < C_Queue[0] ) ? 1'd1 : (Queue[1] == C_Queue[0]) ? 1'd0 : (Queue[2] == C_Queue[1]) ? 1'd0 : 1'd0;
												Out_Queue[5][0] <= (C_Queue[1] < C_Queue[0] ) ? 1'd0 : (Queue[1] == C_Queue[0]) ? 1'd1 : (Queue[2] == C_Queue[1]) ? 1'd1 : 1'd0;
											end
										else
											begin
												Out_Queue[4][0] <= Out_Queue[4][1];
												Out_Queue[4][1] <= Out_Queue[4][2];
												Out_Queue[4][2] <= Out_Queue[4][3];
												Out_Queue[4][3] <= Out_Queue[4][4];

												Out_Queue[5][0] <= Out_Queue[5][1];
												Out_Queue[5][1] <= Out_Queue[5][2];
												Out_Queue[5][2] <= Out_Queue[5][3];
												Out_Queue[5][3] <= Out_Queue[5][4];
																													
											end
									end
							default:
								begin
									Out_Queue[0] <= Out_Queue[0];
									Out_Queue[1] <= Out_Queue[1];
									Out_Queue[2] <= Out_Queue[2];
									Out_Queue[3] <= Out_Queue[3];
									Out_Queue[4] <= Out_Queue[4];
									Out_Queue[5] <= Out_Queue[5];									
								end
							endcase					
						end
				default:
					begin
						Out_Queue[0] <= Out_Queue[0];
						Out_Queue[1] <= Out_Queue[1];
						Out_Queue[2] <= Out_Queue[2];
						Out_Queue[3] <= Out_Queue[3];
						Out_Queue[4] <= Out_Queue[4];
						Out_Queue[5] <= Out_Queue[5];		
					end
				endcase

			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//HC1~HC6
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				HC1 <= 8'd0;
				HC2 <= 8'd0;
				HC3 <= 8'd0;
				HC4 <= 8'd0;
				HC5 <= 8'd0;
				HC6 <= 8'd0;			
			end
		else
			begin
				case(current_state)
					SPLIT:
						begin
							case(R_Queue[3'd6 - spilt_cnt])
								0:	HC1 <= Out_Queue[spilt_cnt - 3'd1];
								1:	HC2 <= Out_Queue[spilt_cnt - 3'd1];
								2:	HC3 <= Out_Queue[spilt_cnt - 3'd1];
								3:	HC4 <= Out_Queue[spilt_cnt - 3'd1];
								4:	HC5 <= Out_Queue[spilt_cnt - 3'd1];
								5:	HC6 <= Out_Queue[spilt_cnt - 3'd1];
							default:
								begin
									HC1 <= HC1;
									HC2 <= HC2;
									HC3 <= HC3;
									HC4 <= HC4;
									HC5 <= HC5;
									HC6 <= HC6;
								end
							endcase			
						end
				default:
					begin
						HC1 <= HC1;
						HC2 <= HC2;
						HC3 <= HC3;
						HC4 <= HC4;
						HC5 <= HC5;
						HC6 <= HC6;			
					end
				endcase
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//M1~M6
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				M1 <= 8'd0;
				M2 <= 8'd0;
				M3 <= 8'd0;
				M4 <= 8'd0;
				M5 <= 8'd0;
				M6 <= 8'd0;
			end
		else
			begin
				case(current_state)
					SPLIT:
						begin
							case(R_Queue[3'd6 - spilt_cnt])
								0: M1 <= (spilt_cnt > 3'd4 && ((Queue[2] + C_Queue[6] == C_Queue[7])) ) ? 8'd31 : ((Queue[2] + C_Queue[6] != C_Queue[7]) && (spilt_cnt > 3'd2)) ? 8'd15 : 2**(spilt_cnt) - 3'd1;
								1: M2 <= (spilt_cnt > 3'd4 && ((Queue[2] + C_Queue[6] == C_Queue[7])) ) ? 8'd31 : ((Queue[2] + C_Queue[6] != C_Queue[7]) && (spilt_cnt > 3'd2)) ? 8'd15 : 2**(spilt_cnt) - 3'd1;
								2: M3 <= (spilt_cnt > 3'd4 && ((Queue[2] + C_Queue[6] == C_Queue[7])) ) ? 8'd31 : ((Queue[2] + C_Queue[6] != C_Queue[7]) && (spilt_cnt > 3'd2)) ? 8'd15 : 2**(spilt_cnt) - 3'd1;
								3: M4 <= (spilt_cnt > 3'd4 && ((Queue[2] + C_Queue[6] == C_Queue[7])) ) ? 8'd31 : ((Queue[2] + C_Queue[6] != C_Queue[7]) && (spilt_cnt > 3'd2)) ? 8'd15 : 2**(spilt_cnt) - 3'd1;
								4: M5 <= (spilt_cnt > 3'd4 && ((Queue[2] + C_Queue[6] == C_Queue[7])) ) ? 8'd31 : ((Queue[2] + C_Queue[6] != C_Queue[7]) && (spilt_cnt > 3'd2)) ? 8'd15 : 2**(spilt_cnt) - 3'd1;
								5: M6 <= (spilt_cnt > 3'd4 && ((Queue[2] + C_Queue[6] == C_Queue[7])) ) ? 8'd31 : ((Queue[2] + C_Queue[6] != C_Queue[7]) && (spilt_cnt > 3'd2)) ? 8'd15 : 2**(spilt_cnt) - 3'd1;
							default:
								begin
									M1 <= M1;
									M2 <= M2;
									M3 <= M3;
									M4 <= M4;
									M5 <= M5;
									M6 <= M6;
								end
							endcase
						end
				default:
						begin
							M1 <= M1;
							M2 <= M2;
							M3 <= M3;
							M4 <= M4;
							M5 <= M5;
							M6 <= M6;																				
						end
				endcase															
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//CNT_VALID
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				CNT_valid <= 1'd0;
			end
		else
			begin
				case(current_state)
					READ:	CNT_valid <= (next_state == SORT) ? 1'd1 : 1'd0;
					SORT:	CNT_valid <= 1'd0; 
				default:
					begin
						CNT_valid <= CNT_valid;			
					end
				endcase
			end
	end

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//CODE_VALID
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

always @(posedge clk or posedge reset) 
	begin
		if(reset)
			begin
				code_valid <= 1'd0;
			end
		else
			begin
				case(current_state)
					SPLIT:	code_valid <= (next_state == FINISH) ? 1'd1 : 1'd0;
					FINISH:	code_valid <= 1'd0;
				default:
					begin
						code_valid <= code_valid;
					end
				endcase
			end
	end

endmodule