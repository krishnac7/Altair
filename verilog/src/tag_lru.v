// Part of the cache controller
// Least Recently Used replacement policy

// TODO generate the design from the parameters
// TODO measure the hardware cost and performance and optimize
module tag_lru #(
    parameter WAY = 4,
    localparam SINGLE_LRU_TAG_LENGTH = $clog2(WAY), // Size of a tag (single way)
    localparam LRU_TAG_LENGTH = SINGLE_LRU_TAG_LENGTH * WAY // Size of all tags
) (
    input wire i_clk,
    input wire [LRU_TAG_LENGTH-1:0] old_tags,
    output wire [LRU_TAG_LENGTH-1:0] new_tags,
    input wire [SINGLE_LRU_TAG_LENGTH-1:0] hit // 00 if way0 is a hit, 01 for way1...
);
    reg [1:0] hit_counter;

    always@*
    begin
        case (hit)
            2'b00: hit_counter = old_tags[7:5];
            2'b01: hit_counter = old_tags[4:3];
            2'b10: hit_counter = old_tags[3:2];
            2'b11: hit_counter = old_tags[1:0];
            default: hit_counter = 2'b00;
        endcase
    end

    wire hit_way0;
    wire [SINGLE_LRU_TAG_LENGTH-1:0] old_tag_way0;
    reg [SINGLE_LRU_TAG_LENGTH-1:0] new_tag_way0;
    assign hit_way0 = (hit == 2'b00)? 1'b1: 1'b0;
    // old_tag_way0[7:5]
    assign old_tag_way0 = old_tags[LRU_TAG_LENGTH-1:LRU_TAG_LENGTH-SINGLE_LRU_TAG_LENGTH];
    single_tag_lru #(.WAY(4)) lru_way0 (
        .is_hit(hit_way0),
        .old_count(old_tag_way0),
        .new_count(new_tag_way0),
        .ohit_count(hit_counter)
    );

    wire hit_way1;
    wire [SINGLE_LRU_TAG_LENGTH-1:0] old_tag_way1;
    reg [SINGLE_LRU_TAG_LENGTH-1:0] new_tag_way1;
    assign hit_way1 = (hit == 2'b01)? 1'b1: 1'b0;
    // old_tag_way1[4:3]
    assign old_tag_way1 = old_tags[4:3];
    single_tag_lru #(.WAY(4)) lru_way1 (
        .is_hit(hit_way1),
        .old_count(old_tag_way1),
        .new_count(new_tag_way1),
        .ohit_count(hit_counter)
    );

    wire hit_way2;
    wire [SINGLE_LRU_TAG_LENGTH-1:0] old_tag_way2;
    reg [SINGLE_LRU_TAG_LENGTH-1:0] new_tag_way2;
    assign hit_way2 = (hit == 2'b10)? 1'b1: 1'b0;
    // old_tag_way2[3:2]
    assign old_tag_way2 = old_tags[3:2];
    single_tag_lru #(.WAY(4)) lru_way2 (
        .is_hit(hit_way2),
        .old_count(old_tag_way2),
        .new_count(new_tag_way2),
        .ohit_count(hit_counter)
    );

    wire hit_way3;
    wire [SINGLE_LRU_TAG_LENGTH-1:0] old_tag_way3;
    reg [SINGLE_LRU_TAG_LENGTH-1:0] new_tag_way3;
    assign hit_way3 = (hit == 2'b11)? 1'b1: 1'b0;
    // old_tag_way3[1:0]
    assign old_tag_way3 = old_tags[1:0];
    single_tag_lru #(.WAY(4)) lru_way3 (
        .is_hit(hit_way3),
        .old_count(old_tag_way3),
        .new_count(new_tag_way3),
        .ohit_count(hit_counter)
    );

    assign new_tags = {new_tag_way0, new_tag_way1, new_tag_way2, new_tag_way3};

endmodule

// We update the LRU counter to indicate if the way tagged by this counter was
// the Least recently used
// Three scenario:
// [1] We have a hit on the way tagged by this counter, we set the counter to
// the maximum value
// [2] We have a hit on some other way and we have to decrease our counter to
// let the other way take our place
// [3] We have a hit on some other way but we are already on the bottom, we do
// not change our counter
module single_tag_lru #(
    parameter WAY = 4,
    localparam SINGLE_LRU_TAG_LENGTH = $clog2(WAY) // Size of a tag (single way)
) (
    input wire is_hit, // hit on this way
    output reg [SINGLE_LRU_TAG_LENGTH-1:0] new_count,
    input wire [SINGLE_LRU_TAG_LENGTH-1:0] old_count,
    input wire [SINGLE_LRU_TAG_LENGTH-1:0] ohit_count // an other way has hit and this is it's old counter's value
);
    always@*
    begin
        if (is_hit) begin
            new_count = {SINGLE_LRU_TAG_LENGTH{1'b1}}; // [1]
        end else begin
            // Corner case: will never do 0-1 because N < 0 cannot be true
            if (ohit_count < old_count) new_count = old_count-1; // [2]
            else new_count = old_count; // [3]
        end
    end
endmodule
