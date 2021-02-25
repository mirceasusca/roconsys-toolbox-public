classdef LTIEqSystem < System
    %LTIEQSYSTEM System which has its dynamics based on an LTI system when
    % taking into account its equilibrium point by offsets. This structure 
    % is a NONLINEAR system (affine). It should NOT inherit LTISystem.
    %
    % Implements Fig. 12 (linearized model part) from:
    % "Linearization: Students Forget the Operating Point", by
    % Jirka Roubal, Petr Husek, Jan Stecha, IEEE Trans. on Education,
    % Vol. 53, No. 3, August 2010. See Bibliography.
    %
    
    properties
        % inherited from class System
        params
        sysList
        m
        n
        p
        
        x0
        u0
        y0
        t0
        
        A
        B
        C
        D
    end

    methods
        function obj = LTIEqSystem(A,B,C,D,x0,u0,y0,t0,varargin)
            %LTISYSTEM 
            obj@System(varargin);
            
            obj.A = A;
            obj.B = B;
            obj.C = C;
            obj.D = D;
            %
            if ~isempty(A) && ~isempty(B) && ~isempty(C)
                assert(size(A,1) == size(A,2));
                assert(size(B,1) == size(A,1));
                assert(size(C,2) == size(A,1));
                assert(size(D,1) == size(C,1));
                assert(size(D,2) == size(B,2));
            end
            %
            obj.m = size(B,2);
            obj.n = size(A,1);
            obj.p = size(C,1);
            
            obj.x0 = x0;
            obj.u0 = u0;
            obj.y0 = y0;
            obj.t0 = t0;
                        
        end
        
        function dx = F(obj,x,u,t)
            dx = obj.A*(x-obj.x0) + obj.B*(u-obj.u0);
            
        end
        
        function y = h(obj,x,u,t)
            y = obj.C*(x-obj.x0) + obj.D*(u-obj.u0) + obj.y0;

        end
        
    end
end

