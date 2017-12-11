with Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;

procedure main is

    type motor_parancs is (Backward, Forward, Power_Off);
    subtype Level is Integer range 0..4;

    Motor_Burned_Out: Exception;

    task motor is
        entry command(parancs: motor_parancs);
    end motor;

    task Elevator is
        entry Move_Up;
        entry Move_Down;
    end Elevator;

    task Controller is
        entry Sensor(emelet: Level);
        entry Request(emelet: Level);
    end Controller;

    task type Signal(emelet: Level);

    task body motor is
        use Ada.Calendar;

        speed : Integer := 0;
        position : Float := 0.0;

        running : Boolean := true;

        lastupdate : Ada.Calendar.Time := Ada.Calendar.Clock;

        procedure posupdate is
            time : Ada.Calendar.Time := Ada.Calendar.Clock;
            difference : Duration := time - lastupdate;

            threshold : Float := 0.1;
        begin
            position := position + Float(speed * difference);
            lastupdate := time;

            if (position > threshold) then
                position := position - threshold;
                select
                    Elevator.Move_Up;
                or
                    delay 0.1;
                    Put_Line("Kiegett a motor");
                    raise Motor_Burned_Out;
                end select;
            elsif (position < (- 1.0) * threshold) then
                position := position + threshold;
                select
                    Elevator.Move_Down;
                or
                    delay 0.1;
                    Put_Line("Kiegett a motor");
                    raise Motor_Burned_Out;
                end select;
            end if;
        end;
    begin
        while running loop
            posupdate;

            select
                accept command(parancs : motor_parancs) do
                    posupdate;

                    case (parancs) is
                        when (Backward) => begin
                            if speed > -1 then
                                speed := speed - 1;
                            end if;
                        end;
                        when (Forward) => begin
                            if speed < 1 then
                                speed := speed + 1;
                            end if;
                        end;
                        when (Power_Off) => begin
                            running := false;
                        end;
                    end case;
                    Put_Line("Kapott parancs: " & motor_parancs'Image(parancs));
                end command;
            or
                delay until (lastupdate + 0.1);
            end select;

            --Put_Line("Mozgasirany: " & Integer'Image(speed) & " Megtett tav: " & Float'Image(position));
        end loop;
    end motor;

    task body Elevator is
        minimum_value: Integer := Level'First * 10;
        maximum_value: Integer := Level'Last * 10;

        position: Integer := minimum_value;

        procedure posupdate is
            epsilon : Integer := 2;
            signalAccess : access Signal;
        begin
            if (position + epsilon - 1) mod 10 < epsilon then
                signalAccess := new Signal((position + epsilon) / 10);
            end if;
        end;
    begin
        posupdate;
        loop
            select
                when position < maximum_value => accept Move_Up do
                    position := position + 1;
                    --Put_Line("Fentebbment!");
                end;
            or
                when position > minimum_value => accept Move_Down do
                    position := position - 1;
                    --Put_Line("Lentebbment!");
                end;
            or
                terminate;
            end select;

            posupdate;

            Put_Line("Poz: " & Integer'Image(position));
        end loop;
    end Elevator;

    task body Controller is
        requestedto: Level := 0;
        currentfloor: Level := 0;

        engineDirection: Integer := 0;
    begin
        loop
            select
                accept Sensor(emelet: Level) do
                    if currentfloor < emelet then
                        engineDirection := 1;
                    elsif currentfloor > emelet then
                        engineDirection := -1;
                    end if;

                    currentfloor := emelet;
                    Put_Line(" --- " & Integer'Image(emelet) & " --- ");

                    if currentfloor = requestedto then
                        if engineDirection > 0 then
                            Motor.Command(Backward);
                        elsif engineDirection < 0 then
                            Motor.Command(Forward);
                        end if;

                        engineDirection := 0;
                    end if;
                end;
            or
                accept Request(emelet: Level) do
                    Put_Line("Requested to: " & Integer'Image(emelet));
                    requestedto := emelet;

                    if currentfloor < requestedto then
                        Motor.Command(Forward);
                        Motor.Command(Forward);
                        engineDirection := 1;
                    elsif currentfloor > requestedto then
                        Motor.Command(Backward);
                        Motor.Command(Backward);
                        engineDirection := -1;
                    elsif currentfloor = requestedto then
                        if engineDirection > 0 then
                            Motor.Command(Backward);
                            Motor.Command(Backward);
                            engineDirection := -1;
                        elsif engineDirection < 0 then
                            Motor.Command(Forward);
                            Motor.Command(Forward);
                            engineDirection := 1;
                        end if;
                    end if;
                end;
            or
                terminate;
            end select;
        end loop;
    end Controller;

    task body Signal is
    begin
        Controller.Sensor(emelet);
    end Signal;

begin
    delay 1.0;
    Controller.Request(Level'Last);
    Controller.Request(3);
    delay 5.0;
    Controller.Request(2);
    Controller.Request(4);
    delay 0.5;
    Controller.Request(1);
    delay 10.0;
    Motor.Command(Power_Off);
end main;
