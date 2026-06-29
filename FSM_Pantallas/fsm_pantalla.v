module fsm_pantalla (
    input setting,
    input exit, //pooner exits independientes?
    input correct_password,
    input [1:0] sel,

    output kids,
    output password,
    output menu,
    output adult,
    output setting
);

// Estados (pantallas)
localparam KIDS = 3'd0;
localparam PASSWORD = 3'd1;
localparam MENU = 3'd2; //nose
localparam ADULT = 3'd3;
localparam SETTINGS = 3'd4;

reg [1:0] state, next_state;

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
            if (settiing) state=PASSWORD;
            else state=KIDS;
        end
        PASSWORD: begin
            if (exit) state=KIDS;
            else if (correct_password) state=MENU;
            else state=PASSWORD;
        end
        MENU: begin
            if (exit) state=KIDS;
            else if (sel==) state=MENU;
            else state=PASSWORD;
        end
        ADULT: begin
            if (exit) state=MENU;
            else state=ADULT;
        end
        SETTINGS: begin
            if (exit) state=MENU;
            else state=SETTINGS;
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