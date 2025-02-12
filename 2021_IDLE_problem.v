module geofence ( clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output reg valid;
output reg is_inside;

parameter IDLE = 2'd0, SORT = 2'd1, CAL = 2'd2, FINISH = 2'd3;
reg [2:0] cst, nst;

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
        x[counter] <= X;
        y[counter] <= Y;
        counter <= counter + 3'd1;
    end
    else begin
        counter <= 3'd0;
    end
end

//sort
reg [2:0] point_sort;
wire [2:0] cnt1;
assign cnt1 = point_sort - 3'd1;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        point_sort <= 3'd3;
    end
    else if (cst == SORT) begin
        if (((x[cnt1] - x[1])*(y[point_sort] - y[1])) - ((x[point_sort] - x[1])*(y[cnt1] - y[1])) > 0) begin
            x[point_sort] <= x[cnt1];
            y[point_sort] <= y[cnt1];
            x[cnt1] <= x[point_sort];
            y[cnt1] <= y[point_sort];
        end
        point_sort <= point_sort + 3'd1;
    end
    else point_sort <= 3'd3;
end

//cal
reg [2:0] point_cal;
wire [2:0] cnt2;
assign cnt2 = point_cal - 3'd1;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        point_cal <= 3'd2;
        is_inside <= 1'b1;
    end
    else if (cst == CAL) begin
        if ((((x[cnt2] - x[0])*(y[point_cal] - y[0])) - ((x[point_cal] - x[0])*(y[cnt2] - y[0]))) < 0) begin
            is_inside <= 1'b0;
        end
        else is_inside <= 1'b1;

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
            if (point_sort == 3'd6) begin
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

