function [fres,beta,q0,unc_fres,unc_beta,unc_q0]=S11fit_delta(freq11,xx11,yy11,startbeta,attenuation)
% Fitting of the reflection parameter for a single resonance.
% Fitting the data as a function of the normalised frequency shift delta
% (delta = freq/fres-fres/freq) to find beta, q0. The resonance frequency
% is determined by the minimum of the S11
% and its uncertainty is the frequency spacing/sqrt(12).
% Matlab curve fitting toolbox is needed.
%
% free parameters of the fit: beta, Q0
% fres      resonant frequency
% beta      coupling factor
% q0        unloaded quality factor
% unc_fres  uncertainty on the resonant frequency
% unc_beta  uncertainty on the coupling factor
% unc_q0    uncertainty on the unloaded quality factor
% Input parameters
% freq11    frequency (independent variable)
% xx11      real part of the S11 to be fitted
% yy11      imag part of the S11 to be fitted
% startbeta first guess of the copling factor <1 (>1) for under (over) coupling
% attenuation   constant attenuation of the feeding trasmission line
%               (fixed parameter in the fit)
% function [fres,beta,q0,unc_fres,unc_beta,unc_q0]=S11fit_delta(freq11,xx11,yy11,startbeta,attenuation)
% ver. 1.1 Andrea Mostacci 07/10/08 

% to allow column and raw vector as input 
[raw,col]=size(freq11);
if col>raw,
    freq11=freq11';
end

[raw,col]=size(xx11);
if col>raw,
    xx11=xx11';
end

[raw,col]=size(yy11);
if col>raw,
    yy11=yy11';
end

mod_S11=sqrt(xx11.^2+yy11.^2);
[val,ind1]=min(mod_S11);
f0_S11=freq11(ind1);
delta_S11=freq11./f0_S11-f0_S11./freq11;

% Fitting as function of the normalised frequency shift
myS11 = fittype('factor*sqrt((((beta-1)/(beta+1))^2+(x*q0/(1+beta))^2)/(1+(x*q0/(1+beta))^2))',...
    'independent',{'x'},'coefficients',{'beta','q0'},'problem',{'factor'});

% Fitting parameters for the Under/Over coupled cases
if startbeta <= 1,
    startbeta=(1-mod_S11(ind1))/(1+mod_S11(ind1));
    fitParam = fitoptions('method','NonlinearLeastSquares',...
    'Lower',[0 0],'Upper',[1 Inf],'Startpoint',[startbeta 10000]);
else
    startbeta=(1+mod_S11(ind1))/(1-mod_S11(ind1));
    fitParam = fitoptions('method','NonlinearLeastSquares',...
    'Lower',[1 0],'Upper',[Inf Inf],'Startpoint',[startbeta 10000]);
end

% Results of the first fit as a function of the normalised frequency
[fitS11,gofS11,outS11] = fit(delta_S11,mod_S11,myS11,...
     fitParam,'problem',{attenuation});

coeffS11=coeffvalues(fitS11);
deltaParameters=confint(fitS11,0.95);

beta=coeffS11(1);
q0=coeffS11(2);
fres=f0_S11;

[aux,Nparameters]=size(deltaParameters);
Ndegreees_of_freedom=length(freq11)-Nparameters;
t_value=tinv(0.95,Ndegreees_of_freedom);

unc_beta=(deltaParameters(2,1)-deltaParameters(1,1))./t_value;
unc_q0=(deltaParameters(2,2)-deltaParameters(1,2))./t_value;
unc_fres=abs(freq11(ind1)-freq11(ind1+1))./sqrt(12);


