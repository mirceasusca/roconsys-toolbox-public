classdef BuckConverterSystem < System
    % BUCKCONVERTERSYSTEM Summary of this class goes here
    %   Detailed explanation goes here

    properties
        params
        sysList
        m = 3;  % E, R, duty cycle
        n = 2;  % iL, uC
        p = 1;  % uC
        
        satHi = 0.95;
        satLo = 0.00;
        
    end

    methods
        function obj = BuckConverterSystem(varargin)
            obj@System(varargin);
            
            obj.params = struct(...
            'L1',40e-6,'rL1',10e-3,'C1',600e-6,'rC1',0.2,...
            'rDS1',0.01,'rDS2',0.01,'VF1',0.2,'VF2',0.2);
            
            if isempty(varargin)
                return
            else
                for k=1:2:length(varargin)
                    obj.params.(varargin{k}) = varargin{k+1};
                end
            end
        end
        
        function dx = F(obj,x,u,t)
            E = u(1);
            R = u(2);
            miu = u(3);
 
            if miu < obj.satLo
                miu = obj.satLo;
            elseif miu > obj.satHi
                miu = obj.satHi;
            end
            
            L1 = obj.params.L1;
            C1 = obj.params.C1;
            rL1 = obj.params.rL1;
            rC1 = obj.params.rC1;
            VF1 = obj.params.VF1;
            rDS1 = obj.params.rDS1;

            A0 = [-1/L1*(rL1+R*rC1/(R+rC1)-rDS1),-1/L1*R/(R+rC1);
                1/C1*R/(R+rC1), -1/C1/(R+rC1)];
            A1 = [-2/L1*rDS1,0;0,0];
            b0 = [-VF1/L1;0];
            b1 = [E/L1;0];
            
            dx = A0*x+b0 + (A1*x+b1)*miu;
        end
        
        function y = h(obj,x,u,t)
            % y(t) = uR(t) % measureable output
            rC1 = obj.params.rC1;
            R = u(2);
            
            Ra = R/(R+rC1);
            y = rC1*Ra*x(1) + Ra*x(2);  % same equation in both ON and OFF
            
            % y = [x(2)];  % y(t) = uC(t)
        end

    end
end

