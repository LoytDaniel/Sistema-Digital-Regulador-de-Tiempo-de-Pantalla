module fsm_screen (
    input clk,
    input reset,
    input exit,
    input correct_password,
    input [1:0] sel,

    output reg kids,
    output reg password,
    output reg menu,
    output reg adult,
    output reg setting
);

// Estados (pantallas)
localparam KIDS = 3'b000;
localparam PASSWORD = 3'b001;
localparam MENU = 3'b010; //nose
localparam ADULT = 3'b011;
localparam SETTINGS = 3'b100;

reg [2:0] state, next_state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= KIDS;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
 next_state = state;
    case (state)
        KIDS: begin
            if (exit) next_state=PASSWORD;  //main menu usa la misma tecla que exit, se toma como una sola señal
            else next_state=KIDS;
        end
        PASSWORD: begin
            if (exit) next_state=KIDS;
            else if (correct_password) next_state=MENU;
            else next_state=PASSWORD;
        end
        MENU: begin
            if (exit) next_state=KIDS;
            else if (sel==2'b01) next_state=ADULT;
            else if (sel==2'b10) next_state=SETTINGS;
            else next_state=MENU;
        end
        ADULT: begin
            if (exit) next_state=MENU;
            else next_state=ADULT;
        end
        SETTINGS: begin
            if (exit) next_state=MENU;
            else next_state=SETTINGS;
        end
	
    endcase
end

//logica de salida
always @(*) begin
    case (state)
        KIDS: begin
            kids=1;
            password=0;
            menu=0;
            adult=0;
            setting=0;
        end
        PASSWORD: begin
            kids=0;
            password=1;
            menu=0;
            adult=0;
            setting=0;
        end
        MENU: begin
            kids=0;
            password=0;
            menu=1;
            adult=0;
            setting=0;
        end
        ADULT: begin
            kids=0;
            password=0;
            menu=0;
            adult=1;
            setting=0;
        end
        SETTINGS: begin
            kids=0;
            password=0;
            menu=0;
            adult=0;
            setting=1;
        end

    endcase
end
    
endmodule