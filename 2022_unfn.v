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
reg cal_fn;
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        W <= 3'd0;
        J <= 3'd0;
    end
    else if (cst == CAL) begin
            W <= W + 1'd1;
            J <= seq[W + 1'd1];
    end
    else begin
        W <= 3'd0;
        J <= seq[0];
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
        currentcost <= 10'd0;
    end
    else if (cst == CAL) begin
        currentcost <= currentcost + Cost;
    end
end

//CHECK
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        MinCost <= 10'd1023;
        MatchCount <= 4'd1;
    end
    else if (nst == CHECK) begin
        if (currentcost < MinCost) begin
            MinCost <= currentcost;
            MatchCount <= 4'd1;
        end
        else if (currentcost == MinCost) begin
            MatchCount <= MatchCount + 4'd1;
        end
        currentcost <= 10'd0;
    end
end

//FIND change spot
reg [2:0] n;
reg [2:0] m;
reg [2:0] change_spot;
reg FIND0_fn;
reg finish;
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        n <= 3'd7;
        change_spot <= 3'd0;
        FIND0_fn <= 1'b0;
    end
    else if (nst == FIND0) begin
        if (seq[n] > seq[n-3'd1]) begin
            change_spot <= n - 3'd1;
            m <= n;
            FIND0_fn <= 1'b1;
        end
        else n <= n - 3'd1;
    end
    else begin
        FIND0_fn <= 1'b0;
        n <= 3'd7;
    end
end

//FIND smallest num that bigger than change spot
reg [2:0] min;
reg [2:0] min_spot;
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        m <= 3'd0;
        min <= 3'd7;
        min_spot <= 3'd7;
    end
    else if(cst == FIND1) begin
        if (seq[m] > seq[change_spot] && seq[m] <= min) begin
            min <= seq[m];
            min_spot <= m;
        end
        else m <= m + 3'd1;
    end
    else begin
        min <= 3'd7;
    end
end

//SWAP0
always @(posedge CLK) begin
    if (nst == SWAP1) begin
        seq[change_spot] <= seq[min_spot];
        seq[min_spot] <= seq[change_spot];
    end
end

//swap1
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        seq[0] <= 3'd0;
        seq[1] <= 3'd1;
        seq[2] <= 3'd2;
        seq[3] <= 3'd3;
        seq[4] <= 3'd4;
        seq[5] <= 3'd5;
        seq[6] <= 3'd6;
        seq[7] <= 3'd7;
    end
    else begin
        if (cst == SWAP1) begin
            case (change_spot)
                3'd5: begin
                    seq[6] <= seq[7];
                    seq[7] <= seq[6];
                end
                3'd4: begin
                    seq[5] <= seq[7];
                    seq[7] <= seq[5];
                end
                3'd3: begin
                    seq[4] <= seq[7];
                    seq[5] <= seq[6];
                    seq[6] <= seq[5];
                    seq[7] <= seq[4];
                end
                3'd2: begin
                    seq[3] <= seq[7];
                    seq[4] <= seq[6];
                    seq[6] <= seq[4];
                    seq[7] <= seq[3];
                end
                3'd1: begin
                    seq[2] <= seq[7];
                    seq[3] <= seq[6];
                    seq[4] <= seq[5]; 
                    seq[5] <= seq[4];
                    seq[6] <= seq[3];
                    seq[7] <= seq[2];
                end
                3'd0: begin
                    seq[1] <= seq[7];
                    seq[2] <= seq[6];
                    seq[3] <= seq[5];
                    seq[5] <= seq[3];
                    seq[6] <= seq[2];
                    seq[7] <= seq[1];
                end
            endcase
        end
    end
end

//finish
always @(posedge CLK or posedge RST) begin
    if(RST) begin
        finish <= 1'b0;
    end
    else if (n == 3'd0) begin
            finish <= 1'b1;
        end
    else finish <= 1'b0;
end

always @(posedge CLK) begin
    if (cst == FINISH) begin
        Valid <= 1'b1;
    end
    else Valid <= 1'b0;
end

always @(posedge CLK or posedge RST) begin
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
        CHECK: nst = FIND0;
        FIND0: begin
            if (finish) begin
                nst = FINISH;
            end
            else if (FIND0_fn) begin
                nst = FIND1;
            end
            else nst = FIND0;
        end
        FIND1: begin
            if (m == 3'd7) begin
                nst = SWAP0;
            end
            else nst = FIND1;
        end
        SWAP0: nst = SWAP1;
        SWAP1: begin
            nst = CAL;
        end
        FINISH: nst = FINISH;
        default: nst = IDLE;
    endcase
end

endmodule
