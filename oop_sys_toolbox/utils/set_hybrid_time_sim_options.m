function opts = set_hybrid_time_sim_options(varargin)
% To be used when testing closed-loop control systems in MiL simulations
% with hybrid system models.
% Should receive system structure (interface u/x/y) and robust control
% performance specifications and deduce what reference signals should be 
% given for each input (step/ramp etc.), disturbances etc.
%

opts = struct('N',10,'tfin',1,'solverType','ode23t','ref_tol',0.05,...
    'TPWM',5e-4,'u2x',false,'odeOpts',[]);

for k=1:2:length(varargin)
    opts.(varargin{k}) = varargin{k+1};
end

end