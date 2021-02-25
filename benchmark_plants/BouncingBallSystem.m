classdef BouncingBallSystem < HybridSystem
    %
    
    properties
        params
        sysList % to keep track for system interconnections
        m  % num. inputs
        n  % num. states
        p  % num. outputs
        
        gamma = -9.81;
        lambda = 0.8;

    end
    
    methods
        function obj = BouncingBallSystem(varargin)
            obj@HybridSystem(varargin);
            
            obj.m = 0;
            obj.n = 2;
            obj.p = 2;

        end
    end
    
    methods 
        function dx = F(obj,x,u,t)
            dx = [x(2); obj.gamma];
            
        end
        
        function xplus = G(obj,x,u,t)
            xplus = [-x(1); -obj.lambda*x(2)];
        end
        
        function inside = C(obj,x,u,t)
            if x(1) >= 0
                inside = 1;
            else
                inside = 0;
            end
        end
        
        function inside = D(obj,x,u,t)
            if (x(1) <= 0 && x(2) <= 0)
                inside = 1;
            else
                inside = 0;
            end
        end
        
        function y = h(obj,x,u,t)
            y = x; 
        end

    end
    
end
