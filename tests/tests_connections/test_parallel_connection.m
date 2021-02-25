rng(4);
sys1 = rss(5,2,3);
sys2 = rss(3,2,3);

sys = parallel(sys1,sys2);

Sys1 = LTISystem(sys1.a,sys1.b,sys1.c,sys1.d)
Sys2 = LTISystem(sys2.a,sys2.b,sys2.c,sys2.d)

sys_parallel = ParallelConnectionSystem(Sys1,Sys2)

x0 = zeros(8,1);
tfin = 50;
[x,t,y] = sys_parallel.simInitCond(x0,[1;0;0],tfin);

t1 = 0:1e-1:max(t);
L = length(t1);
u = [ones(1,L);zeros(1,L);zeros(1,L)];
y1 = lsim(sys,u,t1);

plot(t,y,t1,y1,'*')
