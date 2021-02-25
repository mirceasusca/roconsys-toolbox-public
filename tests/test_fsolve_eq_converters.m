boost = BoostConverterSystem();
% boost = BoostConverterSystem(py.dict(pyargs('rC1',0.0,'VF1',0.0,'VF2',0.0,'rL1',0.0,'rDS1',0.0,'rDS2',0.0)));

% F = @(z) f(0,[z(1);24],[12;15;z(2)]);
% z0 = fsolve(F,[3;0.5])
% 
% y0 = 24;
% Fy = @(z) [f(0,[z(1);y0],[12;15;z(2)]);
%     h(0,[z(1);y0],[12;15;z(2)])-y0];
% z0 = fsolve(Fy,[10;0.5])

eqOpts = set_eq_point_options(...
    'xeq',[24],'xeqidx',[2],'xunkguess',[3],...
    'ueq',[12;15],'ueqidx',[1;2],'uunkguess',[0.5]);

[x0,u0,y0,t0] = boost.findEqPoint(eqOpts)

%%
buck = BuckConverterKrasovskiiSystem();
[x,t,y] = buck.sim([0;0],@(t)[12;15;0.5],0.005);
plot(t,x)

x(:,end)

eqOpts = set_eq_point_options(...
    'xeq',[6],'xeqidx',[2],'xunkguess',[1],...
    'ueq',[12;15],'ueqidx',[1;2],'uunkguess',[0.6]);

[x0,u0,y0,~] = buck.findEqPoint(eqOpts)

%% sepic - state value imposed % TODO: update for 5 state model
clc
sepic = SEPICConverterSystem();

% [x,t,y] = sepic.sim([0;0;0;0],@(t)[12;15;0.7766],0.02);
% plot(t,x), shg
% legend('x1','x2','x3','x4')
% plot(t,y), shg
% legend('uC','uR')

% x(:,end)
% y(:,end)

eqOpts = set_eq_point_options(...
    'xeq',[38],'xeqidx',[4],'xunkguess',[0.5;0.5;10],...
    'ueq',[12;15],'ueqidx',[1;2],'uunkguess',[0.6]);

[x0,u0,y0,t0] = sepic.findEqPoint(eqOpts)

% [x,t,y] = sepic.sim(x0,@(t)u0,0.001);
% plot(t,y)

% figure
% [A,B,C,D] = sepic.linearize(x0,u0,0);
% % bode(A,B(:,3),C,D(:,3))
% step(A,B(:,3),C,D(:,3))

%% sepic - output value imposed % TODO: update for 5 state model
clc
sepic = SEPICConverterSystem();

% [x,t,y] = sepic.sim([0;0;0;0],@(t)[12;15;0.7766],0.01);
% plot(t,x), shg
% legend('x1','x2','x3','x4')
% plot(t,y), shg
% legend('uC','uR')

% x(:,end)
% y(:,end)
% 

eqOpts = set_eq_point_options(...
    'yeq',[38],'yeqidx',[2],'xunkguess',[5,2,10,37],...
    'ueq',[12;15],'ueqidx',[1,2],'uunkguess',[0.6],...
    'solve_for_time',true);

[x0,u0,y0,t0] = sepic.findEqPoint(eqOpts)

% [x,t,y] = sepic.sim(x0,@(t)u0,0.005);
% plot(t,y)

