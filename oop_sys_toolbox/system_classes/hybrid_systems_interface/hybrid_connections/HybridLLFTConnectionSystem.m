classdef HybridLLFTConnectionSystem < HybridSystem & LLFTConnectionSystem
    %HybridLLFTConnectionSystem Summary of this class goes here
    %   Detailed explanation goes here

    methods
        function obj = HybridLLFTConnectionSystem(sys1,sys2,nmeas,ncon,varargin)
            obj@HybridSystem(varargin);
            obj@LLFTConnectionSystem(sys1,sys2,nmeas,ncon,varargin);
            
            sys1 = HybridSystem.wrap_to_hybrid_system(sys1);
            sys2 = HybridSystem.wrap_to_hybrid_system(sys2);
            
            obj.sysList = {sys1,sys2};
            obj.sys1 = sys1;
            obj.sys2 = sys2;
            
        end
        
        function dx = F(obj,x,u,t)
            dx = obj.F@LLFTConnectionSystem(x,u,t);
        end
        
        function y = h(obj,x,u,t)
            y = obj.h@LLFTConnectionSystem(x,u,t);
            
        end
        
        function xplus = G(obj,x,u,t)
            [u1,u2,x1,x2] = obj.get_extended_inputs(x,u,t);
            
            xplus1 = x1;
            xplus2 = x2;
            
            if obj.sys1.jumpLogic(x1,u1,t)
                xplus1 = obj.sys1.G(x1,u(1:obj.m1)+u1,t);
            end
            
            if obj.sys2.jumpLogic(x2,u2,t)
                xplus2 = obj.sys2.G(x2,u(obj.m1+1:obj.m)+u2,t);
            end
            
            xplus = [xplus1;xplus2];
        end
        
        function inside = C(obj,x,u,t)
            [u1,u2,x1,x2] = obj.get_extended_inputs(x,u,t);
            
            inside = obj.sys1.C(x1,u(1:obj.m1)+u1,t) &&...
                obj.sys2.C(x2,u(obj.m1+1:obj.m)+u2,t);
            
        end
        
        function inside = D(obj,x,u,t)
            [u1,u2,x1,x2] = obj.get_extended_inputs(x,u,t);

            inside = obj.sys1.D(x1,u(1:obj.m1)+u1,t) ||...
                obj.sys2.D(x2,u(obj.m1+1:obj.m)+u2,t);

        end
        
    end
    
end
