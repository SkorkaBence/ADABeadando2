with Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;

procedure main is

    type motor_parancs is (Backward, Forward, Power_Off);

    Motor_Burned_Out: Exception;

    task motor is
        entry command(parancs: motor_parancs);
    end motor;

    task Elevator is
        entry Move_Up;
        entry Move_Down;
    end Elevator;

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

            Put_Line("Mozgasirany: " & Integer'Image(speed) & " Megtett tav: " & Float'Image(position));
        end loop;
    end motor;

    task body Elevator is
        minimum_value: Integer := 0;
        maximum_value: Integer := 40;

        position: Integer := minimum_value;
    begin
        loop
            select
                when position < maximum_value => accept Move_Up do
                    position := position + 1;
                    Put_Line("Fentebbment!");
                end;
            or
                when position > minimum_value => accept Move_Down do
                    position := position - 1;
                    Put_Line("Lentebbment!");
                end;
            or
                terminate;
            end select;
            Put_Line("Poz: " & Integer'Image(position));
        end loop;
    end Elevator;

begin
    delay 1.0;
    Put_Line("Forward");
    Motor.Command(Forward);
    delay 1.5;
    Motor.Command(Forward);
    delay 0.5;
    Put_Line("Stop");
    Motor.Command(Backward);
    delay 0.7;
    Put_Line("Backward");
    Motor.Command(Backward);
    delay 0.5;
    Motor.Command(Backward);
    delay 1.0;
    Put_Line("Stop");
    Motor.Command(Forward);
    delay 1.0;
    Put_Line("Forward");
    Motor.Command(Forward);
    delay 200.0;
    Motor.Command(Power_Off);
end main;
