classdef LTISystem < System
    %LTISYSTEM Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % inherited from class System
        params
        sysList
        m
        n
        p
        
        A
        B
        C
        D
    end

    methods
        function obj = LTISystem(A,B,C,D,varargin)
            %LTISYSTEM Construct an instance of this class
            %   Detailed explanation goes here
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
                        
        end
        
        function dx = F(obj,x,u,t)
            dx = obj.A*x+obj.B*u;
        end
        
        function y = h(obj,x,u,t)
            y = obj.C*x+obj.D*u;
        end

        function sys = getss(obj,varargin)
            % works if system is LTISystem only for now
            if isempty(varargin)
                sys = ss(obj.A,obj.B,obj.C,obj.D);
            else
                iu = varargin{1};
                iy = varargin{2};
                sys = ss(obj.A,obj.B(:,iu),obj.C(iy,:),obj.D(iy,iu));
            end
        end

    end
end

