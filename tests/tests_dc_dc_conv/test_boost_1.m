clearvars
boost = BoostConverterSystem();
% boost = BoostConverterSystem(py.dict(pyargs('rC1',0.0,'VF1',0.0,'VF2',0.0,'rL1',0.0,'rDS1',0.0,'rDS2',0.0)));

%%
tfin = 0.01;

miu = @(t) (t<=1*tfin/4)*0.2 + (t>1*tfin/4)*0.6;
R = @(t) (t <= tfin/2)*12 + (t>tfin/2)*15;

f = @(t,x) boost.F(x,[12;R(t);miu(t)],t)

[t,x] = ode23t(f,[0,tfin],[3.8,24]);

plot(t,x), shg

%%
[x,t,y] = boost.simInitCond([5;32],[12;15;0.7],0.02); plot(t,x)

%%
% dynamical system for the controller also
% LinearSystem object
% to close the loop

% impunerea tensiunii de iesire
uout = 24
fun = @(z) boost.F([z(1);uout],[12;15;z(2)],0);
z0 = fsolve(fun,[5;0.5])
