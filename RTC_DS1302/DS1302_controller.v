module DS1302_controller (clk1, rstn, rd_tick, wr_btn, hr, min, sec, time_out, CE, SCLK, IO);
	
	// Clock address of DS1302 RTC module
	localparam BURST_RD_ADDR = 8'hBF;
	localparam BURST_WR_ADDR = 8'hBE;
	localparam WR_CTRL_REG_ADDR = 8'h8E; // Control register address, used to clear Write Protection during initialization (WP = 0 to allow writing to RTC registers)
	localparam WR_SEC_REG_ADDR = 8'h80; // Seconds register address, used to clear Clock Halt during initialization (CH = 0 to start the clock)
	
	input clk1, rstn; 
    input rd_tick, wr_btn;
	input [7:0] hr, min, sec; // Time to write, in BCD format
	
	output reg CE, SCLK;
	output reg [63:0] time_out;
	
	inout wire IO; // IO is a bi-directional port (used for both read and write operations)
	
	reg read_request, prev_wr_btn;
	reg io_dir, io; // io_dir controls the direction of IO port, io_dir = 1: output, io_dir = 0: input
	reg CH_init, WP_init; // These flags check if the RTC module has been initialized (Write Protection and Clock Halt is cleared) or not
	reg [6:0] count; // count to keep track of the current data bit
	reg [7:0] addr;
	wire [63:0] burst_data;
	
    // State machine states
    localparam IDLE = 4'b0000; 
    localparam WR_ADDR_PREP = 4'b0001; // Prepare the current address bit value at SCLK low level
    localparam WR_ADDR = 4'b0010; // Raise SCLK to send address bit
    localparam CNT_RST = 4'b0011; // Reset count and move to read or write state based on the sent address
    localparam WR_BURST_PREP = 4'b0100; // Prepare to send burst data
    localparam WR_BURST = 4'b0101; // Send burst data
    localparam WR_SINGLE_PREP = 4'b0110; // Prepare the current data bit at SCLK low level
    localparam WR_SINGLE = 4'b0111; // Send single data
    localparam RD_BURST = 4'b1000; // Prepare to read burst data, pull SCLK low level
    localparam STO_BURST = 4'b1001; // Store burst data to internal register
    localparam TERMINATE = 4'b1010; // Terminate the communication by pulling CE and SCLK low and reset count

    reg [3:0] state, next_state;
	
	// Time data to write to RTC module, day, date, month, year are sent as 0s. Functionality can be expanded later
	assign burst_data = {8'b0, 8'b0, 8'b0, 8'b0, 8'b0, hr, min, sec};
	
	assign IO = io_dir ? io : 1'bz; // In order for IO port to be an input port, it has to be set to a high-imdedance state (hi-Z)

	// Detect Write button falling edge
	always @(posedge clk1) begin
		if (wr_btn) prev_wr_btn <= 1;
		else if (prev_wr_btn) begin
			prev_wr_btn <= 0;
		end
	end

    always @(posedge clk1) begin
        if(!rstn)
            read_request <= 0;
        else if(rd_tick)
            read_request <= 1;
        else if(state == WR_ADDR_PREP && addr == BURST_RD_ADDR)
            read_request <= 0;
        end

    //Reset logic
    always @(posedge clk1) begin
        if(!rstn) state <= IDLE;
        else state <= next_state;
    end

    // Transition logic for the state machine
    always @(*) begin
        case(state)
            IDLE: begin
                if (!WP_init) next_state = WR_ADDR_PREP;
                else if (!CH_init) next_state = WR_ADDR_PREP;
                else if (!wr_btn && prev_wr_btn) next_state = WR_ADDR_PREP;
                else if (read_request) next_state = WR_ADDR_PREP;
                else next_state = IDLE;
            end

            WR_ADDR_PREP: next_state = WR_ADDR;

            WR_ADDR: begin
                if (count == 7'd7) next_state = CNT_RST; // If all 8 address bits are sent, move to transferring data
                else next_state = WR_ADDR_PREP; // Else continue to send remaining address bits
            end

            CNT_RST: begin
                if (addr == WR_CTRL_REG_ADDR) next_state = WR_SINGLE_PREP;
                else if (addr == WR_SEC_REG_ADDR) next_state = WR_SINGLE_PREP;
                //if reading, change direction of IO port to input
                else if (addr == BURST_RD_ADDR) next_state = RD_BURST;
                else if (addr == BURST_WR_ADDR) next_state = WR_BURST_PREP;
                else next_state = IDLE;
            end

            WR_SINGLE_PREP: next_state = WR_SINGLE;

            WR_SINGLE: begin
                if (count == 7'd7) next_state = TERMINATE; //if all 8 data bits for the single-byte write are sent, terminate the communication
                else next_state = WR_SINGLE_PREP; //else, continue to send remaining data bits
            end

            WR_BURST_PREP: next_state = WR_BURST;

            WR_BURST: begin
                if (count == 7'd63) next_state = TERMINATE; //if all 64 bits for 8x8-bit Clock registers are sent, terminate the communication
                else next_state = WR_BURST_PREP;
            end

            RD_BURST: next_state = STO_BURST;

            STO_BURST: begin
                if (count == 7'd63) next_state = TERMINATE; //if all 64 bits from 8x8-bit Clock registers are received, terminate the communication
                else next_state = RD_BURST;
            end

            TERMINATE: next_state = IDLE;

            default: next_state = IDLE;
        endcase
    end

    // Output logic for the state machine
    always @(posedge clk1) begin
        if (!rstn) begin
            count <= 0;
            CE <= 0;
            SCLK <= 0;
            io_dir <= 1;
            io <= 0;
            time_out <= 64'd0;
            WP_init <= 0;
            CH_init <= 0;
        end else begin

            case (state)
                IDLE: begin
                    CE <= 0;
                    SCLK <= 0;
                    count <= 0;
                    io_dir <= 1;
                    if (!WP_init) addr <= WR_CTRL_REG_ADDR;
					else if (!CH_init) addr <= WR_SEC_REG_ADDR;
					else if (!wr_btn && prev_wr_btn) addr <= BURST_WR_ADDR;
					else if (read_request) addr <= BURST_RD_ADDR;
                end

                WR_ADDR_PREP: begin
                    CE <= 1; // CE is set HIGH to initiate communication
                    SCLK <= 0;
                    io_dir <= 1;
                    io <= addr[count];
                end

                WR_ADDR: begin
                    SCLK <= 1;
                    count <= count + 7'd1;
                end

                CNT_RST: begin
                    count <= 0;
                    if (addr == BURST_RD_ADDR) io_dir <= 0; // If reading, change direction of IO port to input
                end

                WR_SINGLE_PREP: begin
                    SCLK <= 0;
                    io <= 0; // Since we are only writing 0s to the control register and seconds register during initialization, io is set to 0. This can be modified later if we want to write different values to these registers.
                end

                WR_SINGLE: begin
                    SCLK <= 1;
                    count <= count + 7'd1;
                end

                WR_BURST_PREP: begin
                    SCLK <= 0;
                    io <= burst_data[count];
                end

                WR_BURST: begin
                    SCLK <= 1;
                    count <= count + 7'd1;
                end

                RD_BURST: SCLK <= 0;

                STO_BURST: begin
                    SCLK <= 1;
                    time_out[count] <= IO;
                    count <= count + 7'd1;
                end

                TERMINATE: begin
                    CE <= 0;
                    SCLK <= 0;
                    count <= 0;
                    if (addr == WR_CTRL_REG_ADDR) WP_init <= 1;
					if (addr == WR_SEC_REG_ADDR) CH_init <= 1;
                end
            endcase
        end
    end 
endmodule 
	