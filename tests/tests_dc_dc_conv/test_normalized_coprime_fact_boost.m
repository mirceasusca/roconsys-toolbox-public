boost_nominal = BoostConverterSystem();
boost2 = BoostConverterSystem(py.dict(pyargs('L1',4e-5*1.01,'C1',6e-4*0.98)));

eqOpts = set_eq_point_options(...
    'xeq',[24],'xeqidx',[2],'xunkguess',[3],...
    'ueq',[12;15],'ueqidx',[1;2],'uunkguess',[0.5]);

[x0,u0,y0,t0] = boost_nominal.findEqPoint(eqOpts);
[x20,u20,y20,t20] = boost2.findEqPoint(eqOpts);

% check tolerances for the solution (residuals) first

[A,B,C,D] = boost_nominal.linearize(x0,u0,t0);

[Ar,Br,Cr,Dr] = boost2.linearize(x20,u20,t20);

[~,M1,N1] = lncf(ss(A,B,C,D));
[~,M2,N2] = lncf(ss(Ar,Br,Cr,0));

Delta_M = M1-M2;
Delta_N = N1-N2;

hinfnorm(Delta_M)
hinfnorm(Delta_N)