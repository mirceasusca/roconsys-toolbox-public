classdef InvPendulumSystem < System
    %INVPENDULUM Summary of this class goes here
    %   Detailed explanation goes here
    % 
    % From "Linearization: Students Forget the Operating Point", by
    % Jirka Roubal, Petr Husek, Jan Stecha, IEEE Trans. on Education,
    % Vol. 53, No. 3, August 2010.
    %
    % Parameters:
    %  delta [1/s]
    %  l [m]
    %  g [m/s^2]
    % 
    % Recommended eq. point: u0 = 0; x10 = pi/2; x20 = 0; y0 = 90;
    %
   
    properties
        params
        sysList
        m = 1;  % u = (F/m) [m/s^2]
        n = 2;  % phi [rad], d(phi)/dt [rad/s]
        p = 1;  % y = phi [deg]
        
    end

    methods
        function obj = InvPendulumSystem(varargin)
            obj@System(varargin);
            
            obj.params = py.dict(pyargs(...
            'delta',0.25,'l',1,'g',9.81...
            ));
            
        end
        
        function dx = F(obj,x,u,t)
            % obj = obj.setState(x);
            delta = obj.params{'delta'};
            l = obj.params{'l'};
            g = obj.params{'g'};
            
            dx = [
                x(2);
                -2*delta*x(2)-3*g/2/l*cos(x(1)) + 3/2/l*u*sin(x(1));
            ];
        end
        
        function y = h(obj,x,u,t)
            y = 180/pi*x(1);
        end

    end
end
