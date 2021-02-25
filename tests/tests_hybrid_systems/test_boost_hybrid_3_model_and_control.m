boost3 = BoostHybrid3ConverterSystem()

boost3.TPWM = 1/100e3;
options = odeset('RelTol',1e-5,'MaxStep',boost3.TPWM/30);
boost3.solverOptions = options;

u = @(t)[
    12+3*(t>=0.005);
    15;
    0.5+0.3*(t>=0.01)
];

x0 = [0;0;1;0];
tfin = 0.015;
[x,t,y]=boost3.sim(x0,u,tfin);

close all
figure
subplot(311),plot(t,x(1:2,:),'linewidth',1.5)
subplot(312),plot(t,x(3,:),'linewidth',1),ylabel('q')
subplot(313),plot(t,x(4,:),'linewidth',1),ylabel('tau')

% subplot(311),plot(t,x(1:2,:),'linewidth',1.5)
% legend('iL','uC');

%% Comparative closed-loop control using K from test_boost_2.m
clc

scaled_ref = @(t,ref,y0) y0 - ref(t);
uCref = @(t) 24+(t>=0.1)*3+(t>=0.15)*2;

u = @(t) [
    12+(t>=0.015)*1;
    15+(t>=0.05)*8;
    0;  % miu_ref -> not applicable here
    scaled_ref(t,uCref,y0);  % ref=-delta(uC)
];

iL0 = 1.31;
uC0 = 20;

% tfin = 0:1e-6:0.2;
tfin = 0.10;

ClSysEq = LLFTConnectionSystem(boostLTIEq,KSysEq,1,1);
ClSysEq.solverType = 'ode23t';
[xl,tl,yl] = ClSysEq.sim([iL0;uC0;0;0;0],u,tfin);

CLSysNL = LLFTConnectionSystem(boost,KSysEq,1,1);
ClSysNL.solverType = 'ode23t';
[xn,tn,yn] = CLSysNL.sim([iL0;uC0;0;0;0],u,tfin);

boost3.TPWM = 1/75e3;
CLSysHy = HybridLLFTConnectionSystem(boost3,KSysEq,1,1);
options = odeset('RelTol',1e-4,'MaxStep',boost3.TPWM/30);
CLSysHy.solverOptions = options;
ClSysHy.solverType = 'ode23tb';
[xh,th,yh] = CLSysHy.sim([iL0;uC0;1;0;0;0;0],u,tfin);

clf
subplot(211)
plot(tl,xl(1:2,:)), hold on
plot(tn,xn(1:2,:))
plot(th,xh(1:2,:))
legend('i_L lin','u_C lin','i_L nonlin','u_C nonlin','i_L hyb','u_C hyb')

subplot(212)
plot(tl,yl), hold on
plot(tn,yn), 
plot(th,yh), shg
legend('y lin','\mu lin','y nonlin','\mu nonlin','y hyb','\mu hyb')
