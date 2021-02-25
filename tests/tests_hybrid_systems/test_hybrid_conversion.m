rng(8);
sys = rss(10,2,1);

[A,B,C,D] = ssdata(sys);

Sys = LTISystem(A,B,C,D);
SysH = HybridSystemWrapper(Sys)

x0 = rand(10,1);
u0 = rand(1,1);

u = @(t) u0;
[x,t,y] = Sys.sim(x0,u,10);
[xh,th,yh] = SysH.sim(x0,u,10);

subplot(211)
plot(t,x,th,xh,'*')

subplot(212)
plot(t,y,th,yh,'*')

