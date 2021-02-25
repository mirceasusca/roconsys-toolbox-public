classdef SEPICHybrid2ConverterSystem < HybridSystem
    %SEPICHybrid2ConverterSystem Summary of this class goes here
    %   Detailed explanation goes here
    % TODO!!

    properties
        params
        sysList
        m = 3;  % E, R, duty cycle
        n = 7;  % uCin, iL1, uC1, iL2, uC2, q, tau
        p = 1;  % uR
        
        satHi = 0.95;
        satLo = 0.00;

    end

    methods
        function obj = SEPICHybrid2ConverterSystem(varargin)
            obj@HybridSystem(varargin);
            
            obj.params = struct(...
            'L1',120e-6,'L2',120e-6,'rL1',10e-3,'rL2',10e-3, ...
            'Cin',10e-6,'C1',16e-6,'C2',10e-6, ...
            'rCin',30e-3,'rC1',30e-3,'rC2',30e-3, ...
            'rDS1',0.01,'rDS2',0.01, ...
            'VF1',0.2,'VF2',0.2 ,...
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
            L2 = obj.params.L2;
            Cin = obj.params.Cin;
            C1 = obj.params.C1;
            C2 = obj.params.C2;
            rL1 = obj.params.rL1;
            rL2 = obj.params.rL2;
            rCin = obj.params.rCin;
            rC1 = obj.params.rC1;
            rC2 = obj.params.rC2;
            VF1 = obj.params.VF1;
            VF2 = obj.params.VF2;
            rDS1 = obj.params.rDS1;
            rDS2 = obj.params.rDS2;
            
            q = round(x(6));

            if q == 1 
                % DONE: replace for SEPIC
                A_on = [
                    -1/rCin/Cin,0,0,0,0;
                    1/L1,(-rCin-rL1-rDS1)/L1,0,rDS2/L1,0; % rCin-rL1
                    0,0,0,1/C1,0;
                    0,-rDS1/L2,-1/L2,(-rDS1-rC1-rL2)/L2,0;
                    0,0,0,0,-1/(R+rC2)/C2
                    ];
                B_on = [1/rCin/Cin;0;0;0;0];
                DC_on = VF1*[0;-1/L1;0;1/L2;0];
                %
                z = A_on*x(1:5)+B_on*E+DC_on;
            elseif q == 2               
                % DONE: replace for SEPIC
                A_off = [
                    -1/rCin/Cin,0,0,0,0;
                    1/L1,(-rL1-rC1-rDS1-rC2-rCin)/L1,-1/L1,(rDS2+rC2)/L1,-1/L1;
                    0,1/C1,0,0,0;
                    0,(rDS2+rC2)/L2,0,(-rL2-rDS2-rC2)/L2,1/L2;
                    0,R/(R+rC2)/C2,0,-R/(R+rC2)/C2,-1/(R+rC2)/C2
                ];
                B_off = [1/rCin/Cin;0;0;0;0];
                DC_off = VF2*[0;-1/L1;0;1/L2;0];
                %
                z = A_off*x(1:5)+B_off*E+DC_off;
            else
                error('Should not reach here.');
            end

            dx = [z;0;1];

        end
        
        function xplus = G(obj,x,u,t)

            q = round(x(6));
            tau = x(7);

            xplus = [x(1);x(2);x(3);x(4);x(5);q;tau];

            if q == 1
                xplus(6) = 2; % q = 2
            elseif q == 2
                % if tau >= obj.params.TPWM
                xplus(6) = 1; % q = 1
                xplus(7) = 0; % tau = 0
                % end
            end

        end
        
        function inside = C(obj,x,u,t)

            q = round(x(6));
            tau = x(7);

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

            q = round(x(6));
            tau = x(7);
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
            % y = x(5);  % y(t) = u_C2(t) = x(5);
             
            R = u(2);
            rC2 = obj.params.rC2;
            
            q = round(x(6));
            
            C_on = [0,0,0,0,R/(R+rC2)];
            C_off = [0,R*rC2/(R+rC2),0,-R*rC2/(R+rC2),R/(R+rC2)];
            
            if q == 1  % ON
                y = C_on*x(1:5);
            elseif q == 2  % OFF
                y = C_off*x(1:5);
            else
                disp('Should not reach here!');
                y = C_on*x(1:5);
            end
            
        end

    end
end

