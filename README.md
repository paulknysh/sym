# sym: A Mathematica package for parallel symbolic regression using Monte Carlo

## What is this?

A simple method for automatic construction of a symbolic model from given data. User needs to provide an error function (of how well a given model fits the data) and some basic building blocks: operations, variables, constants. A Monte Carlo approach is used: a large number of random models is generated to find the best ones. Procedure scales on multicore CPUs by running several independent Monte Carlo loops in parallel and subsequently accumulating obtained results.

## How do I represent my error function?

A Mathematica function/module called `Error` needs to be defined by user:
```mathematica
Error[expr_]:=...
```
`expr` is a symbolic expression. Function has to return a **non-negative** error value that is being **minimized**.

## How do I run the procedure?

Just like that (minimizing an error):
```mathematica
Get["...\\sym.m"]


Error[expr_]:=...


time=60; (*time in seconds for running the procedure*)
ncores=4; (*number of cores to be used*)
uops={#^2&,Abs[#]^(1/2)&,Log[Abs[#]]&}; (*list of unary operations*)
bops={Plus,Subtract,Times,Divide}; (*list of binary operations*)
vars:={x,y,c}; (*list of variables and constants*)
nops=10; (*max number of operations used for building expression*)


output=Search[time,ncores,uops,bops,vars,nops];
output[[1]]//TableForm (*returns accumulated list of top 100 models and corresponding error values*)
output[[2]] (*returns total number of iterations*)
```
Constants in `vars` can be listed as symbols (like `c` in example above) and be determined inside of `Error` function. Alternatively, they can be listed as `RandomInteger[]`/`RandomReal[]` to appear as random values in expression. Finally, no constants is an option too.

**Important**: All used operations must be protected. For example, it's better to protect arguments of `Log`/`Sqrt` with `Abs` (dividing by 0 is OK). Also, applying functions like `Exp`/`Power` on large (small) enough numbers can cause severe memory leaks (Wolfram, wtf?). Therefore, arguments of these functions need to be protected by `Clip` (cuts off large/small values). For instance, instead of listing `Exp` in `uops` user needs to list something like `Exp[Clip[#,{10^-6,10^2},{0,Infinity}]]&`.

## Author

Paul Knysh (paul.knysh@gmail.com)
