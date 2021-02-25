function obj = set_eq_point_options(varargin)
% Define struct with all necessary fields to be given as input argument for
% System.findEqPoint(); much easier to keep track of fields in this way.
% Assertions for dimensionalities of the values are checked in 
% System.findEqPoint().
% 
% For a system with m inputs, n states and p outputs:
% xeq: specifies state desired values
% xeqidx: specifies the index vector from 1:n for the values in xeq
% xunkguess: specifies guess values for unknown states
% xunkidx: specifies the indices of unknown state values
% ueq: input desired (fixed) values
% ueqidx: index vector from 1:m for the values specified in ueq
% uunkguess: specifies guess values for unknown inputs
% uunkidx: specifies the indices of unknown input values
% yeq: output desired values
% yeqidx: index vector from 1:p for the values specified in yeq
% yunkguess: specifies guess values for unknown outputs
% yunkidx: specifies the indices of unknown output values
% 
% Other fields in the struct will be automatically computed in 
% System.findEqPoint(), check its documentation and source code.
%

L = length(varargin);

assert(mod(L,2) == 0,'Arguments must be in pairs of Field and Value')

obj = struct(...
    'solve_for_state_only',true,'solve_for_time',false,...
    'xeq',[],'xeqidx',[],'xunkguess',[],'xunkidx',[],...
    'ueq',[],'ueqidx',[],'uunkguess',[],'uunkidx',[],...
    'yeq',[],'yeqidx',[],'tunkguess',0 ...
);

for i = 1:L/2
   field = varargin{2*i-1};
   value = varargin{2*i};
   
   % store values as column vectors
   if size(value,2) > 1
       obj.(field) = value';
   else
       obj.(field) = value;
   end
   
   if strcmp(field,'yeq')
       obj.solve_for_state_only = false;
   end
end

end