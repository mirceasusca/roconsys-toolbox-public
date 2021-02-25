%% Shows the applicability of the toolbox!

clc

boost = BoostConverterSystem();

eqOpts = set_eq_point_options(...
    'xeq',[24],'xeqidx',[2],'xunkguess',[3],...
    'ueq',[12;15],'ueqidx',[1;2],'uunkguess',[0.5]);

[x0,u0,y0,t0] = boost.findEqPoint(eqOpts)

[A,B,C,D,y0] = boost.linearize(x0,u0,t0);
boostLTIEq = LTIEqSystem(A,B,C,D,x0,u0,y0,t0);
boostLTI = LTISystem(A,B,C,D);

[num,den] = ss2tf(A,B(:,3),C,D(:,3));
H = tf(num,den);
% bode(H), shg

%% correctly simulate LTI system behaviour near the equilibrium point
u = @(t) [
    12+(t>=0.015)*1;
    15+(t>=0.01)*2;
    u0(3)+0.01;
];

uLTI = @(t) u(t)-u0;

iL0 = 3;
uC0 = 22;

[xl,tl,yl]=boostLTI.sim([iL0;uC0]-x0,uLTI,0.02);
[xe,te,ye]=boostLTIEq.sim([iL0;uC0],u,0.02);
[xn,tn,yn]=boost.sim([iL0;uC0],u,0.02);

clf

subplot(211);
plot(tl,xl+x0), hold on
plot(tn,xn)
plot(te,xe)

subplot(212)
plot(tl,yl+y0), hold on
plot(tn,yn)
plot(te,ye), shg

figure
plot(tl,yl+y0); hold on
plot(tl,xl+x0);

%%
%
% Sensitivity
% Performance weight
% 
M = 1.5;
wB = 1000;
Am = 1/100;
num = [1/M,wB]; den = [1,wB*Am];
[AwS,BwS,CwS,DwS] = tf2ss(num,den);
WS = ss(AwS,BwS,CwS,DwS);
%
%   Complementary sensitivity
%   Robustness weight 
%
% W2 = (40*s + 7.2)/(s + 7200);
[AwT,BwT,CwT,DwT] = tf2ss([40, 2],[1, 2000]);
% [AwT,BwT,CwT,DwT] = tf2ss([40, 7.2],[1, 7200]);
WT = ss(AwT,BwT,CwT,DwT);

P = augw(H,WS,[],[]);
K = hinfsyn(P,1,1);

K = -K;

% reverse y0, u0 compared to the process which has u0, y0!
% K needs -(Delta y)ref = -(y - y0) = y0 - y
KSysEq = LTIEqSystem(K.a,K.b,K.c,K.d,zeros(size(K.A,1),1),y0,u0(3),0);

%% check expected steady-state behaviour for the regulator
[x,t,y]=KSysEq.sim([0;0;0],@(t)y0,0.2);
plot(t,y), shg

%% Using KSysEq (without reference scaler) -- correct usage
scaled_ref = @(t,ref,y0) y0 - ref(t);
uCref = @(t) 24+(t>=0.1)*3+(t>=0.15)*2;

u = @(t) [
    12+(t>=0.015)*1;
    15+(t>=0.05)*8;
    0;  % miu_ref -> not applicable here
    scaled_ref(t,uCref,y0);  % ref=-delta(uC)
];

iL0 = 2.31;
uC0 = 22;

% tfin = 0:1e-6:0.2;
tfin = 0.2;

ClSysEq = LLFTConnectionSystem(boostLTIEq,KSysEq,1,1);
ClSysEq.solverType = 'ode23t';
[xl,tl,yl] = ClSysEq.sim([iL0;uC0;0;0;0],u,tfin);

CLSysNL = LLFTConnectionSystem(boost,KSysEq,1,1);
ClSysNL.solverType = 'ode23t';
[xn,tn,yn] = CLSysNL.sim([iL0;uC0;0;0;0],u,tfin);

clf
subplot(211)
plot(tl,xl(1:2,:)), hold on
plot(tn,xn(1:2,:))
legend('i_L lin','u_C lin','i_L nonlin','u_C nonlin')

subplot(212)
plot(tl,yl), hold on
plot(tn,yn), shg
legend('y lin','\mu lin','y nonlin','\mu nonlin')
