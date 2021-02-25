clc
% TODO
rng(13)
sys = rss(4,2,3);

[A,B,C,D] = ssdata(sys);
Sys = LTISystem(A,B,C,D)

% step(sys), shg

%% get equilibrium point (operating point) -> using Simulink functions (!!)
% https://www.mathworks.com/help/slcontrol/ug/steady-state-operating-point-trimming.html
% findop function
% x0 = [

f = @(x,u,t) Sys.F(x,u,t)
h = @(x,u,t) Sys.h(x,u,t)

%%
x0 = [3;1;4;4];
u0 = [2;3;-4];
y0 = [0.5;2];
t0 = 2;
[Al,Bl,Cl,Dl] = Sys.linearize(x0,u0,t0)

