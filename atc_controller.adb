-- Author: Tim Deville (2003506)
-- Date: 05/12/22
-- Air Traffic Control system to simulate an airport with a single runway.
-- Planes can request entry to airspace to land, request landing, taxi to gate/runway
-- and take off.
pragma SPARK_Mode (On);

with AS_Io_Wrapper; use AS_Io_Wrapper;

package body ATC_Controller is

   -- Initialises ATC status to default values.
   procedure Initialse_ATC (ATC_Status : out ATC_Status_Type) is
   begin
      ATC_Status.Landing_Approach.East := Free;
      ATC_Status.Landing_Approach.West := Free;
      ATC_Status.Runway_Status         := Available;
   end Initialse_ATC;

   -- Function to convert the Landing approach direction to a string for output to console.
   function Landing_Approach_To_String
     (Landing_Approach : Airspace_Status_Type) return String
   is
   begin
      if (Landing_Approach = Reserved_Enter) then
         return "Reserved - Plane Entering Airspace.";
      elsif (Landing_Approach = Reserved_Exit) then
         return "Reserved - Plane Exiting Airspace.";
      else
         return "Free.";
      end if;
   end Landing_Approach_To_String;

   -- Function to convert the runway status to a string for output to console.
   function Runway_Status_To_String
     (Runway_Status : Runway_Status_Type) return String
   is
   begin
      if (Runway_Status = Occupied_Takeoff) then
         return "Occupied - Plane taking off.";
      elsif (Runway_Status = Occupied_Landed) then
         return "Occupied - Plane landing.";
      else
         return "Available.";
      end if;
   end Runway_Status_To_String;

   -- A plane must taxi to the runway before requesting takeoff.
   -- Runway must be available and selected east/west airspace must be free.
   procedure Taxi_To_Runway
     (ATC_Status : in out ATC_Status_Type; Direction : in Direction_Type)
   is
   begin
      AS_Put_Line ("Requesting taxi to runway...");
      -- Check Runway is empty
      if (ATC_Status.Runway_Status = Available) then
         -- Check no other plane is landing in east/west airspace.
         if (Direction = East and ATC_Status.Landing_Approach.East = Free) then
            -- Set Runway to Occupied & Airspace to reserved
            ATC_Status.Runway_Status         := Occupied_Takeoff;
            ATC_Status.Landing_Approach.East := Reserved_Exit;
            AS_Put_Line ("Permission to depart towards the East granted.");
         elsif (Direction = West and ATC_Status.Landing_Approach.West = Free)
         then
            -- Same as above, if approaching from West.
            ATC_Status.Runway_Status         := Occupied_Takeoff;
            ATC_Status.Landing_Approach.West := Reserved_Exit;
            AS_Put_Line ("Permission to depart towards the West granted.");
         else
            AS_Put_Line ("Cannot take off - requested airspace reserved.");
         end if;
      else
         AS_Put_Line ("Cannot take off - runway occupied.");
      end if;
   end Taxi_To_Runway;

   -- Before landing, planes must request entry to the airspace and reserve
   -- a slot ready to land.
   procedure Enter_Landing_Airspace
     (ATC_Status : in out ATC_Status_Type; Direction : in Direction_Type)
   is
   begin
      AS_Put_Line ("Requesting permission to approach airport airspace...");
      -- Check no other plane has reserved approach airspace.
      if (Direction = East and ATC_Status.Landing_Approach.East = Free) then
         -- Reserve easrtern airspace
         ATC_Status.Landing_Approach.East := Reserved_Enter;
         AS_Put_Line ("Eastern approach airspace reserved");
      elsif (Direction = West and ATC_Status.Landing_Approach.West = Free) then
         -- Same as above, if approaching from West.
         ATC_Status.Landing_Approach.West := Reserved_Enter;
         AS_Put_Line ("Western approach airspace reserved");
      else
         AS_Put_Line ("Cannot approach airport, airspace already reserved.");
      end if;
   end Enter_Landing_Airspace;

   -- If a plane is on the runway and prepared to take off, it can request a take off.
   -- Airspace in chosen direction must be reserved to do so.
   procedure Execute_Takeoff
     (ATC_Status : in out ATC_Status_Type; Direction : in Direction_Type)
   is
   begin
      AS_Put_Line ("Attempting to take off...");
      -- Check Runway is Occupied
      if (ATC_Status.Runway_Status = Occupied_Takeoff) then
         -- Check no other plane is landing in east/west airspace.
         if
           (Direction = East and
            ATC_Status.Landing_Approach.East = Reserved_Exit)
         then
            -- Set Runway to Occupied & Airspace to reserved
            ATC_Status.Runway_Status         := Available;
            ATC_Status.Landing_Approach.East := Free;
            AS_Put_Line ("Take off successful. Leaving Eastern airspace.");
         elsif
           (Direction = West and
            ATC_Status.Landing_Approach.West = Reserved_Exit)
         then
            -- Same as above, if approaching from West.
            ATC_Status.Runway_Status         := Available;
            ATC_Status.Landing_Approach.West := Free;
            AS_Put_Line ("Take off successful. Leaving Western airspace.");
         else
            AS_Put_Line
              ("Cannot take off - Requested airspace not reserved for take-off.");
         end if;
      else
         AS_Put_Line ("Cannot take off - Runway occupied.");
      end if;
   end Execute_Takeoff;

   -- If a plane has reserved the approach airspace, it can request to land
   -- if the runway is available.
   procedure Request_Landing
     (ATC_Status : in out ATC_Status_Type; Direction : in Direction_Type)
   is
   begin
      -- Runway is not free. Cannot land
      if (ATC_Status.Runway_Status /= Available) then
         AS_Put_Line ("Cannot land. Runway currently in use.");
         -- Runway is free and airspace has been reserved.
      elsif (ATC_Status.Runway_Status = Available) and
        ((Direction = East and
          ATC_Status.Landing_Approach.East = Reserved_Enter) or
         (Direction = West and
          ATC_Status.Landing_Approach.West = Reserved_Enter))
      then
         ATC_Status.Runway_Status := Occupied_Landed;
         -- Check approach direction again
         if (Direction = East) then
            -- free up airspace behind.
            ATC_Status.Landing_Approach.East := Free;
            AS_Put_Line ("Successfully landed from East. Stopped on runway.");
         elsif (Direction = West) then
            ATC_Status.Landing_Approach.West := Free;
            AS_Put_Line ("Successfully landed from West. Stopped on runway.");
         end if;
      else
         AS_Put_Line ("No planes cleared to approach from this direction.");
      end if;
   end Request_Landing;

-- If a plane is on the runway after landing, it can taxi to the arrivals gate.
-- This clears the runway for other planes.
   procedure Taxi_To_Gate (ATC_Status : in out ATC_Status_Type) is
   begin
      -- Check plane has just landed
      if (ATC_Status.Runway_Status = Occupied_Landed) then
         ATC_Status.Runway_Status := Available;
         AS_Put_Line ("Successfully left runway.");
      else
         AS_Put_Line ("No plane landed.");
      end if;
   end Taxi_To_Gate;

   -- Prints the ATC system status to the console.
   -- Called at the end of every main loop.
   procedure Print_Runway_Status (ATC_Status : in ATC_Status_Type) is
   begin
      AS_Put_Line ("Airspace status...");
      AS_Put ("East approach: ");
      AS_Put (Landing_Approach_To_String (ATC_Status.Landing_Approach.East));
      AS_Put_Line ("");
      AS_Put ("West approach: ");
      AS_Put (Landing_Approach_To_String (ATC_Status.Landing_Approach.West));
      AS_Put_Line ("");

      AS_Put ("Runway status: ");
      AS_Put (Runway_Status_To_String (ATC_Status.Runway_Status));
      AS_Put_Line ("");
   end Print_Runway_Status;

end ATC_Controller;
