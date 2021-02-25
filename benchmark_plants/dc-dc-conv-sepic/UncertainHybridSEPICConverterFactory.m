classdef UncertainHybridSEPICConverterFactory < UncertainHybridPlantFactory
    %UNCERTAINHYBRIDSEPICCONVERTERFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    % L1_actual = L1*(1 +/- L1tol)
    % C1_actual = C1*(1 +/- C1tol)
    %
    % DONE: TPWM should also be a parameter of the object/system and variable
    %
    
    properties
        params
        x0_hl
    end
    
    methods (Static)
        function tolLim = getTolSet(varargin)
            
            tolLim.L1tol = 0.2;
            tolLim.L2tol = 0.2;
            tolLim.Cintol = 0.2;
            tolLim.C1tol = 0.2;
            tolLim.C2tol = 0.2;
            tolLim.rCintol = 0.1;
            tolLim.rC1tol = 0.1;
            tolLim.rC2tol = 0.1;
            tolLim.rL1tol = 0.1;
            tolLim.rL2tol = 0.1;
            tolLim.rDS1tol = 0.1;
            tolLim.rDS2tol = 0.1;
            tolLim.VF1tol = 0.1;
            tolLim.VF2tol = 0.1;
            tolLim.Etol = 10;
            tolLim.Rtol = 5;
            %
            tolLim.TPWMtol = 0.2;
            
        end
        
    end
    
    methods
        function obj = UncertainHybridSEPICConverterFactory(varargin)
            obj@UncertainHybridPlantFactory(varargin)
            
            obj.params = struct(...
            'L1',120e-6,'L2',120e-6,'rL1',10e-3,'rL2',10e-3, ...
            'Cin',10e-6,'C1',16e-6,'C2',10e-6, ...
            'rCin',30e-3,'rC1',30e-3,'rC2',30e-3, ...
            'rDS1',0.01,'rDS2',0.01, ...
            'VF1',0.2,'VF2',0.2, 'TPWM',1.75e-5 ...
            );
        
            obj.x0_hl = [1;0];
        
            for k=1:2:length(varargin)
                obj.params.(varargin{k}) = varargin{k+1};
            end

            
        end
      
        function sys = getRandomPlant(obj, varargin)
            if isempty(varargin)
                nominal = false;
            else
                nominal = varargin{1};
            end
            
            tolLim = obj.getTolSet();

            L1 = obj.params.L1*(1 + obj.RNGB(nominal)*tolLim.L1tol);
            L2 = obj.params.L2*(1 + obj.RNGB(nominal)*tolLim.L2tol);
            Cin = obj.params.Cin*(1 + obj.RNGB(nominal)*tolLim.Cintol);
            C1 = obj.params.C1*(1 + obj.RNGB(nominal)*tolLim.C1tol);
            C2 = obj.params.C2*(1 + obj.RNGB(nominal)*tolLim.C2tol);
            rL1 = obj.params.rL1*(1 + obj.RNGB(nominal)*tolLim.rL1tol);
            rL2 = obj.params.rL2*(1 + obj.RNGB(nominal)*tolLim.rL2tol);
            rCin = obj.params.rC1*(1 + obj.RNGB(nominal)*tolLim.rCintol);
            rC1 = obj.params.rC1*(1 + obj.RNGB(nominal)*tolLim.rC1tol);
            rC2 = obj.params.rC2*(1 + obj.RNGB(nominal)*tolLim.rC2tol);
            VF1 = obj.params.VF1*(1 + obj.RNGB(nominal)*tolLim.VF1tol);
            VF2 = obj.params.VF2*(1 + obj.RNGB(nominal)*tolLim.VF2tol);
            rDS1 = obj.params.rDS1*(1 + obj.RNGB(nominal)*tolLim.rDS1tol);
            rDS2 = obj.params.rDS2*(1 + obj.RNGB(nominal)*tolLim.rDS2tol);
            TPWM = obj.params.TPWM*(1+obj.RNGB(nominal)*tolLim.TPWMtol);
            %
            sys = SEPICHybrid2ConverterSystem(...
                'L1',L1,'L2',L2,'Cin',Cin',...
                'C1',C1,'C2',C2,...
                'rL1',rL1,'rL2',rL2,'rCin',rCin,'rC1',rC1,'rC2',rC2,...
                'VF1',VF1,'VF2',VF2,'rDS1',rDS1,'rDS2',rDS2,'TPWM',TPWM...
            );
        end
        
    end
end

