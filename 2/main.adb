with Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;

procedure main is

    type motor_parancs is (Backward, Forward);

    task motor is
        entry command(parancs: motor_parancs);
    end motor;

    task body motor is
        use Ada.Calendar;

        speed : Integer := 0;
        position : Float := 0.0;

        lastupdate : Ada.Calendar.Time := Ada.Calendar.Clock;
    begin
        loop
            select
                accept command(parancs : motor_parancs) do

                    declare
                        time : Ada.Calendar.Time := Ada.Calendar.Clock;
                        difference : Duration := time - lastupdate;
                    begin
                        position := position + Float(speed * difference);
                        lastupdate := time;
                    end;

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
                    end case;
                    Put_Line("Kapott parancs: " & motor_parancs'Image(parancs) & " Mozgasirany: " & Integer'Image(speed) & " Megtett tav: " & Float'Image(position));

                end command;
            or
                terminate;
            end select;
        end loop;
    end motor;

    task Elevator is
        entry Move_Up;
        entry Move_Down;
    end Elevator;

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
    for I in 1..4 loop
        Elevator.Move_Up;
    end loop;
    for I in 1..10 loop
        Elevator.Move_Down;
    end loop;
    for I in 1..100 loop
        Elevator.Move_Up;
    end loop;
end main;
