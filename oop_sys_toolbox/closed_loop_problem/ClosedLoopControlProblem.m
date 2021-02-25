classdef ClosedLoopControlProblem < handle
    %CLOSEDLOOPCONTROLPROBLEM Summary of this class goes here
    %   Detailed explanation goes here
    %
    % all fields, populated as phases are executed during the workflow
    % ability to save to disk this class instance and retain all experiment
    %   results
    % functions to show results, to test all imposed performances etc.
    %
    % save function from different states: uncertainty bound, robust
    % control optimization, controller order reduction , 
    % quantization analysis etc.
    %
    
    properties
        modelName
        savePath

        GF  % plant factory
        GHF % hybrid plant factory (optional, if plant supports it)
        GLF % uncertain linearized plant set (with optimized unc. bound)
                
        GLN  % nominal linearized plant
        EqN  % nominal equilibrium point
        eqOpts  % equilibrium point options
        
        uBound  % uncertainty bound structure
        uBoundOptimProb  % uncertainty bound optimization problem
        uOpts % uncertainty bound options
        tfSpecs  % uncertainty bound transfer function specifications (structure)
        
        rcOptimProblem  % robust control optimization problem
        Kopt  % optimal controller, after synthesis
        K     % controller after preprocessing (order reduction etc.)
        
    end
    
    methods
        function obj = ClosedLoopControlProblem(varargin)
            %CLOSEDLOOPCONTROLPROBLEM Construct an instance of this class
            %   Detailed explanation goes here
            global toolbox_path
            obj.savePath = [toolbox_path,'data/'];
            obj.modelName = 'model';
            
            obj.GF = [];
            obj.GHF = [];
            obj.GLF = [];
            obj.GLN = [];
            obj.EqN = [];
            obj.tfSpecs = [];
            obj.uBound = [];
            
            obj.uBoundOptimProb = [];
            
            obj.eqOpts = [];
            obj.uOpts = [];
            
            obj.rcOptimProblem = [];
            obj.Kopt = [];
            obj.K = [];
            
            if nargin == 0
                error(message('ClosedLoopControlProblem:NotEnoughInputs'));
            end

            for k=1:2:length(varargin)
                obj.(varargin{k}) = varargin{k+1};
            end

        end
        
        function [uncBound,W,INFO] = optimizeUncertaintyBound(obj,varargin)
            % nargin > 0 is implicit through obj
            if nargin > 1  
                obj.tfSpecs = varargin{1};
                
                if nargin > 2
                    x0 = varargin{2};
                    
                    if nargin > 3
                        opts = varargin{3};
                    else
                        opts = [];
                    end
                else
                    x0 = [];
                end
            end
            
            
            obj.uBound = obj.GF.getUncertaintyModelBoundary(obj.uOpts);
            
            obj.GLN = obj.uBound.pNom;
            obj.EqN = obj.uBound.nomEqPoint;
            
            obj.uBoundOptimProb = UncertaintyOptimProblem(obj.tfSpecs, obj.uBound, opts);
           
            [W,INFO] = obj.uBoundOptimProb.optimize(x0);
            obj.uBound.W = W;
            
            uncBound = obj.uBound;
            obj.save_current_object();
        end
        
        function Punc = getUncLinearPlantSet(obj,uOrd)
            % Returns the uncertain plant Punc with control signals as
            % input and measurement signals as output. To be used for
            % robust control synthesis. The other inputs (not included in
            % Punc) will be considered Delta u = 0, so the system is at
            % equilibrium.
            %
            % TODO: A possible limitation.
            % For example, 
            %   Punc(1,3) = (1+Delta*obj.uBound.W)*SysN(1,3)
            % will not return an uncertain plant, but the nominal plant, so
            % it cannot model only a subpart of the plant with uncertainty.
            %
            
            NCON = length(obj.uOpts.iu);
            NMEAS = length(obj.uOpts.iy);
            Delta = ultidyn('D',[NCON,NMEAS],'SampleStateDimension',uOrd);
            
            SysN = obj.GF.getNominalPlantLinearization(obj.eqOpts);
            sysN = SysN.getss(obj.uOpts.iu,obj.uOpts.iy);
            
            if strcmp(obj.uOpts.uncType,'add')
                Punc = sysN + Delta*obj.uBound.W;
            elseif strcmp(obj.uOpts.uncType,'mul')
                Punc = (1+Delta*obj.uBound.W)*sysN;
            else
                error('Not implemented yet.');
            end
            
            obj.GLF = Punc;
            
        end
        
        function INFO = plantLimitationsAnalysisReport(obj,varargin)
            % TODO: with the information gathered here, take into
            % consideration the RC performances and check if the imposed
            % performances are too stringent.
            % TODO: these informations must be 
            
            if nargin > 1
                N = varargin{1};
            else
                N = 20;
            end
            
            pa = PlantAnalysis(obj);
            INFO = pa.generateReport(N);
            
        end
        
        function validateUncertaintyModelling(obj,N,ord,tfin)
            % TODO: show actual uncertainties sampled from nonlinear system
            % and how they compare with respect to the imposed margins
            
            % Figure 1 logic + plots
            Delta = ultidyn('D',[1,1],'SampleStateDimension',ord);

            SysN = obj.GF.getNominalPlantLinearization(obj.eqOpts);
            sysN = SysN.getss(obj.uOpts.iu,obj.uOpts.iy);
            
            if strcmp(obj.uOpts.uncType,'add')
                Punc = sysN + Delta*obj.uBound.W;
            elseif strcmp(obj.uOpts.uncType,'mul')
                Punc = (1+Delta*obj.uBound.W)*sysN;
            end
            
            process_samples = usample(Punc,N);
            
            figure
            bode(process_samples), hold on, 
            bode(sysN,'r-'), grid
            title('Frequency resp. unc. vs nominal')
            %
            [mag_n,~,~,~] = obj.GF.get_nominal_magnitude(obj.uOpts);
            
            % Figure 2 logic + plots
            w = obj.uBound.w;
            MB = obj.uBound.MB;
            %
            figure
            semilogx(w,db(MB),'-','linewidth',5); grid, hold on
            %
            [mag_opt,~] = bode(obj.uBound.W,w);
            mag_opt = mag_opt(:);
            semilogx(w,db(mag_opt),'-','linewidth',4)
            
            for k=1:N
                eq_opts = obj.GF.getEqOpts(false);
                [pk,~] = obj.GF.getRandomPlantLinearization(eq_opts);
                sys = pk.getss(obj.uOpts.iu,obj.uOpts.iy);
                
                [mag,~] = bode(sys,w);
                mag = mag(:);
                
                if strcmp(obj.uOpts.uncType,'add')
                    mag_unc = abs(mag-mag_n);
                elseif strcmp(obj.uOpts.uncType,'mul')
                    mag_unc = abs((mag-mag_n)./mag);
                else
                    error('Not implemented yet.');
                end

                semilogx(w,db(mag_unc),'Color', uint8([100 100 100]))
            end
           title(['"',obj.uOpts.uncType,'"',' type uncertainty bound'])
           legend('Experimental','Optimized','Monte Carlo')
            
            % Figure 3 logic + plots
            % % take N nonlinear plant models with uncertainty
            % take N linearized plant models with uncertainty Wopt and
            % compare for the equilibrium point
            % deduce bounds ymin,ymax
            iu = obj.uOpts.iu;
            iy = obj.uOpts.iy;
            
            figure
            ref_tol = 0.02; % x100%
            % time response for the nonlinear plant
            for k=1:N
                Sys = obj.GF.getRandomPlant();
                [x0,~,~,~] = Sys.findEqPoint(obj.eqOpts);

                u0 = obj.EqN.u0;
                % u0_step = obj.EqN.u0;
                % u0_step(iu) = u0_step(iu)*(1+ref_tol); % relative value
                % [x,t,y] = Sys.simInitCond(x0,u0_step,tfin);
                
                umask = zeros(Sys.m,1);
                umask(iu) = ref_tol;
                u_sig = @(t) u0 + (t>=tfin(end)/4).*umask;

                [x,t,y] = Sys.sim(x0,u_sig,tfin);
                
                uv = zeros(Sys.m,length(t));
                for j=1:length(t)
                    uv(:,j) = u_sig(t(j));
                end
                
                subplot(211);
                yyaxis left
                % plot(t,[u0(iu),u0_step(iu)*ones(1,length(y)-1)],'-','linewidth',2); hold on
                plot(t,uv(iu,:),'-','linewidth',2); hold on
                xlabel('Time [s]')
                ylabel('u(t)')

                yyaxis right
                plot(t,y(iy,:),'-'); hold on
                
                subplot(212)
                plot(t,x,'-','color',[0.8500, 0.3250, 0.0980]); hold on
            end
            
            sysLN = obj.GLN;
            eqn = obj.EqN;
            SysN = LTIEqSystem(sysLN.A,sysLN.B,sysLN.C,sysLN.D,...
                eqn.x0,eqn.u0,eqn.y0,eqn.t0);
            
            [xln,tln,yln] = SysN.sim(x0,u_sig,tfin);
            % [xln,tln,yln] = SysN.simInitCond(x0,u0_step,tfin);

            subplot(211);
            yyaxis right
            plot(tln,yln(iy,:),'k-','linewidth',1.5); grid minor;
            xlabel('Time [s]')
            ylabel('y(t)')
            title('Nonlinear vs. nominal operating point')
            
            subplot(212);
            plot(tln,xln,'k-','linewidth',1.5); grid minor;
            xlabel('Time [s]')
            ylabel('x(t)')
            title('Nonlinear vs. nominal operating point')
            
            hold off
            
        end
        
        function save_current_object(obj,varargin)
            global toolbox_path
            path = [toolbox_path,'data/'];
            if ~isempty(varargin)
                obj_name = varargin{1};
                save([path,obj_name],'obj');
                disp(['>> ',path,obj_name,' saved to disk.']);
            else
                file_name = [path,'clp-',obj.modelName,'-',datestr(datetime)];
                save(file_name,'obj');
                disp([file_name,'.mat saved to disk.']);
            end
        end
        
    end
    
    methods ( Static )
        function clp = load_object(varargin)
            global toolbox_path
            savePath = [toolbox_path,'data/'];
            if ~isempty(varargin)
                obj_name = varargin{1};
                x = load([savePath,obj_name]);
                clp = x.obj;
            else
                %TODO: load most recent object
                error('Not implemented yet.');
            end
        end
        
    end
    
end

