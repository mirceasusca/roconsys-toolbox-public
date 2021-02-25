classdef UncertainSEPICConverterFactory < UncertainPlantFactory
    %UncertainSEPICConverterFactory Summary of this class goes here
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
%             eqOpts = set_eq_point_options(...
%                 'yeq',[12],'yeqidx',[1],...
%                 'xunkguess',[28;0.5;28;0.5;12],'xunkidx',[1;2;3;4;5],...
%                 'ueq',[28+tolLim.Etol*r1;...
%                 15+tolLim.Rtol*r2],'ueqidx',[1;2],...
%                 'uunkguess',[0.3],'uunkidx',[3]...
%                 );
            E = 300;
            R = 80;
            eqOpts = set_eq_point_options(...
                'yeq',[400],'yeqidx',[1],...
                'xunkguess',[28;0.5;28;-0.5;12],'xunkidx',[1;2;3;4;5],...
                'ueq',[E+tolLim.Etol*r1;...
                R+tolLim.Rtol*r2],'ueqidx',[1;2],...
                'uunkguess',[0.57],'uunkidx',[3]...
                );
        end
        
    end
    
    methods
        function obj = UncertainSEPICConverterFactory(varargin)
            obj@UncertainPlantFactory(varargin)
            
            obj.params = struct(...
            'L1',2.57e-3,'L2',1.71e-3,'rL1',130e-3,'rL2',110e-3, ...
            'Cin',3.57e-6,'C1',4.7e-6,'C2',3.57e-6, ...
            'rCin',270e-3,'rC1',270e-3,'rC2',350e-3, ...
            'rDS1',0.01,'rDS2',80e-3, ...
            'VF1',0.2,'VF2',0.62 ...
            );
            
%             obj.params = struct(...
%             'L1',120e-6,'L2',120e-6,'rL1',10e-3,'rL2',10e-3, ...
%             'Cin',10e-6,'C1',16e-6,'C2',10e-6, ...
%             'rCin',30e-3,'rC1',30e-3,'rC2',30e-3, ...
%             'rDS1',0.01,'rDS2',0.01, ...
%             'VF1',0.2,'VF2',0.2 ...
%             );
        
%             obj.params = struct(...
%             'L1',22e-6,'L2',22e-6,'rL1',10e-3,'rL2',10e-3, ...
%             'Cin',4.7e-6,'C1',1e-6,'C2',4.7e-6, ...
%             'rCin',30e-3,'rC1',30e-3,'rC2',30e-3, ...
%             'rDS1',0.01,'rDS2',0.01, ...
%             'VF1',0.2,'VF2',0.2 ...
%             );

    
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
            %
            sys = SEPICConverterSystem('L1',L1,'L2',L2,'Cin',Cin',...
                'C1',C1,'C2',C2,...
                'rL1',rL1,'rL2',rL2,'rCin',rCin,'rC1',rC1,'rC2',rC2,...
                'VF1',VF1,'VF2',VF2,'rDS1',rDS1,'rDS2',rDS2 ...
                );
        end
        
    end
end