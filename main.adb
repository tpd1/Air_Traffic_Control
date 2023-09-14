-- Author: Tim Deville (2003506)
-- Date: 05/12/22
-- Procedure for simulating an air traffic control input / output.

pragma SPARK_Mode (On);
with AS_Io_Wrapper;  use AS_Io_Wrapper;
with ATC_Controller; use ATC_Controller;

procedure Main is

   subtype ATC_Status_Type is ATC_Controller.ATC_Status_Type;
   subtype Direction_Type is ATC_Controller.Direction_Type;

   MAX_CMD   : constant Integer := 5;
   ENTER_CMD : constant String  := "Enter command 1-5: ";
   COMMANDS  : constant String  :=
     "Commands: 1. Enter Landing Airspace, 2. Request Landing, 3. Taxi To Gate, 4. Taxi To Runway, 5. Execute Takeoff.";
   NOT_IN_RANGE : constant String :=
     "Command not recognised, please enter a valid integer: ";
   DIR_TRAVEL : constant String :=
     "Enter Direction of Travel - 1 (East) or 2 (West): ";

   Cmd_Input      : Integer; -- User command selection.
   Dir_Input      : Integer; -- For selecting East/West.
   Direction      : Direction_Type; -- East/West selection.
   End_Loop_Input : String (1 .. 20);
   Last           : Integer;
   ATC_Status     : ATC_Status_Type; -- Holds current status of ATC.

begin
   AS_Init_Standard_Input;
   AS_Init_Standard_Output;
   -- Initialise ATC controller with default values
   Initialse_ATC (ATC_Status);
   loop
      pragma Loop_Invariant (ATC_Controller.No_Deadlock (ATC_Status));
      AS_Put_Line (COMMANDS);
      AS_Put_Line ("");
      -- Take User Command Input (1-5)
      AS_Put (ENTER_CMD);
      loop
         AS_Get (Cmd_Input, NOT_IN_RANGE);
         exit when Cmd_Input in 1 .. MAX_CMD;
         AS_Put (NOT_IN_RANGE);
      end loop;

      if (Cmd_Input /= 3) then
         -- Take User Direction Input (East/West).
         AS_Put (DIR_TRAVEL);
         loop
            AS_Get (Dir_Input, NOT_IN_RANGE);
            exit when Dir_Input in 1 .. 2;
            AS_Put (NOT_IN_RANGE);
         end loop;

         -- Process Direction input.
         if (Dir_Input = 1) then
            Direction := East;
         else
            Direction := West;
         end if;
      else
         Direction :=
           East; -- If Taxi_To_Gate (cmd 3) is chosen - direction not used.
      end if;
      AS_Put_Line ("");

      -- Process Command Input.
      case Cmd_Input is
         when 1 =>
            Enter_Landing_Airspace (ATC_Status, Direction);
         when 2 =>
            Request_Landing (ATC_Status, Direction);
         when 3 =>
            Taxi_To_Gate (ATC_Status);
         when 4 =>
            Taxi_To_Runway (ATC_Status, Direction);
         when 5 =>
            Execute_Takeoff (ATC_Status, Direction);
         when others =>
            null; -- Already handled other inputs.
      end case;

      -- Print ATC controller status.
      AS_Put_Line ("");
      AS_Put_Line ("----------------------------------");
      Print_Runway_Status (ATC_Status);
      AS_Put_Line ("----------------------------------");

      -- Ask User if they want to continue.
      loop
         AS_Put_Line ("");
         AS_Put ("Enter new command (y/n)? ");
         AS_Get_Line (End_Loop_Input, Last);
         exit when Last > 0;
         AS_Put_Line ("Please enter a non-empty string");
      end loop;
      exit when End_Loop_Input (1 .. 1) = "n";
   end loop;
end Main;
