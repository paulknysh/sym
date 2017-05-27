# sym: A Mathematica package for generating symbolic models from data

## What is this?

A Monte Carlo search for a symbolic model that fits given data. User needs to provide an error function (of how well a model fits the data) and some basic building blocks (math operations, variables, constants), from which random models will be generated. Procedure scales on multicore CPUs by running several independent Monte Carlo loops in parallel and subsequently accumulating obtained results.

## How do I represent my error function?

A Mathematica function/module called `Error` needs to be defined. For example, if `data` is a list of points in 2D (`{{0.,1.},{2.,5.},...,{7.,8.}}`) that we want to fit, the following error function can be used:
```mathematica
Error[model_]:=Mean@Table[Abs[data[[i,2]]-model/.{x->data[[i,1]]}],{i,Length[data]}]
```
`model` is a symbolic expression. Symbol `x` that appears inside of the `Error` has to be listed in `vars` (see example below). `Error` has to return a **non-negative** value that is being **minimized**.

Since `Error` is fully programmable, user is not limited to only fitting data points. It is possible to generate models for more general kinds of data.

## How do I run the procedure?

Just like that:
```mathematica
Get["...\\my_folder\\sym.m"] (*path to sym.m*)

Error[model_]:=...

time=60; (*time in seconds for running the procedure*)
ncores=4; (*number of cores to be used*)
uops={#^2&,Sqrt[Abs[#]]&,Log[Abs[#]]&}; (*list of unary operations*)
bops={Plus,Subtract,Times,Divide}; (*list of binary operations*)
vars:={x}; (*list of variables/constants*)
nops=7; (*max number of operations used for constructing model (~ max model size)*)

output=Search[time,ncores,uops,bops,vars,nops]; (*runs procedure*)
output[[1]]//TableForm (*returns accumulated list of best 100 models with corresponding error values*)
output[[2]] (*returns total number of iterations*)
```
Constants in `vars` can be listed as symbols (`vars:={x,c}`), which are then determined inside of `Error`. Alternatively, they can be listed as `RandomInteger[]`/`RandomReal[]` (with proper arguments) to appear as random values in the model. Finally, you don't have to list constants in `vars` if you don't need them.

**Important:** Some operations must be protected. Applying `Exp` and `Power` on large/small enough numbers, especially when randomly generated model contains nestings like `Exp[Exp[Exp[...]]]`, can cause severe memory leaks (Wolfram, wtf?). Therefore, arguments of these functions need to be protected by `Clip` (cuts off large/small values). For instance, instead of listing `Exp` in `uops` user needs to list something like `Exp[Clip[#,{10^-6,10^2},{0,Infinity}]]&`. Also, it's better to use `Log[Abs[#]]&`/`Sqrt[Abs[#]]&` instead of `Log`/`Sqrt` to avoid nasty complex numbers. Arithmetic operations (`Plus`, `Subtract`, `Times`, `Divide`) are safe, dividing by 0 is OK. When adding new operations, make sure they are safe, otherwise use proper safety!

## Author

Paul Knysh (paul.knysh@gmail.com)

Feel free to email me if you have any questions or comments.

<p align="center">
  <img src="http://i.imgur.com/kuZdzVn.png">
</p>
