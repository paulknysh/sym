# sym: A Mathematica package for parallel symbolic regression using Monte Carlo

## What is this?

A simplistic method for automatic data-driven construction of a model. User just needs to provide building blocks (operations, variables, constants). and A Monte Carlo approach is used --- a large number of random models is generated to find the best solution. Procedure scales on multicore CPUs by running several independent Monte Carlo loops in parallel and accumulating obtained results.

## Error function

The following Mathematica function/module needs to be provided:
```mathematica
Error[expr_]:=...
```
Here `expr` is a symbolic expression. It has to return a **non-negative** error value that is being **minimized**.

## How do I run the procedure?

Just like that (minimizing an error):
```mathematica
Get["...\\sym.m"]

time=15; (*time in seconds for running procedure*)
ncores=4; (*number of cores to be used*)
uops={#^2&,Abs[#]^(1/2)&,Log[Abs[#]]&}; (*list of unary operations*)
bops={Plus,Subtract,Times,Divide}; (*list of binary operations*)
vars:={x,y,c}; (*list of variables and constants*)
nops=10; (*max number of operations used in expression*)

output=Search[time,ncores,uops,bops,vars,nops];
output[[1]]//TableForm (*returns accumulated list of top 100 models*)
output[[2]] (*returns total number of iterations*)
```
**Important**: All used operations must be protected --- for example it's better to avoid things like `Log`/`Sqrt` of negative number (dividing by 0 is OK). Also, applying functions like `Exp`/`Power` on large enough values can cause severe  memory leaks (Wolfram, wtf?). Therefore, arguments of these functions need to be protected with `Clip` (cuts off large values). For example, instead of listing `Exp` in `uops` you need to list something like `Exp[Clip[#, {10^-6, 10^2}, {0, Infinity}]] &`.

## Author

Paul Knysh (paul.knysh@gmail.com)
