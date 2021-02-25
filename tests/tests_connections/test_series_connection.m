rng(4);
sys1 = rss(3,2,1);
sys2 = rss(3,3,2);

sys = series(sys1,sys2)

Sys1 = LTISystem(sys1.a,sys1.b,sys1.c,sys1.d)
Sys2 = LTISystem(sys2.a,sys2.b,sys2.c,sys2.d)

sys_series = SeriesConnectionSystem(Sys1,Sys2)

[y1,t1] = step(sys,50);

x0 = [0;0;0;0;0;0];
tfin = 50;
[x,t,y] = sys_series.simInitCond(x0,1,tfin);

plot(t,y,t1,y1,'*')
% plot(t,x)

%%
rng(18)
sys3 = rss(5,4,3);
sysT = series(sys,sys3);

Sys3 = LTISystem(sys3.a,sys3.b,sys3.c,sys3.d);
SysT = SeriesConnectionSystem(sys_series,Sys3);

x0 = zeros(11,1);
[x,t,y] = SysT.simInitCond(x0,1,tfin);
plot(t,x), hold on

x0 = zeros(11,1);
[x,t,y] = SysT.simInitCond(x0,1,tfin);
plot(t,x,'*')
