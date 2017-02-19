# sym: A Mathematica package for generating symbolic models from data

## What is this?

A Monte Carlo search for a symbolic model that fits given data. User needs to provide an error function (of how well a model fits the data) and some basic building blocks: math operations, variables, constants. Procedure scales on multicore CPUs by running several independent Monte Carlo loops in parallel and subsequently accumulating obtained results.

## How do I represent my error function?

A Mathematica function/module called `Error` needs to be defined by user. For example, if `data` is a list of points in 2D (`{{0.,1.},{2.,5.},...,{7.,8.}}`) that we want to fit, then the following error function can be defined:
```mathematica
Error[expr_]:=Mean@Table[Abs[data[[i,2]]-expr/.{x->data[[i,1]]}],{i,Length[data]}]
```
`expr` is a symbolic model. Symbol `x` that appears in the error function has to be included in list of variables (see example below). `Error` has to return a **non-negative** value that is being **minimized**.

## How do I run the procedure?

Just like that (you need to specify proper full path to a package in `Get[]`):
```mathematica
Get["...\\sym.m"]


Error[expr_]:=...


time=60; (*time in seconds for running the procedure*)
ncores=4; (*number of cores to be used*)
uops={#^2&,Abs[#]^(1/2)&,Log[Abs[#]]&}; (*list of unary operations*)
bops={Plus,Subtract,Times,Divide}; (*list of binary operations*)
vars:={x,c}; (*list of variables/constants*)
nops=10; (*max number of operations used for constructing expression (max size)*)


output=Search[time,ncores,uops,bops,vars,nops];
output[[1]]//TableForm (*returns accumulated list of top 100 models and corresponding error values*)
output[[2]] (*returns total number of iterations*)
```
Constants in `vars` can be listed as symbols (like `c` in example above) and be determined inside of `Error` function. Alternatively, they can be listed as `RandomInteger[]`/`RandomReal[]` to appear as random values in expression. Finally, no constants is an option too.

**Important**: All used operations must be protected. For example, it's better to protect arguments of `Log`/`Sqrt` with `Abs` (dividing by 0 is OK). Also, applying functions like `Exp`/`Power` on large (small) enough numbers can cause severe memory leaks (Wolfram, wtf?). Therefore, arguments of these functions need to be protected by `Clip` (cuts off large/small values). For instance, instead of listing `Exp` in `uops` user needs to list something like `Exp[Clip[#,{10^-6,10^2},{0,Infinity}]]&`.

## Author

Paul Knysh (paul.knysh@gmail.com)

Feel free to email me if you have any questions or comments.
