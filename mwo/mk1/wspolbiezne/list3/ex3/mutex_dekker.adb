with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Random_Seeds; use Random_Seeds;
with Ada.Real_Time; use Ada.Real_Time;

procedure Mutex_Dekker is

   -- Processes
   Nr_Of_Processes : constant Integer := 2;  -- Set to 2 for Dekker's algorithm

   Min_Steps : constant Integer := 50;
   Max_Steps : constant Integer := 100;
   Min_Delay : constant Duration := 0.01;
   Max_Delay : constant Duration := 0.05;

   -- States of a Process
   type Process_State is (
      Local_Section,
      Entry_Protocol,
      Critical_Section,
      Exit_Protocol
   );

   -- 2D Board display board
   Board_Width  : constant Integer := Nr_Of_Processes;
   Board_Height : constant Integer := Process_State'Pos(Process_State'Last) + 1;

   -- Timing
   Start_Time : Time := Clock;  -- global starting time

   -- Random seeds for the tasks' random number generators
   Seeds : Seed_Array_Type(1 .. Nr_Of_Processes) := Make_Seeds(Nr_Of_Processes);

   -- Dekker's algorithm variables
   type Want_Array is array (0 .. 1) of Boolean;  -- Named array type

   protected type Shared_Variables is
      procedure Set_Want(Pid : Integer; Value : Boolean);
      function Get_Want(Pid : Integer) return Boolean;
      procedure Set_Turn(Value : Integer);
      function Get_Turn return Integer;
   private
      Want : Want_Array := (False, False);  -- Use named type
      Turn : Integer range 0 .. 1 := 0;
   end Shared_Variables;

   protected body Shared_Variables is
      procedure Set_Want(Pid : Integer; Value : Boolean) is
      begin
         Want(Pid) := Value;
      end Set_Want;

      function Get_Want(Pid : Integer) return Boolean is
      begin
         return Want(Pid);
      end Get_Want;

      procedure Set_Turn(Value : Integer) is
      begin
         Turn := Value;
      end Set_Turn;

      function Get_Turn return Integer is
      begin
         return Turn;
      end Get_Turn;
   end Shared_Variables;

   Dekker_Vars : Shared_Variables;

   -- Types, procedures, and functions
   type Position_Type is record
      X : Integer range 0 .. Board_Width - 1;
      Y : Integer range 0 .. Board_Height - 1;
   end record;

   type Trace_Type is record
      Time_Stamp : Duration;
      Id : Integer;
      Position : Position_Type;
      Symbol : Character;
   end record;

   type Trace_Array_Type is array (0 .. Max_Steps) of Trace_Type;

   type Traces_Sequence_Type is record
      Last : Integer := -1;
      Trace_Array : Trace_Array_Type;
   end record;

   procedure Print_Trace(Trace : Trace_Type) is
      Symbol : String := (' ', Trace.Symbol);
   begin
      Put_Line(
         Duration'Image(Trace.Time_Stamp) & " " &
         Integer'Image(Trace.Id) & " " &
         Integer'Image(Trace.Position.X) & " " &
         Integer'Image(Trace.Position.Y) & " " &
         Symbol
      );
   end Print_Trace;

   procedure Print_Traces(Traces : Traces_Sequence_Type) is
   begin
      for I in 0 .. Traces.Last loop
         Print_Trace(Traces.Trace_Array(I));
      end loop;
   end Print_Traces;

   -- Task Printer collects and prints reports of traces and the line with the parameters
   task Printer is
      entry Report(Traces : Traces_Sequence_Type);
   end Printer;

   task body Printer is
   begin
      -- Collect and print the traces
      for I in 1 .. Nr_Of_Processes loop
         accept Report(Traces : Traces_Sequence_Type) do
            Print_Traces(Traces);
         end Report;
      end loop;

      -- Print the line with the parameters needed for display script
      Put(
         "-1 " &
         Integer'Image(Nr_Of_Processes) & " " &
         Integer'Image(Board_Width) & " " &
         Integer'Image(Board_Height) & " "
      );
      for I in Process_State'Range loop
         Put(I'Image & ";");
      end loop;
      Put_Line("TURN=" & Integer'Image(Dekker_Vars.Get_Turn) & ";");
   end Printer;

   -- Processes
   type Process_Type is record
      Id : Integer;
      Symbol : Character;
      Position : Position_Type;
   end record;

   task type Process_Task_Type is
      entry Init(Id : Integer; Seed : Integer; Symbol : Character);
      entry Start;
   end Process_Task_Type;

   task body Process_Task_Type is
      G : Generator;
      Process : Process_Type;
      Time_Stamp : Duration;
      Nr_of_Steps : Integer;
      Traces : Traces_Sequence_Type;

      procedure Store_Trace is
      begin
         Traces.Last := Traces.Last + 1;
         Traces.Trace_Array(Traces.Last) := (
            Time_Stamp => Time_Stamp,
            Id => Process.Id,
            Position => Process.Position,
            Symbol => Process.Symbol
         );
      end Store_Trace;

      procedure Change_State(State : Process_State) is
      begin
         Time_Stamp := To_Duration(Clock - Start_Time);
         Process.Position.Y := Process_State'Pos(State);
         Store_Trace;
      end Change_State;

   begin
      accept Init(Id : Integer; Seed : Integer; Symbol : Character) do
         Reset(G, Seed);
         Process.Id := Id;
         Process.Symbol := Symbol;
         Process.Position := (
            X => Id,
            Y => Process_State'Pos(Local_Section)
         );
         Nr_of_Steps := Min_Steps + Integer(Float(Max_Steps - Min_Steps) * Random(G));
         Time_Stamp := To_Duration(Clock - Start_Time);
         Store_Trace;
      end Init;

      accept Start do
         null;
      end Start;

      for Step in 0 .. Nr_of_Steps / 4 - 1 loop
         -- LOCAL_SECTION
         delay Min_Delay + (Max_Delay - Min_Delay) * Duration(Random(G));

         Change_State(Entry_Protocol);
         -- Dekker's Entry Protocol
         declare
            Other : Integer := 1 - Process.Id;  -- Other process ID (0 or 1)
         begin
            Dekker_Vars.Set_Want(Process.Id, True);
            while Dekker_Vars.Get_Want(Other) loop
               if Dekker_Vars.Get_Turn /= Process.Id then
                  Dekker_Vars.Set_Want(Process.Id, False);
                  while Dekker_Vars.Get_Turn /= Process.Id loop
                     delay 0.001;  -- Small delay to prevent busy waiting
                  end loop;
                  Dekker_Vars.Set_Want(Process.Id, True);
               end if;
            end loop;
            Dekker_Vars.Set_Turn(Other);
         end;

         Change_State(Critical_Section);
         -- CRITICAL_SECTION
         delay Min_Delay + (Max_Delay - Min_Delay) * Duration(Random(G));

         Change_State(Exit_Protocol);
         -- Dekker's Exit Protocol
         Dekker_Vars.Set_Want(Process.Id, False);

         Change_State(Local_Section);
      end loop;

      Printer.Report(Traces);
   end Process_Task_Type;

   -- Local for main task
   Process_Tasks : array (0 .. Nr_Of_Processes - 1) of Process_Task_Type;
   Symbol : Character := 'A';

begin
   -- Initialize process tasks
   for I in Process_Tasks'Range loop
      Process_Tasks(I).Init(I, Seeds(I + 1), Symbol);
      Symbol := Character'Succ(Symbol);
   end loop;

   -- Start process tasks
   for I in Process_Tasks'Range loop
      Process_Tasks(I).Start;
   end loop;
end Mutex_Dekker;