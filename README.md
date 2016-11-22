# sym: A Mathematica package for parallel symbolic regression using Monte Carlo

## What is this?

A simplistic method for automatic data-driven construction of a symbolic model. User needs to provide an error function and some basic building blocks: operations, variables, constants. A Monte Carlo approach is used: a large number of random models is generated to find the best ones. Procedure scales on multicore CPUs by running several independent Monte Carlo loops in parallel and subsequently accumulating obtained results.

## How do I represent my error function?

A Mathematica function/module called `Error` needs to be provided by user:
```mathematica
Error[expr_]:=...
```
Here `expr` is a symbolic expression. Function has to return a **non-negative** error value that is being **minimized**.

## How do I run the procedure?

Just like that (minimizing an error):
```mathematica
Get["...\\sym.m"]

Error[expr_]:=...

time=15; (*time in seconds for running the procedure*)
ncores=4; (*number of cores to be used*)
uops={#^2&,Abs[#]^(1/2)&,Log[Abs[#]]&}; (*list of unary operations*)
bops={Plus,Subtract,Times,Divide}; (*list of binary operations*)
vars:={x,y,c}; (*list of variables and constants*)
nops=10; (*max number of operations used in expression*)

output=Search[time,ncores,uops,bops,vars,nops];
output[[1]]//TableForm (*returns accumulated list of top 100 models*)
output[[2]] (*returns total number of iterations*)
```
Constants can be listed as symbols (like `c` in example above) and be determined inside of `Error` function. Alternatively, they can be listed as `RandomInteger[]`/`RandomReal[]` to appear as random values in expression.

**Important**: All used operations must be protected --- for example it's better to avoid things like `Log`/`Sqrt` of a negative number (dividing by 0 is OK though). Also, applying functions like `Exp`/`Power` on large enough values can cause severe memory leaks (Wolfram, wtf?). Therefore, arguments of these functions need to be protected by `Clip` (cuts off large values). For example, instead of listing `Exp` in `uops` user needs to list something like `Exp[Clip[#,{10^-6,10^2},{0,Infinity}]]&`.

## Author

Paul Knysh (paul.knysh@gmail.com)
