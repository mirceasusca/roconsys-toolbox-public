classdef (Abstract) UncertainHybridPlantFactory < handle
    %UNCERTAINHYBRIDPLANTFACTORY Must wrap over an UncertainPlantFactory
    %object, inherit its Monte Carlo sample generation interface and return
    %hybrid models with the same tolerance set specification, but with
    %adapted behaviour.
    %
    % The initial conditions of the hybrid system are structured as:
    % [x0_p,x0_hl]
    % x0_p: the initial conditions of the plant (will be covered by EqOpts)
    % x0_hl: the initial conditions of the hybrid system logic
    %
    % Designed only for Model-in-the-Loop simulation.
    %
    
    properties (Abstract)
        params
        x0_hl
        
    end
    
    methods
        function obj = UncertainHybridPlantFactory(varargin)
            %UNCERTAINPLANTFACTORY
            obj.params = struct();
        end
    end
    
    
    methods (Static)
        function r = RNGB(nominal)
            % rng generator with bipolar effect: r in [-1,1];
            if nominal == true
                r = 0;
            else
                r = 2*(rand(1)-0.5);
            end
        end
        
        function r = RNGU(nominal)
            % rng generator with unipolar effect: r in [0,1];
            if nominal == true
                r = 0;
            else
                r = rand(1);
            end
        end
        
    end
    
    
    methods (Abstract)
        % returns a System instance with random parameters from the uncertainty set
        Sys = getRandomPlant(obj);
        
    end
    
    methods (Abstract, Static)
        % get set of tolerances for uncertain parameters in the plant
        % family
        tolSet = getTolSet(varargin);
        
    end
    
    methods
        function Sys = getNominalPlant(obj)
            nominal = true;
            Sys = obj.getRandomPlant(nominal);
        end
        
    end   
   
end