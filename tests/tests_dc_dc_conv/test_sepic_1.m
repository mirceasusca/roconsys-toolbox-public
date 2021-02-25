clearvars
sepic = SEPICConverterSystem();
% sepic = SEPICConverterSystem('rL1',0,'rL2',0,'rC1',0,'rC2',0,'rCin',0.1,'VF1',0,'VF2',0,'rDS1',0,'rDS2',0);

%%
tfin = 0:1e-5:0.1;

miu = @(t) 0.57 + (t>tfin(end)/2)*0.01;
R = @(t) 80;
E = @(t) 300;
u = @(t)[E(t);R(t);miu(t)];

x0 = [0;0;0;0;0];
[x,t,y] = sepic.sim(x0,u,tfin);

plot(t,x), shg
