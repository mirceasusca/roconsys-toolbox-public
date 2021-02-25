
bb = BouncingBallSystem()

t_fin = 10;
j_fin = 20;
options = odeset('RelTol',1e-6,'MaxStep',0.1);

x0 = [1;0];
bb.solverOptions = options;
bb.solverType = 'ode45';
u = @(t) [];
[x,t,y,j]=bb.sim(x0,u,t_fin,j_fin);

x = x';

%%
figure(1);
clf
subplot(211), plotHarc(t,j,x(:,1));
grid on
ylabel('x_1 position')
subplot(212), plotHarc(t,j,x(:,2));
grid on
ylabel('x_2 velocity')

%%
figure(2)
clf
plotHarcColor(x(:,1),j,x(:,2),t);
xlabel('x_1');
ylabel('x_2');

%%
figure(3)
plotHybridArc(t,j,x); grid
xlabel('j');
ylabel('t');
zlabel('x1');