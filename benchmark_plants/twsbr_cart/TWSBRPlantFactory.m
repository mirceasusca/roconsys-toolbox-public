classdef TWSBRPlantFactory < UncertainPlantFactory
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
            
            tolLim.mp_tol = 0.2;
            % tolLim.mc_tol = 0.0;
            tolLim.I_tol = 0.25;
            tolLim.l_tol = 0.2;
            tolLim.f_tol = 0.15;
        end
        
        function eqOpts = getEqOpts(nominal,varargin)
            %DONE: refactor using only RNGB and RNGU and tolLim
            %
            % it's ok to have tolLim parameters in the eqOpts, as the
            % nominal eqOpts will cancel them anyway through the r1, r2
            % terms
            eqOpts = set_eq_point_options(...
                    'yeq',[0],'yeqidx',[1],...
                    'xunkguess',[0;0;0;0],'xunkidx',[1;2;3;4],...
                    'uunkguess',[0.0],'uunkidx',[1]...
                    );
        end
        
    end
    
    methods
        function obj = TWSBRPlantFactory(varargin)
            obj@UncertainPlantFactory(varargin)
            
            obj.params = struct(...
                'mc',0.13,'mp',2.07,'I',0.036,'l',0.121,'f',0.1 ...
            );

        end
      
        function sys = getRandomPlant(obj, varargin)
            if isempty(varargin)
                nominal = false;
            else
                nominal = varargin{1};
            end
            
            tolLim = obj.getTolSet();

            mp = obj.params.mp*(1 + obj.RNGB(nominal)*tolLim.mp_tol);
            mc = obj.params.mc;
            I = obj.params.I*(1 + obj.RNGB(nominal)*tolLim.I_tol);
            l = obj.params.l*(1 + obj.RNGB(nominal)*tolLim.l_tol);
            f = obj.params.f*(1 + obj.RNGB(nominal)*tolLim.f_tol);
            sys = TWSBRSystem('mp',mp,'mc',mc,...
                'I',I,'l',l,'f',f);
        end
        
    end
end

