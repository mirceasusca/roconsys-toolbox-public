function tfSpecs = set_tf_specs_options(varargin)
% Defines tf structure for modelling uncertainty bounds.
% Should receive input args in pairs:
% tfSpecs.n_real_poles: number of real poles (nonzero), defined between
%   (wfmin,wfmax) = (1/Tmax,1/Tmin)
% tfSpecs.n_real_zeros: number of real zeros (nonzero), defined between
%   (wfmin,wfmax) = (1/Tmax,1/Tmin)
% tfSpecs.n_pairs_cc_poles: number of cc pole pairs (nonzero), defined as
%   pairs (wn, zeta), between ((wnmin,wnmax),(0+tol,1))
% tfSpecs.n_pairs_cc_zeros: number of cc zero pairs (nonzero), defined as
%   pairs (wn, zeta), between ((wnmin,wnmax),(0+tol,1))
% tfSpecs.n_int_deriv = p: number of integrators/derivators; if p > 0 then
%   there are p integrators; if p < 0 then there are -p derivators
%

if nargin == 0
    error(message('set_unc_bound_det_options:NotEnoughInputs'));
end

tfSpecs = struct('n_real_poles',0,'n_real_zeros',0,...
    'n_pairs_cc_poles',0,'n_pairs_cc_zeros',0,...
    'n_int_deriv',0);

for k=1:2:length(varargin)
    tfSpecs.(varargin{k}) = varargin{k+1};
end

end
