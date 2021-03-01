%% All steps must be made through clp functions (nothing from exteriorn 
% with the exception of specifying options)
% all optimization steps, validation steps (time/frequency), quantization
% etc.

% DONE: y(t) = uR(t), not uC(t)
% DONE: hybrid with three states when iL = 0 (DCM)

%% 1) define plant and uncertainty bounds/options;
clearvars
close all
GF = UncertainBoostConverterFactory();
GHF = UncertainHybridBoostConverterFactory();

%% simulate time response near equilibrium point
timeSimOpts = set_time_sim_options();
timeSimOpts.tfin = 0.02;
timeSimOpts.solverType = 'ode23tb';
timeSimOpts.ref_tol = 0.05;
timeSimOpts.N = 50;
timeSimOpts.u2x = true;
timeSimOpts.odeOpts = odeset('RelTol',1e-5,'Stats','off');
GF.step(timeSimOpts)

%%
eqOpts = GF.getEqOpts(true);

uOpts = set_unc_bound_det_options('iu',3,'numExp',1000,...
    'wmin',1e1,'wmax',1e7,'npoints',200,'uncType','mul');

clp = ClosedLoopControlProblem(...
    'modelName','dc-dc-boost',...
    'GF',GF,...
    'GHF',GHF,...
    'eqOpts',eqOpts,...
    'uOpts',uOpts...
    );

tfSpecs = set_tf_specs_options('n_real_poles',2,'n_real_zeros',2);

optimOpts = optimoptions('particleswarm',...
   'PlotFcn', @pswplotbestfdb,...
   'SwarmSize',1000,...
   'Display','iter',...
   'InitialSwarmSpan',1e4,...
   'MinNeighborsFraction',0.9,...
   'InertiaRange',[0.1,1.1]);
% optimOpts = [];
x0 = [1.2,1/1e2,1/1.2e5,1/1e3,1/1e5];
% x0 = [];

%% 2) get optimum uncertainty bounds -- optimization procedure
[uncBound,Wopt,INFO] = clp.optimizeUncertaintyBound(tfSpecs,x0,optimOpts);
% clp.save_current_object() 

%% 3) LTI analysis report; poles/zeros/stability/limitations etc.
% this should have a timeSimOpts parameter (synchronized with the
% closed-loop validation one) -- analyze the performances here (before) and
% then after the controller design and preprocessing (after)
N = 50;
uncOrd = 3;
tfin = 0.01;

% DONE: decaleaza step-ul cu 25% din intervalul dorit, pentru a prevedea
% conditiile initiale imperfecte (in caz ca nu le calculez pentru toate
% exemplele de-acolo, ci doar pentru cel nominal)

% TODO:
% nu x ny plots; with step_ref = 5% around the equilibrium point; with a
% 1/4 delay from the final step time of the simulation

INFO = clp.plantLimitationsAnalysisReport(25)
clp.validateUncertaintyModelling(N,uncOrd,tfin);

%% 4) define robust control problem and add object to ClosedLoopProblem and 
% synthesize controller
% TODO: the specifications here should be verified in a LTI Analysis module
% to check/anounce if they are too stringent etc.; keep in mind the limits
% for the command signal (as it is saturated between 0 and 1) and the
% sensitivity bandwidth of the system if it has time-delay or a RHP zero
wB = 650;
sensitivitySpecs = RobustControlOptimProblem.set_rc_sensitivity_opts('wB',wB,'M',2,'A',1e-4,'n',1);
controlEffortSpecs = RobustControlOptimProblem.set_rc_control_effort_opts('FREQ',wB,'MAG',2,'DC',0.1,'HF',100);
complSensSpecs = RobustControlOptimProblem.set_rc_complem_sens_opts('wBT',5*wB,'MT',2,'n',1,'AT',1e-4);
% 
rc_opts = RobustControlOptimProblem.set_rc_performance_specifications(sensitivitySpecs, controlEffortSpecs, complSensSpecs);
% rc_opts = RobustControlOptimProblem.set_rc_performance_specifications(sensitivitySpecs, controlEffortSpecs)
% rc_opts = RobustControlOptimProblem.set_rc_performance_specifications(sensitivitySpecs)

rcp = RobustControlOptimProblem(clp,rc_opts);
clp.rcOptimProblem = rcp;

[K,CLPERF,INFO]=clp.rcOptimProblem.generateController(3);
if CLPERF < 1
    clp.save_current_object()
end

%% 6) validate optimal controller synthesis on uncertainties etc.
% clp.rcOptimProblem.valFrPerfSpecs()
    
% clp.rcOptimProblem.valTrPerfSpecs()

% clp.rcOptimProblem.valTrHyPerfSpecs()

%% 7) controller order reduction (preprocessing) and analysis
tol = 0.4;  % must be such that the peak mu value remains under 1
[Kred,NS,recOrd] = clp.rcOptimProblem.getReducedOrderControllers(tol);
% 
% clp.rcOptimProblem.valFrPerfSpecs(Kred(:,:,recOrd));
% 
% PM = robgain(clp.rcOptimProblem.P0,1)
% RS = robstab(clp.rcOptimProblem.P0)

%% 8) Reduced order controller validation for the uncertain plant set:
% linearized vs nonlinear vs hybrid

INFO = clp.rcOptimProblem.valRsRp(Kred(:,:,recOrd))

% %%
clp.rcOptimProblem.valFrPerfSpecs(Kred(:,:,recOrd));
% 
% % %%
% timeSimOpts = set_time_sim_options();
% timeSimOpts.tfin = 0.02;
% timeSimOpts.solverType = 'ode15i';
% timeSimOpts.ref_tol = 0.05;
% timeSimOpts.N = 50;
% clp.rcOptimProblem.valTrPerfSpecs(Kred(:,:,recOrd),timeSimOpts);

% TODO: illustrate DC-DC converter specific phenomena, such as E variance
% and E step and ramp disturbances

% DONE: valTrHyPerfSpecs refactor, and also in
% UncertainHybridBoostConverterFactory, as the extra states from the hybrid
% system should be correctly initialized automatically

%%
hyTimeSimOpts = set_hybrid_time_sim_options();
hyTimeSimOpts.tfin = timeSimOpts.tfin;
hyTimeSimOpts.solverType = 'ode113';
hyTimeSimOpts.ref_tol = timeSimOpts.ref_tol;
hyTimeSimOpts.odeOpts = odeset('RelTol',1e-8,'NormControl','on','Stats','off');
hyTimeSimOpts.N = 10;
%
clp.GHF.params.TPWM = 1.75e-5;
clp.rcOptimProblem.valTrHyPerfSpecs(Kred(:,:,recOrd),hyTimeSimOpts);
