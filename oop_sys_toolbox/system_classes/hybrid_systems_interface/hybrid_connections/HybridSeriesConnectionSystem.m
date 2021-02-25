classdef HybridSeriesConnectionSystem < HybridSystem & SeriesConnectionSystem
    %HybridSeriesConnectionSystem Summary of this class goes here
    %   Detailed explanation goes here
    %
    % DONE: test using the same examples as in the basic connections, but
    % wrapped to Hybrid systems
    %

    methods
        function obj = HybridSeriesConnectionSystem(sys1,sys2,varargin)
            obj@HybridSystem(varargin);
            obj@SeriesConnectionSystem(sys1,sys2,varargin);
            
            sys1 = HybridSystem.wrap_to_hybrid_system(sys1);
            sys2 = HybridSystem.wrap_to_hybrid_system(sys2);
            
            obj.sysList = {sys1,sys2};
            obj.sys1 = sys1;
            obj.sys2 = sys2;
            
        end
        
        function dx = F(obj,x,u,t)
            dx = obj.F@SeriesConnectionSystem(x,u,t);
        end
        
        function y = h(obj,x,u,t)
            y = obj.h@SeriesConnectionSystem(x,u,t);
            
        end
        
        function xplus = G(obj,x,u,t)
            x1 = x(1:obj.n1);
            x2 = x(obj.n1+1:obj.n1+obj.n2);
            
            xplus1 = x1;
            xplus2 = x2;
            
            if obj.sys1.jumpLogic(x1,u,t)
                xplus1 = obj.sys1.G(x1,u,t);
            end
            
            if obj.sys2.jumpLogic(x2,sys1.h(x1,u,t),t)
                xplus2 = obj.sys2.G(x2,sys1.h(x1,u,t),t);
            end
            
            xplus = [xplus1;xplus2];
        end
        
        function inside = C(obj,x,u,t)
            x1 = x(1:obj.n1);
            x2 = x(obj.n1+1:obj.n1+obj.n2);
            
            inside = obj.sys1.C(x1,u,t) &&...
                obj.sys2.C(x2,obj.sys1.h(x1,u,t),t);
            
        end
        
        function inside = D(obj,x,u,t)
            x1 = x(1:obj.n1);
            x2 = x(obj.n1+1:obj.n1+obj.n2);
            
            inside = obj.sys1.D(x1,u,t) ||...
                obj.sys2.D(x2,obj.sys1.h(x1,u,t),t);

        end
        
    end
    
end
