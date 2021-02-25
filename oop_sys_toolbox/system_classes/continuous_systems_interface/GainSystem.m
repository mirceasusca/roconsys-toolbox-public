classdef GainSystem < LTISystem
    %LTISYSTEM Summary of this class goes here
    %   Detailed explanation goes here

    methods
        function obj = GainSystem(D,varargin)
            %LTISYSTEM Construct an instance of this class
            %   Detailed explanation goes here
            
            obj@LTISystem([],[],[],D,varargin);
            obj.sysList = {};
            
            obj.m = size(D,2);
            obj.n = 0;
            obj.p = size(D,1);
          
        end
        
        function dx = F(obj,x,u,t)
            dx = [];
        end
        
        function y = h(obj,x,u,t)
            y = obj.D*u;
        end

    end
end

