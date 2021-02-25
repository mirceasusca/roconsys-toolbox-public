classdef SEPICConverterSystem < System
    %SEPICCONVERTERSYSTEM Summary of this class goes here
    %   Detailed explanation goes here

    properties
        params
        sysList
        m = 3;  % E, R, duty cycle
        n = 5;
        p = 1;
        
        satHi = 0.95;
        satLo = 0.00;

    end

    methods
        function obj = SEPICConverterSystem(varargin)
            obj@System(varargin);
            
            obj.params = struct(...
            'L1',120e-6,'L2',120e-6,'rL1',10e-3,'rL2',10e-3, ...
            'Cin',10e-6,'C1',16e-6,'C2',10e-6, ...
            'rCin',30e-3,'rC1',30e-3,'rC2',30e-3, ...
            'rDS1',0.01,'rDS2',0.01, ...
            'VF1',0.2,'VF2',0.2 ...
            );
    
            if isempty(varargin)
                return
            else
                for k=1:2:length(varargin)
                    obj.params.(varargin{k}) = varargin{k+1};
                end
            end
            
            assert(obj.params.rCin > 0);
            
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
            
            A_on = [
                -1/rCin/Cin,0,0,0,0;
                1/L1,(-rCin-rL1-rDS1)/L1,0,rDS2/L1,0; % rCin-rL1
                0,0,0,1/C1,0;
                0,-rDS1/L2,-1/L2,(-rDS1-rC1-rL2)/L2,0;
                0,0,0,0,-1/(R+rC2)/C2
                ];
            B_on = [1/rCin/Cin;0;0;0;0];
            %
            A_off = [
                -1/rCin/Cin,0,0,0,0;
                1/L1,(-rL1-rC1-rDS1-rC2-rCin)/L1,-1/L1,(rDS2+rC2)/L1,-1/L1;
                0,1/C1,0,0,0;
                0,(rDS2+rC2)/L2,0,(-rL2-rDS2-rC2)/L2,1/L2;
                0,R/(R+rC2)/C2,0,-R/(R+rC2)/C2,-1/(R+rC2)/C2
                ];
            B_off = [1/rCin/Cin;0;0;0;0];
            %
            DC_on = VF1*[0;-1/L1;0;1/L2;0];
            DC_off = VF2*[0;-1/L1;0;1/L2;0];

            dx = A_on*x*miu + A_off*x*(1-miu) + ...
                B_on*miu*E + B_off*(1-miu)*E + DC_on*miu + DC_off*(1-miu);
        end
        
        function y = h(obj,x,u,t)
            R = u(2);
            miu = u(3);
 
            if miu < obj.satLo
                miu = obj.satLo;
            elseif miu > obj.satHi
                miu = obj.satHi;
            end
            
            rC2 = obj.params.rC2;
            
            C_on = [0,0,0,0,R/(R+rC2)];
            C_off = [0,R*rC2/(R+rC2),0,-R*rC2/(R+rC2),R/(R+rC2)];
            
            y = C_on*x*miu + C_off*x*(1-miu);
        end

    end
end