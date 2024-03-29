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

begin
    Motor.Command(Forward);
    delay 1.5;
    Motor.Command(Forward);
    delay 0.5;
    Motor.Command(Backward);
    delay 0.7;
    Motor.Command(Backward);
    delay 0.5;
    Motor.Command(Backward);
    delay 2.5;
    Motor.Command(Forward);
    delay 1.0;
    Motor.Command(Forward);
    delay 2.0;
end main;
