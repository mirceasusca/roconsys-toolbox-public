classdef TWSBRSystem < System
    %BOOSTCONVERTERSYSTEM Summary of this class goes here
    %   Detailed explanation goes here

    properties
        params
        sysList
        m = 1; 
        n = 4;
        p = 1;

    end

    methods
        function obj = TWSBRSystem(varargin)
            obj@System(varargin);
            
            obj.params = struct(...
                'mc',0.13,'mp',2.07,'I',0.036,'l',0.121,'f',0.1 ...
            );
    
            if isempty(varargin)
                return
            else
                for k=1:2:length(varargin)
                    obj.params.(varargin{k}) = varargin{k+1};
                end
            end
            % DONE: remake for struct and key-value pairs: for specified params (not having default values)
            
        end
        
        function dx = F(obj,x,u,t)
            
            g = 9.81;
            
            mc = obj.params.mc;
            mp = obj.params.mp;
            I = obj.params.I;
            l = obj.params.l;
            f = obj.params.f;

            A= [
                0                     1                                   0                                  0;
                0  (-(I+mp*l*l)*f) / (I*(mc+mp)+ mc*mp*l*l)  (mp*mp*g*l*l) / (I*(mc + mp)+ mc*mp*l*l)        0;
                0                     0                                   0                                  1;
                0  (-mp*l*f) / (I*(mc+mp)+ mc*mp*l*l)        (mp*g*l)*(mc+mp) / (I*(mc + mp)+ mc*mp*l*l)     0;
               ];

            B=[
                                0;
                (I+mp*l*l) / (I*(mc+mp)+ mc*mp*l*l);
                                0;
                   (mp*l) / (I*(mc+mp)+ mc*mp*l*l);
               ];

            dx = A*x + B*u;
        end
        
        function y = h(obj,x,u,t)
            y = x(1);
        end

    end
end

