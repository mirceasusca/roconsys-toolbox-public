% TODO: sculpteaza diagrama Bode/Nyquist ca sa arati ce nu ai voie sa
% depasesti pentru faza de proiectare

% TODO: integrate this file's logic into UncertainPlantFactory
% automatically deduce LCF epsilon and a generalized plant with ULFT
% connection

clearvars
clc

boost_factory = UncertainBoostConverterFactory();
boost_nominal = boost_factory.getNominalPlant();

%%
eqOpts = set_eq_point_options(...
    'xunkguess',[3;24],...
    'ueq',[12;15;0.5179],'ueqidx',[1;2;3]);

[x0n,u0n,y0n,t0n] = boost_nominal.findEqPoint(eqOpts);
[An,Bn,Cn,Dn] = boost_nominal.linearize(x0n,u0n,t0n);
[factn,Mtn,Ntn] = lncf(ss(An,Bn(:,3),Cn,0));

%%
wv = logspace(2,7,100);

clf
[magn,phn]=bode(ss(An,Bn(:,3),Cn,Dn(:,3)),wv);
magn = magn(:);
phn = phn(:);
subplot(211),semilogx(wv,db(magn),'-*','linewidth',1.5),hold on
subplot(212),semilogx(wv,phn,'-*','linewidth',1.5),hold on

%%
Nr = 100;

eps_vm = zeros(1,Nr);
eps_vn = zeros(1,Nr);

for k=1:Nr
    if mod(k,100) == 0
        disp(k);
    end
    
    eqOpts = set_eq_point_options(...
    'xunkguess',[3;24],...
    'ueq',[12+2*(rand(1)-0.5)*2;15+2*(rand(1)-0.5)*5;0.5179+2*(rand(1)-0.5)*0.05],'ueqidx',[1;2;3]);
    
    boost_rand = boost_factory.getRandomPlant();
    [x0r,u0r,y0r,t0r] = boost_rand.findEqPoint(eqOpts);
    [Ar,Br,Cr,Dr] = boost_rand.linearize(x0r,u0r,t0r);
    [fact,Mtr,Ntr] = lncf(ss(Ar,Br(:,3),Cr,0));
    
    Delta_M = Mtn - Mtr;
    eps_vm(k) = hinfnorm(Delta_M);
    
    Delta_N = Ntn - Ntr;
    eps_vn(k) = hinfnorm(Delta_N);
    
    [magr,phr]=bode(ss(Ar,Br(:,3),Cr,Dr(:,3)),wv);
    %
    magr = magr(:);
    phr = phr(:);
    subplot(211),semilogx(wv,db(magr))
    subplot(212),semilogx(wv,phr)
end
hold off
shg

figure
subplot(211), plot(sort(eps_vm))
subplot(212), plot(sort(eps_vn))