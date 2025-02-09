module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

reg [2:0] cst, nst;
reg [9:0] currentcost;
          reg [2:0] seq [7:0];
reg [2:0] i, j, Min;
parameter IDLE = 3'd0, 
          CAL = 3'd1, 
          CHECK = 3'd2,
          FIND0 = 3'd3,
          FIND1 = 3'd4, 
          SWAP0 = 3'd5,
          SWAP1 = 3'd6,
          FINISH = 3'd7;

always @(posedge CLK or posedge RST) begin
    if(RST) begin
        seq[0] <= 0;
        seq[1] <= 1;
        seq[2] <= 2;
        seq[3] <= 3;
        seq[4] <= 4;
        seq[5] <= 5;
        seq[6] <= 6;
        seq[7] <= 7;
        cst <= IDLE;
        currentcost <= 0;
        i <= 0;
        MatchCount <= 1;
        MinCost <= 1023;
        W <= 0;
        Valid <= 0;
        Min <= 7;
    end
    else begin
        cst <= nst;
    end
end

always @(*) begin
    case (cst)
        IDLE: begin
            nst = CAL;
        end 
        CAL: begin
            if (W == 8) begin
                nst = CHECK;
            end
            else begin
                nst = CAL;
            end
        end
        CHECK: begin
            nst = FIND0;
        end
        FIND0: begin
            if (seq[W] > seq[W-1]) begin
                nst = FIND1;
            end
            else if (W == 0) begin
                nst = FINISH;
            end
            else begin
                nst = FIND0;
            end
        end
        FIND1: begin
            if (W == 6) begin
                nst = SWAP0;
            end
            else begin
                nst = FIND1;
            end
        end
        SWAP0: begin
            if (i == 6) begin
                nst = CAL;
            end
            else begin
                nst = SWAP1;
            end
        end
        SWAP1: begin
            nst = CAL;
        end
        FINISH: begin
            nst = IDLE;
        end
        default: nst = IDLE;
    endcase
end

always @(posedge CLK) begin
    if (cst == CAL) begin
        W <= W + 1;
        J <= seq[W];
    end
end

always @(negedge CLK) begin
    if (cst == CAL) begin
        currentcost <= currentcost + Cost;
    end
end

always @(negedge CLK) begin
    if (cst == CHECK) begin
        if (currentcost < MinCost) begin
            MinCost <= currentcost;
            MatchCount <= 1;
        end
        else if (currentcost == MinCost) begin
            MatchCount <= MatchCount + 1;
        end
    end
end

always @(posedge CLK) begin
    if (cst == FIND0) begin
        if (seq[W] < seq[W-1]) begin
             W <= W - 1;
        end
        else begin
            i <= W - 1;
        end
    end
end

always @(posedge CLK) begin
    if (cst == FIND1) begin
        W <= W + 1;
        if (seq[W] > seq[i]) begin
            if (seq[W] < Min) begin
                      Min <= seq[W];
                j <= W;
            end
        end
    end
end

always @(posedge CLK) begin
    if (cst == SWAP0) begin
        seq[i] <= seq[j];
        seq[j] <= seq[i];
    end
end

always @(posedge CLK) begin
    if (cst == SWAP1) begin
        case (i)
            0: begin
                seq[1] <= seq[7];
                seq[2] <= seq[6];
                seq[3] <= seq[5];
                seq[5] <= seq[3];
                seq[6] <= seq[2];
                seq[7] <= seq[1];
            end
            1: begin
                seq[2] <= seq[7];
                seq[3] <= seq[6];
                seq[4] <= seq[5];
                seq[5] <= seq[4];
                seq[6] <= seq[3];
                seq[7] <= seq[2];
            end
            2: begin
                seq[3] <= seq[7];
                seq[4] <= seq[6];
                seq[6] <= seq[4];
                seq[7] <= seq[3];
            end
            3: begin
                seq[4] <= seq[7];
                seq[5] <= seq[6];
                seq[6] <= seq[5];
                seq[6] <= seq[4];
            end
            4: begin
                seq[5] <= seq[7];
                seq[7] <= seq[5];
            end
            5: begin
                seq[6] <= seq[7];
                seq[7] <= seq[6];
            end
        endcase
    end
end

always @(posedge CLK) begin
    if (cst == FINISH) begin
        Valid = 1;
    end
end

endmodule
