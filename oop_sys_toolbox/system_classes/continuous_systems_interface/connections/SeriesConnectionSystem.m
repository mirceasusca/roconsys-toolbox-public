classdef SeriesConnectionSystem < System
    %SYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        params
        sysList
        m  % num. inputs
        n  % num. states
        p  % num. outputs
        
        sys1
        sys2
        n1
        n2

    end
    
    methods
        function obj = SeriesConnectionSystem(sys1,sys2,varargin)
            obj@System(varargin);
            
            obj.sysList = {sys1,sys2};
            
            obj.m = sys1.m;
            obj.n = sys1.n + sys2.n;
            obj.p = sys2.p;
            assert(sys1.p == sys2.m)
            obj.n1 = sys1.n;
            obj.n2 = sys2.n;
            obj.sys1 = sys1;
            obj.sys2 = sys2;

        end
        
        function dx = F(obj,x,u,t)           
            x1 = x(1:obj.n1);
            x2 = x(obj.n1+1:obj.n1+obj.n2);
            dx = [
                obj.sys1.F(x1,u,t);
                obj.sys2.F(x2,obj.sys1.h(x1,u,t),t)
                ];
        end

        function y = h(obj,x,u,t)
            x1 = x(1:obj.n1);
            x2 = x(obj.n1+1:obj.n1+obj.n2);
            y = obj.sys2.h(x2,obj.sys1.h(x1,u,t),t);
        end

    end

end
