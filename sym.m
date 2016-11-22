(* ::Package:: *)

(*
INPUT (common names for all modules);

time : time in seconds for running the procedure;
ncores : number of cores to be used;
uops : list of unary operations;
bops : list of binary operations;
vars : list of variables and constants;
nops : max number of operations used in expression;
*)



(*
Runs symbolic Monte Carlo using multiple cores;

OUTPUT (list);

1st element is the accumulated list of top 100 models;
2nd element is the accumulated number of iterations;
*)

Search[time_,ncores_,uops_,bops_,vars_,nops_]:=Module[{arg,res},

arg=Table[time,ncores];
res=ParallelMap[Search1[#,uops,bops,vars,nops]&,arg];

{SortBy[Flatten[res[[All,1]],1],First][[1;;100]],Total[res[[All,2]]]}

]



(*
Runs symbolic Monte Carlo on a single core;

OUTPUT (list);

1st element is the list of top 100 models;
2nd element is the number of iterations;
*)

Search1[time_,uops_,bops_,vars_,nops_]:=Module[{top100,nit,expr,error},

top100=Table[{Infinity,"???"},100];
nit=0;

TimeConstrained[
Quiet@While[True,
expr=RandomExpression[uops,bops,vars,nops];
error=Error[expr];
nit++;

If[(error<top100[[100,1]])&&(Select[top100[[All,2]],#==expr&]=={}),
top100=SortBy[Append[Most[top100],{error,expr}],First]]
]
,time];

{top100,nit}

]



(*
Generates a random expression from given operations/variables;

OUTPUT (expression);

random expression
*)

RandomExpression[uops_,bops_,vars_,nops_]:=Module[{u,b,expr,leaf,nleaves,index,optype},

u:=RandomChoice[uops];
b:=RandomChoice[bops];

expr=leaf[1];
nleaves=1;

Do[
index=RandomInteger[{1,nleaves}];
optype=RandomChoice[{1,2}];

If[optype==1,
expr=(expr/.leaf[index]->u[leaf[index]]),
expr=(expr/.leaf[index]->b[leaf[index],leaf[nleaves+1]]);nleaves++
]
,RandomInteger[{0,nops}]];

expr/.leaf[_]:>RandomChoice[vars]

]
