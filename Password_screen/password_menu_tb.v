`timescale 1ns / 1ps
//======================================================================
// Testbench: password_checker_tb
//
// Casos probados:
//   1) Ingreso correcto de contrasena (1-2-3-4) y verificacion con Aceptar
//   2) Tecla sostenida varios ciclos (simula "rebote"/tecla mantenida)
//      -> debe contarse una sola vez
//   3) Borrar borra TODO y reinicia la captura desde el primer digito
//   4) Ingreso de contrasena incorrecta
//   5) Mas de 4 digitos ingresados -> los adicionales se IGNORAN
//      (ya no es ventana deslizante)
//   6) Tecla Salir ('*') genera el pulso 'exit'
//   7) puntero_digitos evoluciona 000->001->010->011->100 y se congela
//   8) Con password=0 (pestaña deshabilitada) el modulo ignora todo:
//      no captura digitos, no evalua Aceptar, no genera exit
//======================================================================

module password_menu_tb;

    reg        clk;
    reg        rst;
    reg        password;
    reg  [3:0] key_out;
    reg        push_button;
    reg        Aceptar;
    reg        Borrar;
    reg        Salir;

    wire       correct_password;
    wire       exit;
    wire [2:0] puntero_digitos;

    integer    errors = 0;

    // Banderas "sticky" para capturar pulsos de 1 ciclo sin depender
    // de revisar el valor en el instante exacto
    reg correct_seen;
    reg exit_seen;

    always @(posedge clk) begin
        if (correct_password) correct_seen <= 1'b1;
        if (exit)              exit_seen   <= 1'b1;
    end

    // Contrasena por defecto para la prueba: 1-2-3-4
    password_menu #(
        .DEFAULT_PASSWORD(16'h1234)
    ) dut (
        .clk(clk),
        .rst(rst),
        .password(password),
        .key_out(key_out),
        .push_button(push_button),
        .Aceptar(Aceptar),
        .Borrar(Borrar),
        .Salir(Salir),
        .correct_password(correct_password),
        .exit(exit),
        .puntero_digitos(puntero_digitos)
    );

    // Reloj de 100 MHz (periodo 10 ns)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    //------------------------------------------------------------------
    // Tareas auxiliares
    //------------------------------------------------------------------

    // Presiona una tecla numerica; hold_cycles simula que se mantiene
    // presionada varios ciclos de reloj (para probar el filtro de flanco)
    task press_digit(input [3:0] digit, input integer hold_cycles);
        integer i;
        begin
            @(negedge clk);
            key_out     = digit;
            push_button = 1'b1;
            for (i = 0; i < hold_cycles; i = i + 1)
                @(negedge clk);
            push_button = 1'b0;
            key_out     = 4'hF; // vuelve a estado neutro
            @(negedge clk);
        end
    endtask

    task press_Aceptar(input integer hold_cycles);
        integer i;
        begin
            @(negedge clk);
            key_out = 4'hF;
            Aceptar = 1'b1;
            for (i = 0; i < hold_cycles; i = i + 1)
                @(negedge clk);
            Aceptar = 1'b0;
            @(negedge clk);
        end
    endtask

    task press_Borrar(input integer hold_cycles);
        integer i;
        begin
            @(negedge clk);
            key_out = 4'hF;
            Borrar  = 1'b1;
            for (i = 0; i < hold_cycles; i = i + 1)
                @(negedge clk);
            Borrar  = 1'b0;
            @(negedge clk);
        end
    endtask

    task press_Salir(input integer hold_cycles);
        integer i;
        begin
            @(negedge clk);
            key_out = 4'hF;
            Salir   = 1'b1;
            for (i = 0; i < hold_cycles; i = i + 1)
                @(negedge clk);
            Salir   = 1'b0;
            @(negedge clk);
        end
    endtask

    task check_eq(input [2:0] got, input [2:0] expected, input [8*64-1:0] msg);
        begin
            if (got === expected) begin
                $display("[OK]    %0s (puntero_digitos=%0d)", msg, got);
            end else begin
                $display("[FALLO] %0s (esperado=%0d, obtenido=%0d)", msg, expected, got);
                errors = errors + 1;
            end
        end
    endtask

    //------------------------------------------------------------------
    // Secuencia de pruebas
    //------------------------------------------------------------------
    initial begin
        // Estado inicial
        rst          = 1'b1;
        password     = 1'b1; // pestaña activa por defecto durante las pruebas 1-7
        key_out      = 4'hF;
        push_button  = 1'b0;
        Aceptar      = 1'b0;
        Borrar       = 1'b0;
        Salir        = 1'b0;
        correct_seen = 1'b0;
        exit_seen    = 1'b0;
        repeat (2) @(negedge clk);
        rst = 1'b0;

        check_eq(puntero_digitos, 3'd0, "puntero_digitos inicia en 0 tras reset");

        //--------------------------------------------------------------
        $display("--- Prueba 1: contrasena correcta (1-2-3-4) ---");
        correct_seen = 1'b0;
        press_digit(4'd1, 1);
        press_digit(4'd2, 1);
        press_digit(4'd3, 1);
        press_digit(4'd4, 1);
        press_Aceptar(1);
        if (correct_seen === 1'b1) $display("[OK]    correct_password=1 con clave 1234");
        else begin $display("[FALLO] correct_password no se activo con clave 1234"); errors = errors + 1; end

        //--------------------------------------------------------------
        $display("--- Prueba 2: tecla sostenida (rebote) solo cuenta una vez ---");
        press_Borrar(1);
        correct_seen = 1'b0;
        // push_button se mantiene en alto 5 ciclos con key_out=1: debe contar como un solo '1'
        press_digit(4'd1, 5);
        press_digit(4'd2, 1);
        press_digit(4'd3, 1);
        press_digit(4'd4, 1);
        press_Aceptar(1);
        if (correct_seen === 1'b1) $display("[OK]    tecla sostenida no genero digitos duplicados (clave 1234 sigue correcta)");
        else begin $display("[FALLO] la tecla sostenida genero lecturas repetidas"); errors = errors + 1; end

        //--------------------------------------------------------------
        $display("--- Prueba 3: Borrar borra TODO y reinicia la captura ---");
        press_digit(4'd9, 1);
        press_digit(4'd9, 1);
        press_digit(4'd9, 1); // solo 3 digitos, contrasena incompleta
        press_Borrar(1);
        check_eq(puntero_digitos, 3'd0, "tras Borrar, puntero_digitos vuelve a 0");
        correct_seen = 1'b0;
        press_digit(4'd1, 1);
        press_digit(4'd2, 1);
        press_digit(4'd3, 1);
        press_digit(4'd4, 1);
        press_Aceptar(1);
        if (correct_seen === 1'b1) $display("[OK]    tras Borrar, ingresar 1234 fue correcto (no quedaron residuos)");
        else begin $display("[FALLO] Borrar no reinicio correctamente la captura"); errors = errors + 1; end

        //--------------------------------------------------------------
        $display("--- Prueba 4: contrasena incorrecta ---");
        press_Borrar(1);
        correct_seen = 1'b0;
        press_digit(4'd9, 1);
        press_digit(4'd9, 1);
        press_digit(4'd9, 1);
        press_digit(4'd9, 1);
        press_Aceptar(1);
        if (correct_seen === 1'b0) $display("[OK]    clave 9999 fue rechazada correctamente");
        else begin $display("[FALLO] clave 9999 fue aceptada incorrectamente"); errors = errors + 1; end

        //--------------------------------------------------------------
        $display("--- Prueba 5: mas de 4 digitos -> los adicionales se ignoran ---");
        press_Borrar(1);
        correct_seen = 1'b0;
        press_digit(4'd1, 1);
        press_digit(4'd2, 1);
        press_digit(4'd3, 1);
        press_digit(4'd4, 1);
        press_digit(4'd9, 1); // 5to digito: debe ser ignorado
        press_digit(4'd9, 1); // 6to digito: debe ser ignorado
        check_eq(puntero_digitos, 3'd4, "puntero_digitos se congela en 4 tras el 4to digito");
        press_Aceptar(1);
        if (correct_seen === 1'b1) $display("[OK]    con 6 digitos (1,2,3,4,9,9) prevalecio 1234 (5to y 6to ignorados)");
        else begin $display("[FALLO] los digitos extra no fueron ignorados correctamente"); errors = errors + 1; end

        //--------------------------------------------------------------
        $display("--- Prueba 6: tecla Salir genera pulso exit ---");
        exit_seen = 1'b0;
        press_Salir(3); // se mantiene presionada varios ciclos
        if (exit_seen === 1'b1) $display("[OK]    'exit' se activo al presionar Salir ('*')");
        else begin $display("[FALLO] 'exit' no se activo al presionar Salir"); errors = errors + 1; end

        //--------------------------------------------------------------
        $display("--- Prueba 7: evolucion de puntero_digitos ---");
        press_Borrar(1);
        check_eq(puntero_digitos, 3'd0, "puntero_digitos = 000 antes de ingresar nada");
        press_digit(4'd7, 1);
        check_eq(puntero_digitos, 3'd1, "puntero_digitos = 001 tras 1er digito");
        press_digit(4'd8, 1);
        check_eq(puntero_digitos, 3'd2, "puntero_digitos = 010 tras 2do digito");
        press_digit(4'd9, 1);
        check_eq(puntero_digitos, 3'd3, "puntero_digitos = 011 tras 3er digito");
        press_digit(4'd0, 1);
        check_eq(puntero_digitos, 3'd4, "puntero_digitos = 100 tras 4to digito");
        press_digit(4'd5, 1); // extra, no deberia mover el puntero
        check_eq(puntero_digitos, 3'd4, "puntero_digitos sigue en 100 tras digito extra");

        //--------------------------------------------------------------
        $display("--- Prueba 8: alternar password borra todo automaticamente ---");
        press_Borrar(1); // partir limpio (la prueba 7 dejo el puntero en 4)
        correct_seen = 1'b0;
        press_digit(4'd1, 1);
        press_digit(4'd2, 1);
        press_digit(4'd3, 1); // solo 3 digitos, a proposito
        check_eq(puntero_digitos, 3'd3, "puntero_digitos = 3 antes de deshabilitar la pestaña");

        password = 1'b0; // la FSM sale de esta pestaña (va a otro menu)
        @(negedge clk);
        check_eq(puntero_digitos, 3'd0, "al salir (password=0), se borra automaticamente");

        // Mientras esta deshabilitado, intentar teclear no debe hacer nada
        correct_seen = 1'b0;
        exit_seen    = 1'b0;
        press_digit(4'd1, 1);
        press_digit(4'd2, 1);
        press_digit(4'd3, 1);
        press_digit(4'd4, 1);
        check_eq(puntero_digitos, 3'd0, "con password=0, los digitos no se capturan");

        press_Aceptar(1);
        if (correct_seen === 1'b0) $display("[OK]    con password=0, Aceptar no genero correct_password");
        else begin $display("[FALLO] Aceptar funciono estando deshabilitado"); errors = errors + 1; end

        press_Salir(1);
        if (exit_seen === 1'b0) $display("[OK]    con password=0, Salir no genero exit");
        else begin $display("[FALLO] Salir funciono estando deshabilitado"); errors = errors + 1; end

        // Se reactiva la pestaña (la FSM regresa a este menu)
        password = 1'b1;
        @(negedge clk);
        check_eq(puntero_digitos, 3'd0, "al reactivar password=1, arranca en 0 (limpio)");

        correct_seen = 1'b0;
        press_digit(4'd1, 1);
        press_digit(4'd2, 1);
        press_digit(4'd3, 1);
        press_digit(4'd4, 1);
        press_Aceptar(1);
        if (correct_seen === 1'b1) $display("[OK]    al reactivar password=1, el modulo vuelve a funcionar normal");
        else begin $display("[FALLO] el modulo no volvio a funcionar tras reactivar password"); errors = errors + 1; end

        //--------------------------------------------------------------
        repeat (3) @(negedge clk);
        if (errors == 0)
            $display("\n>>> TODAS LAS PRUEBAS PASARON CORRECTAMENTE <<<");
        else
            $display("\n>>> SE ENCONTRARON %0d FALLO(S) <<<", errors);

        $finish;
    end

    // Volcado de forma de onda para inspeccionar en GTKWave si se desea
    initial begin
        $dumpfile("password_menu_tb.vcd");
        $dumpvars(0, password_menu_tb);
    end

endmodule
