with Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;

procedure main is

    type motor_parancs is (Backward, Forward);

    task motor is
        entry command(parancs: motor_parancs);
    end motor;

    task body motor is
        speed : Integer := 0;
        position : Integer := 0;
    begin
        loop
            accept command(parancs : motor_parancs) do
                case (parancs) is
                    when (Backward) => speed := speed - 1;
                    when (Forward) => speed := speed + 1;
                end case;
                if speed < -1 then
                    speed := -1;
                end if;
                if speed > 1 then
                    speed := 1;
                end if;
                Put_Line("Kapott parancs: " & motor_parancs'Image(parancs) & " Mozgasirany: " & Integer'Image(speed) & " Megtett tav: ");
            end command;
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
