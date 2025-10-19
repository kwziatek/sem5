-- Copyright (C) 2006 M. Ben-Ari, modified for improved synchronization
package Monitor_Package is
   -- Monitor task to ensure mutual exclusion
   task Monitor is
      entry Enter;
      entry Leave;
   end Monitor;

   -- Condition variable task for synchronization
   task type Condition is
      entry Pre_Wait;
      entry Wait;
      entry Signal;
      entry Waiting(B: out Boolean);
   end Condition;

   -- Function to check if condition queue is non-empty
   function Non_Empty(C: Condition) return Boolean;

   -- Procedure to safely wait on a condition
   procedure Wait(C: in out Condition);
end Monitor_Package;