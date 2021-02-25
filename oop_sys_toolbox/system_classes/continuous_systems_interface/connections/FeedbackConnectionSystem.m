classdef FeedbackConnectionSystem < System
    %SYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    %
    % TODO: rewrite using LLFTConnectionSystem
    
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

        y1prev
        y2prev

        idx_u_sys1
        idx_y_sys2
    end
    
    methods
        function obj = FeedbackConnectionSystem(sys1,sys2,varargin)
            obj@System(varargin);
            
%             if ~isempty(varargin)
%                 % must have the same size
%                 obj.idx_y_sys2 = varargin{1};
%                 obj.idx_u_sys1 = varargin{2};
%             else
%                 obj.idx_y_sys2 = 1:sys2.p;
%                 obj.idx_u_sys1 = 1:sys1.m;
%             end

            obj.idx_u_sys1 = 1+sys1.m-sys2.p:sys1.m;
            obj.idx_y_sys2 = 1+sys2.m-sys1.p:sys2.m;
            
            obj.sysList = {sys1,sys2};
            
            obj.m = sys1.m;
            obj.n = sys1.n + sys2.n;
            obj.p = sys1.p;
            assert(sys1.p == sys2.m)
            obj.n1 = sys1.n;
            obj.n2 = sys2.n;
            obj.sys1 = sys1;
            obj.sys2 = sys2;
            
            obj.y1prev = zeros(size(sys1.p,1)); % [TODO: update based on h]
            obj.y2prev = zeros(size(sys2.p,1)); % [TODO: update based on h]
        end

        function dx = F(obj,x,u,t)
            % obj.x = x;
            
            x1 = x(1:obj.n1);
            x2 = x(obj.n1+1:obj.n1+obj.n2);
            
            u1 = zeros(length(u(1:obj.sys1.m)),1);
            u1(obj.idx_u_sys1) = u1(obj.idx_u_sys1) + obj.y2prev(obj.idx_y_sys2);
            y1 = obj.sys1.h(x1,u+u1,t);
            
            y2 = obj.sys2.h(x2,y1,t);

            obj.y1prev = y1;
            obj.y2prev = y2;

            u1 = zeros(length(u),1);
            u1(obj.idx_u_sys1) = u1(obj.idx_u_sys1) + obj.y2prev(obj.idx_y_sys2);
            dx = [
                obj.sys1.F(x1,u+u1,t);
                obj.sys2.F(x2,y1,t)
                ];
 
        end
            
        function y = h(obj,x,u,t)
            x1 = x(1:obj.n1);
            x2 = x(obj.n1+1:obj.n1+obj.n2);
            
            % y = obj.sys2.h(x2,obj.sys1.h(x1,u+obj.y2prev,t),t);
            y = obj.sys1.h(x1,u+obj.sys2.h(x2,obj.y1prev,t),t);
            
        end
        
    end

end
