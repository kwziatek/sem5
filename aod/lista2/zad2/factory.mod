
set product;
set machine;

/*params*/
param working_time >= 0;
param max_demand{product} >= 0;
param profit{product} >= 0;
param working_costs{machine} >= 0;
param material_costs{product} >= 0;
param creating_time{product, machine} >= 0;

/*variables*/ 
var production{product, machine} >= 0;

/*objective maximum income function*/ 
maximize income: sum{i in product, j in machine} (profit[i] - material_costs[i] - working_costs[j] * creating_time[i, j] / 60) * production[i, j];

/*constraints*/ 
s.t. machine_available{j in machine}: sum{i in product} production[i, j] * creating_time[i, j] / 60 <= working_time;
s.t. providing_demand{i in product}: sum{j in machine} production[i, j] <= max_demand[i];