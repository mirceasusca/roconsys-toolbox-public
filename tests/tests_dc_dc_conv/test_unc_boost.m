%%
% TODO: facut o clasa care inglobeaza toata problema de bucla inchisa
% - se prezinta specificatiile => se creeaza obiectele (struct) de tip options
% 
% 
% Verificari la fiecare pas -- optimizarea lui Wopt
% Optimizarea pentru miu synthesis -- fiecare performanta impusa sa fie
% testata pentru procesele liniarizate considerate, respectiv cele
% neliniare initiale etc.
% verificarea pentru cuantizare
% MiL for closed-loop system

% save to disk all settings/results/software version

%%
close all
clc
clearvars
factory = UncertainBoostConverterFactory();
eqOpts = factory.getEqOpts(true);

uncOpts = set_unc_bound_det_options('iu',3,'numExp',500,...
    'wmin',1e1,'wmax',1e7,'npoints',200,'uncType','mul');

uncBound = factory.getUncertaintyModelBoundary(uncOpts);
MB = uncBound.MB;
w = uncBound.w;
semilogx(w,db(MB)); shg

%%
tfSpecs = set_tf_specs_options('n_real_poles',1,'n_real_zeros',1);
optProb = UncertaintyOptProblem(tfSpecs, uncBound);

% x0 = [0.1750,1/195.9,1/1.2e5,1/912.6,1/1e5];  % k, 2z real, 2p real
% x0 = [0.1750,1/195.9,1/1.2e5,1/195.9,1/1.2e5,1/912.6,1/1e5,1/912.6,1/1e5];
% x0 = [1,1/1e5,1/1.1e5]; % TODO: implementez mecanism in care impun doar cate-o variabile etc, restul cu random mai departe: gen sa fie un zero cu constanta de timp T1 etc.
% x0 = [0.18,1e2,0.5,1e4,0.5];
% x0 = [15,1/1e5,1/1e4];
% [W,INFO] = optProb.optimize(x0);
% x0mat = build_initial_tf_guess(tfSpecs,...) # build matrix of x0 points
% with certain specifications (K=0.15, wnpole = 1e5 etc., NOT ENTIRE
% points)
W = optProb.optimize();

%%
MB = uncBound.MB;
w = uncBound.w;

figure
semilogx(w,db(MB),'b','linewidth',2), hold on
%
[magW,~] = bode(W,w);
magW = magW(:);
semilogx(w,db(magW))
legend('Wcacsd','Wopt'), shg

%%
figure
hinfnorm(W)

Delta = ultidyn('D',[1,1],'SampleStateDimension',3)
rng(0)  % for reproducibility


SysN = factory.getNominalPlantLinearization(eqOpts);
sysN = SysN.getss(3,1);
%
if strcmp(uncOpts.uncType,'add')
    Punc = sysN + Delta*W;
elseif strcmp(uncOpts.uncType,'mul')
    Punc = (1+Delta*W)*sysN;
end

bode(Punc)

delS = usample(Delta,100);
% bode(delS)
% 
% P = (1+delS*W)*sysN;
% % figure
% % bode(P), hold on
% % bode(sysN,'*-')
% 
%
% figure
% semilogx(w,db(magW),'b','linewidth',2), hold on
% semilogx(w,db(MB),'b--','linewidth',2)
% 
% bode((P-sysN)/sysN,w)

%%
% % figure
% % G0 = feedback(Punc,1);
% % step(Punc)
% % G = aug
% roConSpecs.WS = makeweight(100,[3e3,sqrt(2)/2],0.3);
% roConSpecs.WT = makeweight(0.3,[2.8e3,sqrt(2)/2],20);
% roConSpecs.WKS = [];
% % bode(roConSpecs.WS,roConSpecs.WT);
% % legend('WS','WT')
% % G = augw(Punc,WS,[],[]);
% % [K,CLPERF,INFO] = musyn(G,1,1);
% rcp = RobustControlOptProblem(Punc);
% [K,CLPERF,INFO] = rcp.optimizeController(roConSpecs);

%%
% figure
% G0 = feedback(Punc,1);
% step(Punc)
% G = aug


%%
roConSpecs.WS = makeweight(100,[3e3,sqrt(2)/2],0.3);
roConSpecs.WT = makeweight(0.3,[2.8e3,sqrt(2)/2],20);
roConSpecs.WKS = [];
% bode(roConSpecs.WS,roConSpecs.WT);
% legend('WS','WT')
% G = augw(Punc,WS,[],[]);
% [K,CLPERF,INFO] = musyn(G,1,1);
rcp = RobustControlOptProblem(Punc);
[K,CLPERF,INFO] = rcp.optimizeController(roConSpecs);

%%
figure
G0 = feedback(K*Punc,1);
% bode(K*Punc), shg
step(G0)
% bode(G0)