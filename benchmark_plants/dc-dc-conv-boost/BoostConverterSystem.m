classdef BoostConverterSystem < System
    %BOOSTCONVERTERSYSTEM Summary of this class goes here
    %   Detailed explanation goes here

    properties
        params
        sysList
        m = 3;  % E, R, duty cycle
        n = 2;
        p = 1;
        
        satHi = 0.95;
        satLo = 0.00;

    end

    methods
        function obj = BoostConverterSystem(varargin)
            obj@System(varargin);
            
            obj.params = struct(...
            'L1',4e-5,'C1',6e-4,'rL1',0.01, ...
            'rC1',0.2,'rDS1',0.01,'rDS2',0.01, ...
            'VF1',0.2,'VF2',0.2 ...
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
            VF2 = obj.params.VF2;
            rDS1 = obj.params.rDS1;
            rDS2 = obj.params.rDS2;
            
            A_on = [-(rL1+rDS1)/L1, 0; ...
                0, -1/(rC1+R)/C1];
            B_on = [1/L1; 0];
            %
            A_off = [-(rL1+rDS2+rC1*R/(rC1+R))/L1, -R/(rC1+R)/L1; ...
                R/(rC1+R)/C1, -1/(rC1+R)/C1];
            B_off = [1/L1; 0];
            %
            DC_on = [-VF1/L1;0];
            DC_off = [-VF2/L1;0];

            dx = A_on*x*miu + A_off*x*(1-miu) + ...
                B_on*miu*E + B_off*(1-miu)*E + DC_on*miu + DC_off*(1-miu);
        end
        
        function y = h(obj,x,u,t)
            % y(t) = uR(t)
            R = u(2);
            miu = u(3);
            
            if miu < obj.satLo
                miu = obj.satLo;
            elseif miu > obj.satHi
                miu = obj.satHi;
            end
            
            rC1 = obj.params.rC1;
            
            C_on = [0,R/(R+rC1)];
            C_off = [rC1*R/(R+rC1),R/(R+rC1)];
            y = C_on*x*miu + C_off*x*(1-miu); % uR
            
            % % % 
            % y = x(2); % uC
        end

    end
end

