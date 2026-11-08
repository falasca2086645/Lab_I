
%% Basic evaluation: plot the Smith Chart - using SmithPlot command
%% April 2026

% Information about the release
info=ver('MATLAB');

fig=figure;

% If using S2p file
% RealPart=real(Sparameters.S11);
% ImagPart=imag(Sparameters.S11);

% If using S1p file
% RealPart=real(Sparameters.data);
% ImagPart=imag(Sparameters.data);

% If using a csv file
RealPart=dataStruct.Real;
ImagPart=dataStruct.Imag;


if exist('smithplot','file')>0
    disp([info.Release ': Using smithplot']);
    SmithPlotObj = smithplot(RealPart+1i*ImagPart,'r-','GridType',"Z",'LineWidth',5);
    SmithPlotObj.GridLineWidth = 3.5;
    SmithPlotObj.FontSize = 26;
else
    disp([info.Release ': Using smithchart']);
    [lineseries,hsm] = smithchart(RealPart+1i*ImagPart);
    set(lineseries,'LineWidth',3);
    set(hsm,'LineWidth',3,'LabelSize',18,'Color',[0 0 0]);
end

clear('info');

% RR=61.39;%Ohm
% LL=8.8845e-8/(2*pi); %H
% LL=22.5*1e-9; %H
% ResFreq=792.14*1e6; %Hz
% CC=1./((2*pi*ResFreq)^2*LL); %F
% 
% freq=xaxis;
% omega=2*pi*freq;
% 
% Z11=RR+1i*omega*LL;
% Z22=1./(1i*omega*CC);
% 
% ZZ=(Z11.*Z22)./(Z11+Z22);
% AdditionalData=(ZZ-50)./(ZZ+50);
% % To compare on the same plot with other data or theory stored in the
% % complex variable AdditionalData
% hold on;
%  plot(real(AdditionalData),imag(AdditionalData),'r--','Linewidth',3);
% hold off

% If you are saving data from Smith Chart format in the Network Analyser,
% you have also the field in the struct
% dataStruct.formattedReal
% dataStruct.formattedImag
% containing the user setting on the Electrical Delay and Phase Offset.
% To plot them use
% hold on;
% plot(dataStruct.formattedReal,dataStruct.formattedImag,'r--','Linewidth',3);
% hold off
%% End of plot the Smith Chart