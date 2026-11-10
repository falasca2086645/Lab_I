function [fres,beta,q0,loss,unc_fres,unc_beta,unc_q0,unc_loss]=S11fit_delta_attenuation_modulus(freq11,mod_S11,startbeta,attenuation)
% Fitting of the reflection parameter for a single resonance.
% Fitting the data as a function of the normalised frequency shift delta
% (delta = freq/fres-fres/freq) to find beta, q0, attenuation. The resonance frequency
% is determined by the minimum of the S11
% and its uncertainty is the frequency spacing/sqrt(12).
% Matlab curve fitting toolbox is needed.
%
% free parameters of the fit: beta, Q0, attenuation
% fres      resonant frequency
% beta      coupling factor
% q0        unloaded quality factor
% loss      constant attenuation of the feeding trasmission line
% unc_fres  uncertainty on the resonant frequency
% unc_beta  uncertainty on the coupling factor
% unc_q0    uncertainty on the unloaded quality factor
% unc_loss  uncertainty on constant attenuation of the feeding trasmission line
% Input parameters
% freq11    frequency (independent variable)
% mod_S11 modulous of the S11 to be fitted
% startbeta first guess of the copling factor <1 (>1) for under (over) coupling
%
% function [fres,beta,q0,loss,unc_fres,unc_beta,unc_q0,unc_loss]=S11fit_delta_attenuation_modulus(freq11,mod_S11,startbeta,attenuation)
% ver. 1.1 Andrea Mostacci 19/01/11 

% to allow column and raw vector as input 
[raw,col]=size(freq11);
if col>raw,
    freq11=freq11';
end

[raw,col]=size(mod_S11);
if col>raw,
    mod_S11=mod_S11';
end

[val,ind1]=min(mod_S11);
f0_S11=freq11(ind1);
delta_S11=freq11./f0_S11-f0_S11./freq11;

% Fitting as function of the normalised frequency shift
myS11 = fittype('factor*sqrt((((beta-1)/(beta+1))^2+(x*q0/(1+beta))^2)/(1+(x*q0/(1+beta))^2))',...
    'independent',{'x'},'coefficients',{'beta','q0','factor'});

% Fitting parameters for the Under/Over coupled cases
if startbeta <= 1,
    startbeta=(1-mod_S11(ind1))/(1+mod_S11(ind1));
    fitParam = fitoptions('method','NonlinearLeastSquares',...
    'Lower',[0 0 0],'Upper',[1 Inf 1],'Startpoint',[startbeta 10000 attenuation]);
else
    startbeta=(1+mod_S11(ind1))/(1-mod_S11(ind1));
    fitParam = fitoptions('method','NonlinearLeastSquares',...
    'Lower',[1 0 0],'Upper',[Inf Inf 1],'Startpoint',[startbeta 10000 attenuation]);
end

% Results of the first fit as a function of the normalised frequency
[fitS11,gofS11,outS11] = fit(delta_S11,mod_S11,myS11,fitParam);

coeffS11=coeffvalues(fitS11);
deltaParameters=confint(fitS11,0.95);

beta=coeffS11(1);
q0=coeffS11(2);
loss=coeffS11(3);
fres=f0_S11;

[aux,Nparameters]=size(deltaParameters);
Ndegreees_of_freedom=length(freq11)-Nparameters;
t_value=tinv(0.95,Ndegreees_of_freedom);

unc_beta=(deltaParameters(2,1)-deltaParameters(1,1))./t_value;
unc_q0=(deltaParameters(2,2)-deltaParameters(1,2))./t_value;
unc_loss=(deltaParameters(2,3)-deltaParameters(1,3))./t_value;
unc_fres=abs(freq11(ind1)-freq11(ind1+1))./sqrt(12);


