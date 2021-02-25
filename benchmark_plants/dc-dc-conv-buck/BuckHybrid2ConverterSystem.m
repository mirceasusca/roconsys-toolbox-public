classdef BuckHybrid2ConverterSystem < HybridSystem
    %BuckHybrid3ConverterSystem Summary of this class goes here
    %   Detailed explanation goes here
    % TODO!!

    properties
        params
        sysList
        m = 3;  % E, R, duty cycle
        n = 4;  % iL, uC, q, tau
        p = 1;
        
        satHi = 0.95;
        satLo = 0.00;

    end

    methods
        function obj = BuckHybrid2ConverterSystem(varargin)
            obj@HybridSystem(varargin);
            
            obj.params = struct(...
            'L1',40e-6,'rL1',10e-3,'C1',600e-6,'rC1',0.2,...
            'rDS1',0.01,'rDS2',0.01,'VF1',0.2,'VF2',0.2,...
            'TPWM',1.75e-5);
        
            if isempty(varargin)
                return
            end

            for k=1:2:length(varargin)
                obj.params.(varargin{k}) = varargin{k+1};
            end
                
            assert(obj.params.TPWM > 0)

        end
        
        function dx = F(obj,x,u,t)
            E = u(1);
            R = u(2);
 
            L1 = obj.params.L1;
            C1 = obj.params.C1;
            rL1 = obj.params.rL1;
            rC1 = obj.params.rC1;
            VF1 = obj.params.VF1;
            VF2 = obj.params.VF2;
            rDS1 = obj.params.rDS1;
            rDS2 = obj.params.rDS2;
           
            q = round(x(3));

            if q == 1 
                % DONE: replace for buck
                A_on = [-(rL1+rDS1+rC1*R/(R+rC1))/L1, -R/(R+rC1)/L1; 
                    R/(R+rC1)/C1, -1/(rC1+R)/C1];
                B_on = [1/L1; 0];
                DC_on = [-VF1/L1;0];
                %
                z = A_on*x(1:2)+B_on*E+DC_on;
            elseif q == 2               
                % DONE: replace for buck
                A_off = [-(rL1-rDS2+rC1*R/(rC1+R))/L1, -R/(rC1+R)/L1; 
                    R/(rC1+R)/C1, -1/(rC1+R)/C1];
                B_off = [0; 0];
                DC_off = [-VF2/L1;0];
                %
                z = A_off*x(1:2)+B_off*E+DC_off;
            else
                error('Should not reach here.');
            end

            dx = [z;0;1];

        end
        
        function xplus = G(obj,x,u,t)

            q = x(3);
            tau = x(4);

            xplus = [x(1);x(2);q;tau];

            if q == 1
                xplus(3) = 2; % q = 2
            elseif q == 2
                % if tau >= obj.params.TPWM
                xplus(3) = 1; % q = 1
                xplus(4) = 0; % tau = 0
                % end
            end

        end
        
        function inside = C(obj,x,u,t)

            q = x(3);
            tau = x(4);

            miu = u(3);

            if miu < obj.satLo
                miu = obj.satLo;
            elseif miu > obj.satHi
                miu = obj.satHi;
            end
            
            inside = 0;
            if ((q == 1) && (tau <= miu*obj.params.TPWM)) || ...
                    ((q == 2) && (tau > miu*obj.params.TPWM))
                inside = 1;
            end
            
        end
        
        function inside = D(obj,x,u,t)

            q = x(3);
            tau = x(4);
            miu = u(3);

            if miu < obj.satLo
                miu = obj.satLo;
            elseif miu > obj.satHi
                miu = obj.satHi;
            end
            
            inside = 0;
            if ((q == 1) && tau > miu*obj.params.TPWM) ||...
                    ((q == 2) && tau >= obj.params.TPWM)
                inside = 1;
            end

        end

        function y = h(obj,x,u,t)
            % y(t) = uR(t)  % measurable output           
            rC1 = obj.params.rC1;
            R = u(2);
            
            Ra = R/(R+rC1);
            y = rC1*Ra*x(1) + Ra*x(2);  % same equation in both ON and OFF
            
            % y = x(2);  % y(t) = uC(t) = x2(t);
        end

    end
end

