with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Random_Seeds; use Random_Seeds;
with Ada.Real_Time; use Ada.Real_Time;

procedure Bakery_Algorithm is

   -- Processes
   Nr_Of_Processes : constant Integer := 15;
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

   -- Define array types for Bakery Algorithm
   type Boolean_Array is array(0 .. Nr_Of_Processes - 1) of Boolean;
   type Integer_Array is array(0 .. Nr_Of_Processes - 1) of Integer;

   -- Bakery Algorithm shared variables
   protected type Shared_Data is
      procedure Set_Choosing(I : Integer; Value : Boolean);
      function Get_Choosing(I : Integer) return Boolean;
      procedure Set_Ticket(I : Integer; Value : Integer);
      function Get_Ticket(I : Integer) return Integer;
   private
      Choosing : Boolean_Array := (others => False);
      Tickets  : Integer_Array := (others => 0);
   end Shared_Data;

   protected body Shared_Data is
      procedure Set_Choosing(I : Integer; Value : Boolean) is
      begin
         Choosing(I) := Value;
      end Set_Choosing;

      function Get_Choosing(I : Integer) return Boolean is
      begin
         return Choosing(I);
      end Get_Choosing;

      procedure Set_Ticket(I : Integer; Value : Integer) is
      begin
         Tickets(I) := Value;
      end Set_Ticket;

      function Get_Ticket(I : Integer) return Integer is
      begin
         return Tickets(I);
      end Get_Ticket;
   end Shared_Data;

   Bakery : Shared_Data;

   -- Types, procedures and functions
   type Position_Type is record
      X: Integer range 0 .. Board_Width - 1;
      Y: Integer range 0 .. Board_Height - 1;
   end record;

   type Trace_Type is record
      Time_Stamp : Duration;
      Id : Integer;
      Position : Position_Type;
      Symbol : Character;
   end record;

   type Trace_Array_type is array(0 .. Max_Steps) of Trace_Type;

   type Traces_Sequence_Type is record
      Last : Integer := -1;
      Trace_Array : Trace_Array_type;
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

   task Printer is
      entry Report(Traces : Traces_Sequence_Type);
   end Printer;

   task body Printer is
      Max_Ticket : Integer := 0;
   begin
      for I in 1 .. Nr_Of_Processes loop
         accept Report(Traces : Traces_Sequence_Type) do
            Print_Traces(Traces);
            -- Update Max_Ticket by checking all traces
            for J in 0 .. Traces.Last loop
               if Traces.Trace_Array(J).Position.Y = Process_State'Pos(Critical_Section) then
                  Max_Ticket := Integer'Max(Max_Ticket, Traces.Trace_Array(J).Id);
               end if;
            end loop;
         end Report;
      end loop;

      Put(
         "-1 " &
         Integer'Image(Nr_Of_Processes) & " " &
         Integer'Image(Board_Width) & " " &
         Integer'Image(Board_Height) & " "
      );
      for I in Process_State'Range loop
         Put(I'Image & ";");
      end loop;
      Put_Line("MAX_TICKET=" & Integer'Image(Max_Ticket) & ";");
   end Printer;

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
      end;

      function Max_Ticket return Integer is
         Max : Integer := 0;
      begin
         for I in 0 .. Nr_Of_Processes - 1 loop
            Max := Integer'Max(Max, Bakery.Get_Ticket(I));
         end loop;
         return Max;
      end Max_Ticket;

      function Has_Priority(Other_Id : Integer) return Boolean is
         My_Ticket : Integer := Bakery.Get_Ticket(Process.Id);
         Other_Ticket : Integer := Bakery.Get_Ticket(Other_Id);
      begin
         return (My_Ticket > Other_Ticket) or
                (My_Ticket = Other_Ticket and Process.Id > Other_Id);
      end Has_Priority;

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

      for Step in 0 .. Nr_of_Steps/4 - 1 loop
         -- LOCAL_SECTION
         delay Min_Delay + (Max_Delay - Min_Delay) * Duration(Random(G));

         Change_State(Entry_Protocol);
         -- ENTRY_PROTOCOL (Bakery Algorithm)
         Bakery.Set_Choosing(Process.Id, True);
         Bakery.Set_Ticket(Process.Id, Max_Ticket + 1);
         Bakery.Set_Choosing(Process.Id, False);

         for J in 0 .. Nr_Of_Processes - 1 loop
            if J /= Process.Id then
               -- Wait until process J is not choosing
               while Bakery.Get_Choosing(J) loop
                  delay 0.001;
               end loop;
               -- Wait until process J has no ticket or has lower priority
               while Bakery.Get_Ticket(J) /= 0 and then Has_Priority(J) loop
                  delay 0.001;
               end loop;
            end if;
         end loop;

         Change_State(Critical_Section);
         -- CRITICAL_SECTION
         delay Min_Delay + (Max_Delay - Min_Delay) * Duration(Random(G));

         Change_State(Exit_Protocol);
         -- EXIT_PROTOCOL (Bakery Algorithm)
         Bakery.Set_Ticket(Process.Id, 0);

         Change_State(Local_Section);
      end loop;

      Printer.Report(Traces);
   end Process_Task_Type;

   Process_Tasks : array(0 .. Nr_Of_Processes - 1) of Process_Task_Type;
   Symbol : Character := 'A';

begin
   for I in Process_Tasks'Range loop
      Process_Tasks(I).Init(I, Seeds(I + 1), Symbol);
      Symbol := Character'Succ(Symbol);
   end loop;

   for I in Process_Tasks'Range loop
      Process_Tasks(I).Start;
   end loop;
end Bakery_Algorithm;