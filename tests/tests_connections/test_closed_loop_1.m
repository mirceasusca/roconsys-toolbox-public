clc

Hf = tf(100,conv([1,1],[2,1]));
H0 = tf(1,conv([0.5,1],[0.5,1]));

% wn = 5; zeta = 0.907; K = 1;
% H0 = tf(K*wn^2,[1,2*zeta*wn,wn^2]);

Hr = minreal(1/Hf*H0/(1-H0))

%%
[A,B,C,D] = tf2ss(Hf.num{:},Hf.den{:});
sys_Hf = ss(A,B,C,D);
Sys_Hf = LTISystem(A,B,C,D)

[A,B,C,D] = tf2ss(Hr.num{:},Hr.den{:});
sys_Hr = ss(A,B,C,D);
Sys_Hr = LTISystem(A,B,C,D)

%%

u0 = 1;
x0 = zeros(Sys_Hf.n,1);
[x,t,y] = Sys_Hf.simInitCond(x0,u0,20)

plot(t,y), shg

%%
OpenLoopSystem = SeriesConnectionSystem(Sys_Hr,Sys_Hf)
gainSystem = GainSystem(-1)

%%
ClSys = FeedbackConnectionSystem(OpenLoopSystem,gainSystem)

ref = 15;
x0 = zeros(ClSys.n,1);
[x,t,y] = ClSys.simInitCond(x0,ref,10);
u = ref*ones(1,size(x,2));
plot(t,u,t,y),shg

%% comparison
[A,B,C,D] = ClSys.linearize([3;-3;2;-2],0.5,10)

[num,den] = ss2tf(A,B,C,D);
H = tf(num,den)
% bode(H), shg
H = minreal(H)

step(H,H0,'*'), shg
legend('H0 from linearization','supervised H0')