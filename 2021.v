module geofence ( clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output reg valid;
output reg is_inside;

parameter IDLE = 2'd0, SORT = 2'd1, CAL = 2'd2, FINISH = 2'd3;
reg [1:0] cst, nst;

//read
reg [2:0] counter;
reg [9:0] x [6:0];
reg [9:0] y [6:0];
always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 3'd0;
        x[0] <= 10'd0;
        x[1] <= 10'd0;
        x[2] <= 10'd0;
        x[3] <= 10'd0;
        x[4] <= 10'd0;
        x[5] <= 10'd0;
        x[6] <= 10'd0;
        y[0] <= 10'd0;
        y[1] <= 10'd0;
        y[2] <= 10'd0;
        y[3] <= 10'd0;
        y[4] <= 10'd0;
        y[5] <= 10'd0;
        y[6] <= 10'd0;
    end
    else if (cst == IDLE) begin
        valid <= 1'b0;
        is_inside <= 1'b1;
        if (!valid) begin
            x[counter] <= X;
            y[counter] <= Y;
            counter <= counter + 3'd1;
        end
    end
    else begin
        counter <= 3'd0;
    end
end

//sort
reg [2:0] i, j;
wire [2:0] cnt1;
assign cnt1 = j - 3'd1;
wire signed [10:0] Ax, Bx, Ay, By;
assign Ax = x[cnt1]-x[1];
assign Ay = y[cnt1]-y[1];
assign Bx = x[j]-x[1];
assign By = y[j]-y[1];
wire [21:0] out;
assign out = (Ax*By - Bx*Ay);
always @(posedge clk or posedge reset) begin
    if (reset) begin
        i <= 3'd3;
        j <= 3'd3;  
    end
    else if (cst == SORT) begin
        if (cnt1 == 3'd2) begin
            i <= i + 3'd1;
            j <= i + 3'd1;
        end
        else j <= j - 3'd1;
    end
    else begin
        i <= 3'd3;
        j <= 3'd3;
    end
end

always @(posedge clk) begin
    if (cst == SORT) begin
        if (out[21] == 1'b0) begin
            x[j] <= x[cnt1];
            y[j] <= y[cnt1];
            x[cnt1] <= x[j];
            y[cnt1] <= y[j];
        end
    end
end

//cal
reg [2:0] point_cal;
wire [2:0] cnt2;
assign cnt2 = point_cal - 3'd1;
wire [21:0] check;
assign check = (((x[cnt2] - x[0])*(y[point_cal] - y[cnt2])) - ((x[point_cal] - x[cnt2])*(y[cnt2] - y[0])));
always @(posedge clk or posedge reset) begin
    if (reset) begin
        point_cal <= 3'd2;
        is_inside <= 1'b1;
    end
    else if (cst == CAL) begin
        if (check[21] == 1'b0) begin
            is_inside <= 1'b0;
        end
        point_cal <= point_cal + 3'd1;
    end
    else begin
        point_cal <= 3'd2;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        valid <= 1'b0;
    end
    else if (cst == FINISH) begin
        valid <= 1'b1;
    end
    else valid <= 1'b0;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        cst <= IDLE;
    end
    else cst <= nst;
end

always @(*) begin
    case (cst)
        IDLE: begin
            if (counter == 3'd6) begin
                nst = SORT;
            end
            else nst = IDLE;
        end 
        SORT: begin
            if (i == 3'd6 && j == 3'd3) begin
                nst = CAL;
            end
            else nst = SORT;
        end
        CAL: begin
            if (point_cal == 3'd6) begin
                nst = FINISH;
            end
            else nst = CAL;
        end
        FINISH: begin
            nst = IDLE;
        end
        default: nst = IDLE;
    endcase
end
endmodule
