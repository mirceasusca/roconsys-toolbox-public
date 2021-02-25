%% All steps must be made through clp functions (nothing from exteriorn 
% with the exception of specifying options)
% all optimization steps, validation steps (time/frequency), quantization
% etc.
%

%% 1) define plant and uncertainty bounds/options
clearvars
GF = UncertainSEPICConverterFactory();
GHF = UncertainHybridSEPICConverterFactory();

%% simulate time response near equilibrium point
% timeSimOpts = set_time_sim_options();
% timeSimOpts.tfin = 0.02;
% timeSimOpts.solverType = 'ode23tb';
% timeSimOpts.ref_tol = 0.01;
% timeSimOpts.N = 50;
% timeSimOpts.u2x = true;
% timeSimOpts.odeOpts = odeset('RelTol',1e-5,'Stats','on');
% GF.step(timeSimOpts)

%%
eqOpts = GF.getEqOpts(true);

uOpts = set_unc_bound_det_options('iu',3,'numExp',1000,...
    'wmin',1e-2,'wmax',1e8,'npoints',300,'uncType','mul');

clp = ClosedLoopControlProblem(...
    'modelName','dc-dc-sepic',...
    'GF',GF,...
    'GHF',GHF,...
    'eqOpts',eqOpts,...
    'uOpts',uOpts...
    );

% tfSpecs = set_tf_specs_options('n_real_poles',1,'n_real_zeros',1);
tfSpecs = set_tf_specs_options('n_pairs_cc_poles',1,'n_pairs_cc_zeros',1);

optimOpts = optimoptions('particleswarm',...
   'SwarmSize',1000,...
   'Display','iter',...
   'InitialSwarmSpan',1e4,...
   'MinNeighborsFraction',0.9,...
   'InertiaRange',[0.1,1.1]);
% optimOpts = [];
K0 = 0.76897*6.262e06/2.844e08*5;
wz1 = sqrt(6.262e06);
zz1 = 4914/2/wz1;
wp1 = sqrt(2.844e08)/2.3;
zp1 = 1659/2/wp1/80;
% bodemag(tf(K0*[1/wz1^2,2*zz1/wz1,1],[1/wp1^2,2*zp1/wp1,1]))
x0 = [K0,wz1,zz1,wp1,zp1];
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
tfin = 0.02;

INFO = clp.plantLimitationsAnalysisReport()
clp.validateUncertaintyModelling(N,uncOrd,tfin);

%% 4) define robust control problem and add object to ClosedLoopProblem and 
% synthesize controller
% TODO: the specifications here should be verified in a LTI Analysis module
% to check/anounce if they are too stringent etc.; keep in mind the limits
% for the command signal (as it is saturated between 0 and 1) and the
% sensitivity bandwidth of the system if it has time-delay or a RHP zero
wB = 200;
sensitivitySpecs = RobustControlOptimProblem.set_rc_sensitivity_opts('wB',wB,'M',2,'A',1e-2,'n',1);
controlEffortSpecs = RobustControlOptimProblem.set_rc_control_effort_opts('FREQ',wB,'MAG',250,'DC',1e+2,'HF',1e5);
complSensSpecs = RobustControlOptimProblem.set_rc_complem_sens_opts('wBT',10*wB,'MT',2,'n',2,'AT',1e-4);
% 
rc_opts = RobustControlOptimProblem.set_rc_performance_specifications(sensitivitySpecs, controlEffortSpecs, complSensSpecs);
% rc_opts = RobustControlOptimProblem.set_rc_performance_specifications(sensitivitySpecs, controlEffortSpecs)
% rc_opts = RobustControlOptimProblem.set_rc_performance_specifications(sensitivitySpecs)

rcp = RobustControlOptimProblem(clp,rc_opts);
clp.rcOptimProblem = rcp;

% Kopts.fxstr_cont = true;
% Kopts.type = 'lead-lag';

[K,CLPERF,INFO]=clp.rcOptimProblem.generateController(8);
if CLPERF < 1
    clp.save_current_object()
end

% 6) validate optimal controller synthesis on uncertainties etc.
% clp.rcOptimProblem.valFrPerfSpecs()

% clp.rcOptimProblem.valTrPerfSpecs()

% clp.rcOptimProblem.valTrHyPerfSpecs()

%% 7) controller order reduction (preprocessing) and analysis
tol = 0.25;  % must be such that the peak mu value remains under 1
[Kred,NS,recOrd] = clp.rcOptimProblem.getReducedOrderControllers(tol);
% Ks = -Kred(:,:,recOrd);
% 
% clp.rcOptimProblem.valFrPerfSpecs(Kred(:,:,recOrd));
% 
% PM = robgain(clp.rcOptimProblem.P0,1)
% RS = robstab(clp.rcOptimProblem.P0)

%% 8) Reduced order controller validation for the uncertain plant set:
% linearized vs nonlinear vs hybrid

% recOrd = 2;  % small - in order to eliminate the spike at the step
% because it requires > 100k sampling frequencies, which are difficult to
% obtain; I think the solution would be to impose loop shaping weights to 
% stay away from that problematic frequency

INFO = clp.rcOptimProblem.valRsRp(Kred(:,:,recOrd))

% %%
clp.rcOptimProblem.valFrPerfSpecs(Kred(:,:,recOrd));

% %%
timeSimOpts = set_time_sim_options();
timeSimOpts.tfin = 0.05;
timeSimOpts.solverType = 'ode15i';
timeSimOpts.ref_tol = 0.05;
timeSimOpts.N = 100;
% timeSimOpts.odeOpts = odeset('AbsTol',1e-8,'Stats','on',...
%     'MaxStep',1e-7,'NormControl','on');
timeSimOpts.odeOpts = odeset('RelTol',1e-6,'NormControl','on','Stats','on');
% timeSimOpts.odeOpts = odeset('NormControl','on','Stats','on');
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
hyTimeSimOpts.N = 2;
%
clp.GHF.params.TPWM = 1.75e-05;
clp.rcOptimProblem.valTrHyPerfSpecs(Kred(:,:,recOrd),hyTimeSimOpts);