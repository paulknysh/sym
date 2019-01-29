# sym: A Mathematica package for generating symbolic models from data

## What is this?

A Monte Carlo search for a symbolic model that fits given data. User needs to provide an error function (of how well a model fits the data) and some basic building blocks (math operations, variables, constants), from which random models will be generated. Procedure scales on multicore CPUs by running several independent Monte Carlo loops in parallel and subsequently accumulating obtained results.

## Demo

A dummy case of fitting sqrt() function using the following - unary operations: log(abs()), sin(), cos(); binary operations: +, -, \*, /; constants: e, pi; variables: x.

<img src="http://i.imgur.com/0QJbGc4.gif">

Evaluation time is set to 10 minutes. Total number of generated models is ~ 6 000 000 (on quad-core intel i7 desktop).

## How do I represent my error function?

A Mathematica function/module called `Error` needs to be defined:
```mathematica
Error[model_]:=...
```
where `model` is a symbolic expression. `Error` has to return a **non-negative** value that is being **minimized**.

## How do I run the procedure?

A template is presented below:
```mathematica
Get["...\\my_folder\\sym.m"] (*path to sym.m*)

data=Table[{i, Sqrt[i]}, {i, 0, 1, 0.1}]; (*given data*)
Error[model_]:=Mean@Table[Abs[data[[i,2]]-model/.{x->data[[i,1]]}],{i,Length[data]}] (*mean deviation*)

time=60*10; (*time in seconds for running the procedure*)
ncores=4; (*number of cores to be used*)
uops={Log[Abs[#]]&,Sin[#]&,Cos[#]&}; (*list of unary operations*)
bops={Plus,Subtract,Times,Divide}; (*list of binary operations*)
vars={x,E,Pi}; (*all free variables that are used in Error[], and also constants if needed*)
nops=10; (*max number of operations used for constructing model*)

output=Search[time,ncores,uops,bops,vars,nops]; (*runs procedure*)
output[[1]]//TableForm (*returns accumulated list of best 100 models with corresponding error values*)
output[[2]] (*returns total number of iterations*)
```
**Important:**
* Some operations must be protected. Applying `Exp` and `Power` on large/small enough numbers, especially when randomly generated model contains nestings like `Exp[Exp[Exp[...]]]`, can cause severe memory leaks. Therefore, arguments of these functions need to be protected by `Clip` (cuts off large/small values). For instance, instead of listing `Exp` in `uops` user needs to list `Exp[Clip[#,{10^-6,10^2},{0,Infinity}]]&`. Also, it's better to use `Log[Abs[#]]&` and `Sqrt[Abs[#]]&` instead of just `Log` and `Sqrt` to avoid nasty complex numbers. Arithmetic operations (`Plus`, `Subtract`, `Times`, `Divide`) are safe, dividing by 0 is OK. When adding new operations, make sure they are safe, otherwise use proper safety!

## Author

Paul Knysh (paul.knysh@gmail.com)

Feel free to email me if you have any questions or comments.

<p align="center">
  <img src="http://i.imgur.com/kuZdzVn.png">
</p>
