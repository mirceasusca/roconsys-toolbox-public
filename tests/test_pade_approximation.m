s = tf('s');
dt = 1.5;
sdt = exp(-dt*s);    
% sysx = pade(sys,3)

[numdt,dendt] = pade(dt,7);

[A,B,C,D] = tf2ss(numdt,dendt);
sdta = ss(A,B,C,D);

rng(10)
% sys = rss(5,1,1);
sys = ss(-1/10,1,1,0);

sysdt = series(sys,sdt);
sysdta = series(sys,sdta);

step(sysdt,sysdta), shg

% bode(sysdt,sysdta), shg

legend('sysdt','sysdta')