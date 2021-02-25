sysn = InvPendulumSystem();

delta = 0.25;
l = 1;
g = 9.81;

x0 = [pi/2;0];
u0 = 0;
t0 = 0;
[A,B,C,D,y0] = sysn.linearize(x0,u0,t0);
sysl = LTIEqSystem(A,B,C,D,x0,u0,y0,t0);

% % for validation; it should coincide
% A1 = [0, 1; 3*g/2/l, -2*delta];
% B1 = [0; 3/2/l];
% C1 = [180/pi, 0];
% D1 = 0;
% 
% A - A1
% B - B1
% C - C1
% D - D1

tfin = 1;

% [tn,xn] = sysn.sim_init_cond(x0,u0,tfin);
% plot(tn,xn), hold on

u = @(t) (t>=0 & t<=1)*1.0;

clf
[xn,tn,yn] = sysn.sim(x0,u,tfin);
[xl,tl,yl] = sysl.sim(x0,u,tfin);

subplot(211)
plot(tn,xn), hold on
plot(tl,xl)
legend('xn1','xn2','xl1','xl2')

subplot(212)
plot(tn,yn), hold on
plot(tl,yl), shg
legend('yn','yl')