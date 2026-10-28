%% Basic evaluation: fit of reflection coefficient of a resonace
% Read the measured parameters
freq=dataStruct.xaxis;
S11data=dataStruct.Real+1i*dataStruct.Imag;
S11real=real(S11data);
S11imag=imag(S11data);

S11mod=abs(S11data);
S11phase=angle(S11data);

% First guess for the fit
LossFirstGuest=0.8;
betaFirstGuessUnder=0.5;
betaFirstGuessOver=2;

%%% Data fitting

% Fit for UNDERcoupled case
[fresUnder,betaUnder,q0Under,lossUnder,unc_fresUnder,unc_betaUnder,unc_q0Under,unc_lossUnder]=...
    S11fit_delta_attenuation(freq,S11real,S11imag,betaFirstGuessUnder,LossFirstGuest);

% S11fit_modUnder   -> module of the fitted S11 in case of UNDER-coupling
% S11fit_phaseUnder -> phase of the fitted S11 in case of UNDER-coupling
[S11fit_modUnder,S11fit_phaseUnder]=s11resonance2(freq,fresUnder,betaUnder,q0Under);


% Fit for OVERcoupled case
[fresOver,betaOver,q0Over,lossOver,unc_fresOver,unc_betaOver,unc_q0Over,unc_lossOver]=...
    S11fit_delta_attenuation(freq,S11real,S11imag,betaFirstGuessOver,LossFirstGuest);

% S11fit_modOver   -> module of the fitted S11 in case of OVER-coupling
% S11fit_phaseOver -> phase of the fitted S11 in case of OVER-coupling
[S11fit_modOver,S11fit_phaseOver]=s11resonance2(freq,fresOver,betaOver,q0Over);

%%% End of data fitting


%%% Data Plot
fig=figure; %Open the figure

% Set the plot format configuration
set(gca,'FontSize',22,'LineWidth',2); % Set the text size and the box line width 
grid(gca,'on'); % Set the grid on the plot
box(gca,'on');  % Set the outer box
hold(gca,'on'); % Hold the following plot on the same figure

% Perform the plot
plot(freq,20*log10(S11mod),'r','Linewidth',2);
plot(freq,20*log10(lossUnder*S11fit_modUnder),'k--','Linewidth',2);
plot(freq,20*log10(lossOver*S11fit_modOver),'g--','Linewidth',2);
 
 % Axis labelling
xlabel(dataStruct.xlabel)
ylabel('|S_{11}| (dB)')
string1=['Q_0=',num2str(q0Under,'%10.0f'), ' \beta=', num2str(betaUnder,'%3.3f'),...
    ' \alpha=', num2str(lossUnder,'%3.2f')];
string2=['Q_0=',num2str(q0Over,'%10.0f'), ' \beta=', num2str(betaOver,'%3.1f'),...
    ' \alpha=', num2str(lossOver,'%3.2f')];
 
legend('data',string1,string2,'Location','Best');
resonantFrequency=(fresOver+fresUnder)./2*1e-6;
text(0.32,1.05, ['f_0=',num2str(resonantFrequency,'%10.6f'),'MHz'],...
    'FontSize',20, 'Units', 'normalized')

%%% End of data plot

%% End of FitResoanceData