classdef PlantAnalysis
    %PLANTANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        clp  % closed-loop problem
    end
    
    methods
        function obj = PlantAnalysis(clp)
            %PLANTANALYSIS Construct an instance of this class
            %   Detailed explanation goes here
            obj.clp = clp;
        end
        
        function INFO = generateReport(obj,N)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            iu = obj.clp.uOpts.iu;
            iy = obj.clp.uOpts.iy;
            %
            INFO.IU = iu;
            INFO.IY = iy;
            INFO.EqN = obj.clp.EqN;
            INFO.GLN = obj.clp.GLN;
            INFO.E = eig(obj.clp.GLN);
            INFO.P = pole(obj.clp.GLN);
            INFO.Z = zero(obj.clp.GLN(iy,iu));  % for command signals
            INFO.TZ = tzero(obj.clp.GLN(iy,iu));  % for command signals
            
            obj.pzplot(N);
          
        end
        
        function pzplot(obj,N)
            iu = obj.clp.uOpts.iu;
            iy = obj.clp.uOpts.iy;
              
            figure, hold on
            
            for k=1:N
                eqOpts = obj.clp.eqOpts;
                GR = obj.clp.GF.getRandomPlant();
                [x0,u0,y0,t0] = GR.findEqPoint(eqOpts);
                [A,B,C,D,~,~,~,~] = GR.linearize(x0,u0,t0);
                sys = ss(A,B,C,D);
                sys = sys(iy,iu);
                pzmap(sys,'b');
            end
            % sgrid;
            
            P = obj.clp.GLN(iy,iu);
            p = pole(P);
            z = zero(P);
            plot(real(p),imag(p),'xr','markersize',12,'linewidth',1.5);
            plot(real(z),imag(z),'or','markersize',10,'linewidth',1.5);
            title('PZ Map uncertain vs nominal')
            
        end
        
    end
end

