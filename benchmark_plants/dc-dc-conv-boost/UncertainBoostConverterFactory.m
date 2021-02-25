classdef UncertainBoostConverterFactory < UncertainPlantFactory
    %UNCERTAINBOOSTCONVERTERFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    % L1_actual = L1*(1 +/- L1tol)
    % C1_actual = C1*(1 +/- C1tol)
    % ...
    % E_actual = E +/- Etol
    % Rld_actual = Rld +/- Rtol
    %
    
    properties
        params
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
            
        end
        
        function eqOpts = getEqOpts(nominal,varargin)
            %DONE: refactor using only RNGB and RNGU and tolLim
            if isempty(varargin)
                tolLim = UncertainBoostConverterFactory.getTolSet();
            else
                tolLim = varargin{1};
            end
            r1 = UncertainBoostConverterFactory.RNGB(nominal);
            r2 = UncertainBoostConverterFactory.RNGB(nominal);
            %
            % it's ok to have tolLim parameters in the eqOpts, as the
            % nominal eqOpts will cancel them anyway through the r1, r2
            % terms
            eqOpts = set_eq_point_options(...
                    'yeq',[24],'yeqidx',[1],...
                    'xunkguess',[3;24],'xunkidx',[1;2],...
                    'ueq',[12+tolLim.Etol*r1;...
                    15+tolLim.Rtol*r2],'ueqidx',[1;2],...
                    'uunkguess',[0.5],'uunkidx',[3]...
                    );
        end
        
    end
    
    methods
        function obj = UncertainBoostConverterFactory(varargin)
            obj@UncertainPlantFactory(varargin)
            
            obj.params = struct(...
            'L1',4e-5,'C1',6e-4, ...
            'rL1',0.01,'rC1',0.2, ...
            'rDS1',0.01,'rDS2',0.01, ...
            'VF1',0.2,'VF2',0.2 ...
            );

    
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
            sys = BoostConverterSystem('L1',L1,'C1',C1,...
                'rL1',rL1,'rC1',rC1,...
                'VF1',VF1,'VF2',VF2,'rDS1',rDS1,'rDS2',rDS2 ...
                );
        end
        
    end
end

