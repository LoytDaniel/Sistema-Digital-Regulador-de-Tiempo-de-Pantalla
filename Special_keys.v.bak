module Special_keys(
    input [3:0] key_in,
    input push_button,

    output reg [3:0] key_out,
    output reg accept_key, delete_key, exit_key,
    output reg key_enable
);

always @(*) begin
    if (push_button) begin
    case (key_in)
        4'hA:begin //Accept
            accept_key <= 1;
            delete_key <= 0;
            exit_key <= 0;
            key_out <= 4'hF;
            key_enable <= 0;
        end
        4'hB:begin //Delete
            accept_key <= 0;
            delete_key <= 1;
            exit_key <= 0;
            key_out <= 4'hF;
            key_enable <= 0;
        end
        4'hE:begin //Exit
            accept_key <= 0;
            delete_key <= 0;
            exit_key <= 1;
            key_out <= 4'hF;
            key_enable <= 0;
        end
        4'hF: begin //Unknown
            accept_key <= 0;
            delete_key <= 0;
            exit_key <= 0;
            key_out <= 4'hF;
            key_enable <= 0;
        end

        default: begin
            key_out <= key_in;
            accept_key <= 0;
            delete_key <= 0;
            exit_key <= 0;
            key_enable <= 1;
        end

    endcase
    end else begin
        accept_key <= 0;
        delete_key <= 0;
        exit_key <= 0;
        key_enable <= 0;
        key_out <= 4'h0;
    end
end

endmodule