-- Author: Tim Deville (2003506)
-- Date: 05/12/22
-- Package to model an automated Air traffic Control system.
pragma SPARK_Mode (On);
with SPARK.Text_IO; use SPARK.Text_IO;

package ATC_Controller is
   type Runway_Status_Type is (Occupied_Takeoff, Occupied_Landed, Available);
   type Airspace_Status_Type is (Reserved_Exit, Reserved_Enter, Free);
   type Direction_Type is (East, West);

   type Landing_Approach_Type is record
      East, West : Airspace_Status_Type;
   end record;

   type ATC_Status_Type is record
      Runway_Status    : Runway_Status_Type;
      Landing_Approach : Landing_Approach_Type;
   end record;

   -- Expression function to check deadlock conditions which should not occur.
   -- If a plane is on runway ready to take-off, then airspace in one direction
   -- must be reserved.
   function No_Deadlock (ATC_Status : ATC_Status_Type) return Boolean is
     (if (ATC_Status.Runway_Status = Occupied_Takeoff) then
        (ATC_Status.Landing_Approach.East = Reserved_Exit or
         ATC_Status.Landing_Approach.West = Reserved_Exit));

   procedure Execute_Takeoff
     (ATC_Status : in out ATC_Status_Type; Direction : in Direction_Type) with
      Depends => (ATC_Status => (ATC_Status, Direction),
       Standard_Output => (Standard_Output, ATC_Status, Direction)),
      Pre  => (No_Deadlock (ATC_Status)),
      Post =>
      (if
         (ATC_Status.Runway_Status'Old = Occupied_Takeoff and
          Direction = East and
          ATC_Status.Landing_Approach.East'Old = Reserved_Exit)
       then
         ATC_Status.Landing_Approach.East = Free and
         ATC_Status.Runway_Status = Available
       else
         (ATC_Status.Landing_Approach.East =
          ATC_Status.Landing_Approach.East'Old)) and
      (if
         (ATC_Status.Runway_Status'Old = Occupied_Takeoff and
          Direction = West and
          ATC_Status.Landing_Approach.West'Old = Reserved_Exit)
       then
         ATC_Status.Landing_Approach.West = Free and
         ATC_Status.Runway_Status = Available
       else
         (ATC_Status.Landing_Approach.West =
          ATC_Status.Landing_Approach.West'Old)) and
      (if
         (ATC_Status.Runway_Status'Old = Occupied_Landed or
          ATC_Status.Runway_Status'Old = Available)
       then ATC_Status = ATC_Status'Old) and
      No_Deadlock (ATC_Status);

   procedure Enter_Landing_Airspace
     (ATC_Status : in out ATC_Status_Type; Direction : in Direction_Type) with
      Depends => (ATC_Status => (ATC_Status, Direction),
       Standard_Output => (Standard_Output, ATC_Status, Direction)),
      Pre  => (No_Deadlock (ATC_Status)),
      Post =>
      (if (Direction = East and ATC_Status.Landing_Approach.East'Old = Free)
       then ATC_Status.Landing_Approach.East = Reserved_Enter
       else ATC_Status.Landing_Approach.East =
         ATC_Status.Landing_Approach.East'Old) and
      (if (Direction = West and ATC_Status.Landing_Approach.West'Old = Free)
       then ATC_Status.Landing_Approach.West = Reserved_Enter
       else ATC_Status.Landing_Approach.West =
         ATC_Status.Landing_Approach.West'Old) and
      No_Deadlock (ATC_Status);

   procedure Taxi_To_Runway
     (ATC_Status : in out ATC_Status_Type; Direction : in Direction_Type) with
      Depends => (ATC_Status => (ATC_Status, Direction),
       Standard_Output => (Standard_Output, ATC_Status, Direction)),
      Pre  => (No_Deadlock (ATC_Status)),
      Post =>
      (if
         (ATC_Status.Runway_Status'Old = Available and Direction = East and
          ATC_Status.Landing_Approach.East'Old = Free)
       then
         ATC_Status.Landing_Approach.East = Reserved_Exit and
         ATC_Status.Runway_Status = Occupied_Takeoff
       else
         (ATC_Status.Landing_Approach.East =
          ATC_Status.Landing_Approach.East'Old)) and
      (if
         (ATC_Status.Runway_Status'Old = Available and Direction = West and
          ATC_Status.Landing_Approach.West'Old = Free)
       then
         ATC_Status.Landing_Approach.West = Reserved_Exit and
         ATC_Status.Runway_Status = Occupied_Takeoff
       else
         (ATC_Status.Landing_Approach.West =
          ATC_Status.Landing_Approach.West'Old)) and
      (if
         (ATC_Status.Runway_Status'Old = Occupied_Landed or
          ATC_Status.Runway_Status'Old = Occupied_Takeoff)
       then ATC_Status = ATC_Status'Old) and
      No_Deadlock (ATC_Status);

   procedure Request_Landing
     (ATC_Status : in out ATC_Status_Type; Direction : in Direction_Type) with
      Depends => (ATC_Status => (ATC_Status, Direction),
       Standard_Output => (Standard_Output, ATC_Status, Direction)),
      Pre  => (No_Deadlock (ATC_Status)),
      Post =>
      (if
         (ATC_Status.Runway_Status'Old = Available and Direction = East and
          ATC_Status.Landing_Approach.East'Old = Reserved_Enter)
       then
         ATC_Status.Landing_Approach.East = Free and
         ATC_Status.Runway_Status = Occupied_Landed
       else
         (ATC_Status.Landing_Approach.East =
          ATC_Status.Landing_Approach.East'Old)) and
      (if
         (ATC_Status.Runway_Status'Old = Available and Direction = West and
          ATC_Status.Landing_Approach.West'Old = Reserved_Enter)
       then
         ATC_Status.Landing_Approach.West = Free and
         ATC_Status.Runway_Status = Occupied_Landed
       else
         (ATC_Status.Landing_Approach.West =
          ATC_Status.Landing_Approach.West'Old)) and
      (if
         (ATC_Status.Runway_Status'Old = Occupied_Landed or
          ATC_Status.Runway_Status'Old = Occupied_Takeoff)
       then ATC_Status = ATC_Status'Old) and
      No_Deadlock (ATC_Status);

   procedure Taxi_To_Gate (ATC_Status : in out ATC_Status_Type) with
      Depends => (ATC_Status => (ATC_Status),
       Standard_Output => (Standard_Output, ATC_Status)),
      Pre  => (No_Deadlock (ATC_Status)),
      Post =>
      (if (ATC_Status.Runway_Status'Old = Occupied_Landed) then
         ATC_Status.Runway_Status = Available
       else ATC_Status.Runway_Status = ATC_Status.Runway_Status'Old) and
      (No_Deadlock (ATC_Status));

   procedure Initialse_ATC (ATC_Status : out ATC_Status_Type) with
      Depends => (ATC_Status => null),
      Post    => (No_Deadlock (ATC_Status));

   procedure Print_Runway_Status (ATC_Status : in ATC_Status_Type) with
      Global  => (In_Out => Standard_Output),
      Depends => (Standard_Output => (Standard_Output, ATC_Status));

end ATC_Controller;
