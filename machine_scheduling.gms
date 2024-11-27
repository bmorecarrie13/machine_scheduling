$title Job Scheduling Exercise
$title Carrie Ward


* DATA ENTRY
Set m 'Machine, ie A,B,C' /A,B,C/;
Set u 'Unit, ie A1' /A1*A2, B1*B3, C1*C3/;

Set machine(m,u) 'Machine-unit, mapping of unit to machine (ex, A1 to A)';

machine('A','A1') = yes;
machine('A','A2') = yes;

machine('B','B1') = yes;
machine('B','B2') = yes;
machine('B','B3') = yes;

machine('C','C1') = yes;
machine('C','C2') = yes;
machine('C','C3') = yes;

Set p 'Product' /1*10/;

set o 'Job Number' /j1*j10/;

Set c 'Product Category' /x,y,z/;
set product_category(p,c) 'Product Category assignment';
product_category('1','x') = yes;
product_category('2','y') = yes;
product_category('3','z') = yes;
product_category('4','x') = yes;
product_category('5','y') = yes;
product_category('6','z') = yes;
product_category('7','z') = yes;
product_category('8','y') = yes;
product_category('9','z') = yes;
product_category('10','x') = yes;

Parameters
    t(p,m)    'Processing times for each product on each machine'
    / 1.A 10, 1.B 20, 1.C 15,
      2.A 15, 2.B 30, 2.C 25,
      3.A 10, 3.B 40, 3.C 5,
      4.A 20, 4.B 10, 4.C 25,
      5.A 10, 5.B 20, 5.C 15,
      6.A 15, 6.B 30, 6.C 25,
      7.A 10, 7.B 20, 7.C 25,
      8.A 20, 8.B 10, 8.C 25,
      9.A 10, 9.B 30, 9.C 25,
      10.A 15, 10.B 20, 10.C 15 /
;

Scalar
    penalty 'Penalty for consecutive same product types' / 25 /
    max_t 'Big M scalar for upper bound set as the max total time'
;

max_t = sum((p,m), t(p,m));


alias(m, mi);
alias(m, mj);

alias(o, oi);
alias(o, oj);

alias(p, pi);
alias(p, pj);


Set order(mi, mj) 'process order pairs, ex A,B';
order('A','B') = yes;
order('B','C') = yes;

* --
* Variables

Binary Variables
    y(u,o,p) '1 if product P is scheduled on machine-unit U for job number O '
    z(u,c) '1 if the same product category is scheduled on the same machine-unit U for consecutive jobs'
;

Positive Variables x_start(u,o,p) 'Start time of product P on machine-unit U for job number O';

Variable obj 'Objective function - max processing time + penalties';
Positive Variable x_makespan 'Max processing time for the objective function';

x_start.up(u,o,p) = max_t;
x_makespan.up = max_t;


* --
* Equations

Equation set_next_start(u,o,p) 'Set the start time on or after the end time of previous job (O) per unit U';

set_next_start(u,oj,pj)$(ord(oj)>1) .. x_start(u,oj,pj) + max_t*(1-y(u,oj,pj)) =g= sum((oi,pi)$(ord(oi)=(ord(oj)-1)), x_start(u,oi,pi) + sum(machine(m,u), t(pi,m)*y(u,oi,pi)));

equation link_constraint(u,o,p) 'Link variables x_start and y together';
link_constraint(u,o,p) .. x_start(u,o,p) =l= max_t*y(u,o,p);

Equation set_sequence(u,o);
set_sequence(u,oi)$(ord(oi)<card(oi)) .. sum(p, card(oi)*y(u,oi,p)) =g= sum((p,oj)$(ord(oi)=(ord(oj)-1)), y(u,oj,p));

Equation assign_unique_product(u,o);
assign_unique_product(u,o) .. sum(p, y(u,o,p)) =l= 1;

Equation find_consecutive_products(u,o,c);
find_consecutive_products(u,oj,c).. sum((product_category(p,c), oi)$(ord(oi)=(ord(oj)-1)), y(u,oi,p)) + sum(product_category(p,c), y(u,oj,p)) =l= z(u,c)+1;

Equation set_process_order(p,mi,mj) 'Processing order, ie machine A must be processed before B and B before C';
set_process_order(p,order(mi,mj)).. sum((machine(mi,u),o), x_start(u,o,p) + t(p,mi)*y(u,o,p)) =l= sum((machine(mj,u),o), x_start(u,o,p));

Equation force_all_scheduled(p,m);
force_all_scheduled(p,m) .. sum((machine(m,u),o), y(u,o,p)) =e= 1;
             
Equation set_makespan(p,m) 'Calculate the max processing time (makespan)';
set_makespan(p,m)$(ord(m)=card(m)).. sum((o,machine(m,u)), x_start(u,o,p) + t(p,m)*y(u,o,p)) =l= x_makespan;

Equation set_obj 'Calculate the objective function';
set_obj.. obj =e= x_makespan + sum((u,c), penalty*z(u,c));

* --
* Solve      

Model machine_scheduling / all/;

machine_scheduling.optFile = 1;
machine_scheduling.holdfixed = 1;
option mip = cplex;
solve machine_scheduling using mip minimizing obj;


* output for post-solve analysis
variable output(p,c,u,o);
output.l(p,c,u,o)$(y.l(u,o,p)>0.01 and product_category(p,c)) = y.l(u,o,p);
output.lo(p,c,u,o)$(y.l(u,o,p)>0.01 and product_category(p,c)) = x_start.l(u,o,p);
output.up(p,c,u,o)$(y.l(u,o,p)>0.01 and product_category(p,c)) = x_start.l(u,o,p)+sum(machine(m,u),t(p,m))*y.l(u,o,p);
