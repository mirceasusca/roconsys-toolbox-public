classdef UncertainHybridBuckConverterFactory < UncertainHybridPlantFactory
    %UNCERTAINHYBRIDBUCKCONVERTERFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    % L1_actual = L1*(1 +/- L1tol)
    % C1_actual = C1*(1 +/- C1tol)
    % ...
    % E_actual = E +/- Etol
    % Rld_actual = Rld +/- Rtol
    %
    % TODO!!
    
    properties
        params
        x0_hl
    end
    
    methods (Static)
        function tolLim = getTolSet(varargin)
            
            tolLim.L1tol = 0.2;
            tolLim.C1tol = 0.2;
            tolLim.rC1tol = 0.1;
            tolLim.rL1tol = 0.1;
            tolLim.rDS1tol = 0.1;
            tolLim.rDS2tol = 0.1;
            tolLim.VF1tol = 0.1;
            tolLim.VF2tol = 0.1;
            tolLim.Etol = 1;
            tolLim.Rtol = 1;
            %
            tolLim.TPWMtol = 0.2;
            
        end
        
    end
    
    methods
        function obj = UncertainHybridBuckConverterFactory(varargin)
            obj@UncertainHybridPlantFactory(varargin)
            
            obj.params = struct(...
            'L1',40e-6,'rL1',10e-3,'C1',600e-6,'rC1',0.2,...
            'rDS1',0.01,'rDS2',0.01,'VF1',0.2,'VF2',0.2 ...
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
            C1 = obj.params.C1*(1 + obj.RNGB(nominal)*tolLim.C1tol);
            rL1 = obj.params.rL1*(1 + obj.RNGB(nominal)*tolLim.rL1tol);
            rC1 = obj.params.rC1*(1 + obj.RNGB(nominal)*tolLim.rC1tol);
            VF1 = obj.params.VF1*(1 + obj.RNGB(nominal)*tolLim.VF1tol);
            VF2 = obj.params.VF2*(1 + obj.RNGB(nominal)*tolLim.VF2tol);
            rDS1 = obj.params.rDS1*(1 + obj.RNGB(nominal)*tolLim.rDS1tol);
            rDS2 = obj.params.rDS2*(1 + obj.RNGB(nominal)*tolLim.rDS2tol);
            TPWM = obj.params.TPWM*(1+obj.RNGB(nominal)*tolLim.TPWMtol);
            sys = BuckHybrid2ConverterSystem('L1',L1,'C1',C1,...
                'rL1',rL1,'rC1',rC1,...
                'VF1',VF1,'VF2',VF2,'rDS1',rDS1,'rDS2',rDS2,'TPWM',TPWM ...
                );
        end
        
    end
end

