
set company;
set airport;

/*parameters*/ 
param demand{airport} >= 0;
param supply{company} >= 0;
param price{airport, company} >= 0;

/*variables*/ 
var purchase{airport, company} >= 0;

/*objective function to minimize costs*/ 
minimize total_cost: sum{i in airport, j in company} price[i, j] * purchase[i, j];

/*constraints*/
s.t. requirement{i in airport}: sum{j in company} purchase[i, j] = demand[i];
s.t. capacity{j in company}: sum{i in airport} purchase[i, j] <= supply[j];
s.t. demand_supply: sum{i in airport} demand[i] <= sum{j in company} supply[j];