classdef HybridSystemWrapper < HybridSystem
    % Turns a non-hybrid system into a hybrid system through its interface.
    % Used when there is a hybrid system in the loop; the solver changes
    % and all components must be adapted to the extended hybrid solver
    % interface (HyEQSolver).
    %
    
    properties
        params
        sysList % to keep track for system interconnections
        m  % num. inputs
        n  % num. states
        p  % num. outputs
    end
    
    properties
        Sys
    end
    
    methods
        function obj = HybridSystemWrapper(Sys, varargin)
            obj@HybridSystem(varargin);
            
            obj.params = Sys.params;
            assert(length(Sys.sysList) <= 1); 
            obj.sysList = Sys.sysList;
            obj.m = Sys.m;
            obj.n = Sys.n;
            obj.p = Sys.p;
            
            assert(~isa(Sys,'HybridSystem'),'Input System must not be Hybrid'); 
            obj.Sys = Sys;
        end
    
        function dx = F(obj,x,u,t)
            dx = obj.Sys.F(x,u,t);
        end
            
        function xplus = G(obj,x,u,t)
           xplus = x;  % no jumps 
        end
        
        function inside = C(obj,x,u,t)
            inside = 1;  % the state is always the flow set
        end
        
        function inside = D(obj,x,u,t)
           inside = 0;  % the state is never in the jump set
        end
        
        function y = h(obj,x,u,t)
            y = obj.Sys.h(x,u,t);
        end

    end
    
end
