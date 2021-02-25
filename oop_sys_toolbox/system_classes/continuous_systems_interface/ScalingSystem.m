classdef ScalingSystem < System
    %LTISYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    %
    % y = FAC*u + OFFS
    %
    % FAC: quare matrix
    % OFFS: column vector
    %
    

    properties
        params
        sysList
        m
        n
        p
        
        FAC
        OFFS
        
    end
    
    methods
        function obj = ScalingSystem(FAC,OFFS,varargin)
            %LTISYSTEM Construct an instance of this class
            %   Detailed explanation goes here
            
            obj@System(varargin);
            
            assert(size(FAC,1) == size(FAC,2));
            assert(size(OFFS,1) == size(FAC,1));
            assert(size(OFFS,2) == 1);
            
            obj.FAC = FAC;
            obj.OFFS = OFFS;
            
            obj.m = size(FAC,1);
            obj.p = size(FAC,1);
            obj.n = 0;
         
        end
        
        function dx = F(obj,x,u,t)
            dx = [];
        end
        
        function y = h(obj,x,u,t)
            y = obj.FAC*u+obj.OFFS;
        end

    end
end

