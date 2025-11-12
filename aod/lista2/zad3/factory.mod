set T;

param normal_cap >= 0;
param overtime_cap{T} >= 0;
param c{T} >= 0;
param o{T} >= 0;
param d{T} >= 0;
param store_cost >= 0;
param store_cap >= 0;
param init_inv >= 0;

var x{t in T} >= 0, <= normal_cap;
var y{t in T} >= 0, <= overtime_cap[t];
var s{t in T} >= 0, <= store_cap;

minimize TotalCost:
    sum{t in T} ( c[t]*x[t] + o[t]*y[t] + store_cost*s[t] );

# bilans dla okresu 1
s.t. balance1:
    init_inv + x[1] + y[1] - d[1] = s[1];

# bilans dla okresów 2..K
s.t. balance_rest{t in T: t <> 1}:
    s[t-1] + x[t] + y[t] - d[t] = s[t];
