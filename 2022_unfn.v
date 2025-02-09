module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid);

parameter IDLE = 3'd0, 
          CAL = 3'd1, 
          CHECK = 3'd2,
          FIND0 = 3'd3,
          FIND1 = 3'd4, 
          SWAP0 = 3'd5,
          SWAP1 = 3'd6,
          FINISH = 3'd7;

reg [2:0] cst, nst;
reg [9:0] currentcost;
reg [2:0] seq [7:0];

//w,j
reg [2:0] worker;
reg cal_fn;
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        worker <= 3'd0;
    end
    else if (cst == CAL) begin
            W <= worker;
            J <= seq[worker];
            worker <= worker + 1;
    end
    else begin
        worker <= 3'd0;
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        cal_fn <= 1'b0;
    end
    else if (W == 3'd6) begin
        cal_fn <= 1'b1;
    end
    else cal_fn <= 1'b0;
end

always @(negedge CLK or posedge RST) begin
    if (RST) begin
        currentcost <= 10'd1023;
    end
    else if (nst == CAL) begin
        currentcost <= currentcost + Cost;
    end
end

always @(posedge CLK or negedge RST) begin
    if (RST) begin
        cst <= IDLE;
    end
    else cst <= nst;
end

always @(*) begin
    case (cst)
        IDLE: nst = CAL;
        CAL: begin
            if (cal_fn) begin
                nst = CHECK;
            end
            else nst = CAL;
        end 
        default: nst = IDLE;
    endcase
end

endmodule
