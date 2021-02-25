classdef (Abstract) HybridSystem < System
    %
    % rule for jumps:
    % rule = 1 -> priority for jumps
    % rule = 2 -> priority for flows
    %
    
    properties
        rule
        j_fin
    end
    
    methods
        function obj = HybridSystem(varargin)
            obj@System(varargin);

            obj.rule = 1;
            obj.j_fin = 1e5;
        end
    end
    
    methods (Abstract)
        dx = F(obj,x,u,t)     % continuous dynamics (flow map)
        xplus = G(obj,x,u,t)  % discrete dynamics (jump map)
        
        inside = C(obj,x,u,t) % flow set => applies F when inside
        inside = D(obj,x,u,t) % jump set => applies G when inside
        
        y = h(obj,x,u,t)

    end
    
    methods (Static)
        function sys_out = wrap_to_hybrid_system(sys)
            if ~isa(sys,'HybridSystem')
                sys_out = HybridSystemWrapper(sys);
            else
                sys_out = sys;
            end
            
        end
        
    end
    
    methods
        function [x,t,y,j] = sim(obj,x0,u,tfin,varargin)
            % u is a function of time with the same size as the number of
            % inputs of the system.
            %
            % tfin can be a single value, case in which the simulation time
            % given to ode will be [0,tfin], otherwise tfin is assumed to
            % be a vector of time values, and given accordingly to ode.
            %
            % optional argument: jfin maximum number of discrete steps to
            % be taken before stopping the simulation
            %
            
            if length(tfin) >= 2
                t_sim = tfin;
            else
                t_sim = [0,tfin];
            end
            
            if ~isempty(varargin)
                j_sim = [0,varargin{1}];
            else
                j_sim = [0,1e5];
            end
            
            try
               u(0);
            catch ME
                error('The argument "u" must be a function of t');
            end
            
            [t,j,x] = HyEQsolver(...
                @(x,t) obj.F(x,u(t),t),...
                @(x,t) obj.G(x,u(t),t),...
                @(x,t) obj.C(x,u(t),t),...
                @(x,t) obj.D(x,u(t),t),...
                x0,t_sim,j_sim,obj.rule,obj.solverOptions,obj.solverType);
            x = x';  % make each state vector in column form
            
            N = length(t);
            y = zeros(obj.p,N);
            for k=1:N
                y(:,k) = obj.h(x(:,k),u(t(k)),t(k));
            end
        end
        
        function jump = jumpLogic(obj,x,u,t)
            %
            
            c = obj.C(x,u,t);
            d = obj.D(x,u,t);
            r = rand(1);
            
            jump = ((d==1) && obj.rule == 1) ||...
                ((c==0) && (d==1) && (obj.rule==2)) ||...
                ((c==0) && (d==1) && (obj.rule==3)) ||...
                ((c==1) && (d==1) && (obj.rule==3) && (r>=0.5));
            
        end
        
        function [A,B,C,D,y0,x0,u0,t0] = linearize(obj,x0,u0,t0)
            throw(MException('HybridSystem:notImplemented',...
                'Not implemented error for hybrid systems!'))
        end
        
        function [x0,u0,y0,t0] = findEqPoint(obj,eqOpts)
            throw(MException('HybridSystem:notImplemented',...
                'Not implemented error for hybrid systems!'))
        end
        
    end
end
