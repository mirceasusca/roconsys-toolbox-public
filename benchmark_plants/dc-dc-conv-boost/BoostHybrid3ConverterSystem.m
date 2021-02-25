classdef BoostHybrid3ConverterSystem < HybridSystem
    %BoostHybrid3ConverterSystem Summary of this class goes here
    %   Detailed explanation goes here

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
        function obj = BoostHybrid3ConverterSystem(varargin)
            obj@HybridSystem(varargin);
            
            obj.params = struct(...
            'L1',4e-5,'C1',6e-4,'rL1',0.01, ...
            'rC1',0.2,'rDS1',0.01,'rDS2',0.01, ...
            'VF1',0.2,'VF2',0.2,'TPWM',1.75e-5 ...
            );
        
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
                A_on = [-(rL1+rDS1)/L1, 0; 0, -1/(rC1+R)/C1];
                B_on = [1/L1; 0];
                DC_on = [-VF1/L1;0];
                %
                z = A_on*x(1:2)+B_on*E+DC_on;
            elseif q == 2               
                A_off = [-(rL1+rDS2+rC1*R/(rC1+R))/L1, ...
                    -R/(rC1+R)/L1; R/(rC1+R)/C1, -1/(rC1+R)/C1];
                B_off = [1/L1; 0];
                DC_off = [-VF2/L1;0];
                %
                z = A_off*x(1:2)+B_off*E+DC_off;
            elseif q == 3
                A_dcm = [0, 0; 0, -1/(rC1+R)/C1];
                B_dcm = [0; 0];
                %
                z = A_dcm*x(1:2)+B_dcm*E;
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
                if x(1) <= 0
                    xplus(3) = 3; % q = 3
                    xplus(1) = 0; % iL = 0
                elseif tau >= obj.params.TPWM
                    xplus(3) = 1; % q = 1
                    xplus(4) = 0; % tau = 0
                else
                    error('Should not reach here.');
                end
            elseif q == 3
                xplus(3) = 1; % q = 1
                xplus(4) = 0; % tau = 0
            else
                error('Should not reach here.');
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
                    ((q == 2) && (tau > miu*obj.params.TPWM) && (x(1) > 0)) || ...
                    ((q == 3) && (tau > miu*obj.params.TPWM) && (x(1) <= 0))
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
                    ((q == 2) && tau >= obj.params.TPWM) || ...
                    ((q == 2) && x(1) <= 0) || ...
                    ((q == 3) && tau >= obj.params.TPWM)
                inside = 1;
            end

        end

        function y = h(obj,x,u,t)
            R = u(2);
            q = x(3);
            % tau = x(4);
            % miu = u(3);
            rC1 = obj.params.rC1;
            
            q = round(q);
            
            if q == 1  % ON
                y = R/(R+rC1)*x(2);
            elseif q == 2  % OFF
                y = R/(R+rC1)*(rC1*x(1) + x(2));
            elseif q == 3
                y = R/(R+rC1)*x(2);  % (same behaviour as in ON): DONE: check if correct; yes
            else
                disp('Should not reach here!');
                y = R/(R+rC1)*x(2);
            end
            
            % y = x(2);  % always y = uC
        end

    end
end
