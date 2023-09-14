# Air Traffic Control Simulation

This command line program is designed to model a simple automated air traffic control (ATC) system using SPARK Ada. The system aims to manage arrivals and departures of aircraft on a single runway. The pilot can request an operation such as take-off or land, and the system checks whether this action can be safely performed given the current system sate. The ATC controller then returns an instruction such as granting approval or indicating the pilot must wait for the runway to be available. In this simplified system, the pilot can choose to land or take-off from the eastern or western approaches to the runway.

## Usage

For input, the user can issue one of five command line options which aim to simulate requests given by pilots to the ATC. For each command except for ‘Taxi to Gate’, the user must enter an intended direction of travel (East or West). The five commands available to the user are shown below:
1. Enter Landing Airspace – If the chosen approach airspace is available, reserve this airspace. Otherwise, if airspace is reserved then wait for slot.
2. Request Landing – If east/west approach is reserved for landing and runway is available, permit aircraft to land, otherwise deny permission.
3. Taxi To Gate – If the runway is occupied by a landed plane, permit this plane to exit the runway.
4. Taxi To Runway – If the runway is available and the chosen direction airspace is free then reserve
this airspace and occupy the runway ready for take-off.
5. Execute Take-off – If there is a plane on the runway ready to take-off, and the chosen airspace is
reserved for take-off then permit the request, otherwise deny request.

## Example Input Sequences

### Example 1 - Successful Landing
- Aircraft 1: Enter airspace from East -> land on available runway -> taxi to gate.

### Example 2 - Request to land on occupied runway:
- Aircraft 1: Taxi to runway, ready for departing West.
- Aircraft 2: Enter airspace from East -> Request Landing from East (Denied).

### Example 3 – Request to enter reserved airspace followed by successful take-off:
- Aircraft 1: Enter airspace from West.
- Aircraft 2: Request Taxi to runway heading East (allowed).
- Aircraft 3: Enter airspace from East (denied, reserved by Aircraft 2).
- Aircraft 2: Execute take-off heading East.
