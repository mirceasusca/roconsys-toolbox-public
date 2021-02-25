function uncOpts = set_unc_bound_det_options(varargin)
%
% numExp[=200]: number of Monte Carlo simulations
% iu[=1]: input index to use for perturbing
% iy[=1]: output index to use for perturbing
% uncType[='mul']: uncertainty type: {'add','mul'} =
%   {additive,multiplicative}
% wmin[=[]]: minimum pulsation used in bode/sigma
% wmax[=[]]: maximum pulsation used in bode/sigma
% npoints[=[]]: number of points to generate with logspace
%
%
if nargin == 0
    error(message('set_unc_bound_det_options:NotEnoughInputs'));
end

uncOpts = struct('numExp',200,'iu',1,'iy',1,'uncType','mul',...
    'wmin',[],'wmax',[],'npoints',[]);

for k=1:2:length(varargin)
    uncOpts.(varargin{k}) = varargin{k+1};
end

end