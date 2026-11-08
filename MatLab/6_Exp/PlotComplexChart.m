
%% Basic evaluation: plot the with Polar plot
% chosing among Impedance Smith Chart, Admittance Smith Chart
% or polar plot depending on the data file 
% SmithPlot command is used
% April 2026

% Information about the release
info=ver('MATLAB');

fig=figure;

if isfield(dataStruct,'formattedReal')
    RealPart=dataStruct.formattedReal;
    ImagPart=dataStruct.formattedImag;
else
    RealPart=dataStruct.Real;
    ImagPart=dataStruct.Imag;
end

if exist('smithplot','file')>0
    if contains(dataStruct.ylabel, 'SAD')
        disp([info.Release ': Using smithplot']);
        SmithPlotObj = smithplot(RealPart+1i*ImagPart,'r-','GridType','Y','LineWidth',5);
        SmithPlotObj.GridLineWidth = 3.5;
        SmithPlotObj.FontSize = 26;
    elseif contains(dataStruct.ylabel, 'POL') 
        polarplot(RealPart+1i*ImagPart,'r-','LineWidth',5); %formattedPhase
        PolarPlotObj=gca;
        PolarPlotObj.FontSize=20;
        PolarPlotObj.LineWidth=4;
        PolarPlotObj.GridAlpha=0.3;
    elseif contains(dataStruct.ylabel, 'COM')
        fig=figure; 
        % Set the plot format configuration
        set(gca,'FontSize',22,'LineWidth',2); % Set the text size and the box line width 
        grid(gca,'on'); % Set the grid on the plot
        box(gca,'on');  % Set the outer box
        hold(gca,'on'); % Hold the following plot on the same figure
        axis(gca,'square')
        plot(RealPart,ImagPart,'r','Linewidth',2);
    else
        disp([info.Release ': Using smithplot']);
        SmithPlotObj = smithplot(RealPart+1i*ImagPart,'r-','GridType','Z','LineWidth',5);
        SmithPlotObj.GridLineWidth = 3.5;
        SmithPlotObj.FontSize = 26;
    end
    
else
    disp([info.Release ': Using smithchart']);
    [lineseries,hsm] = smithchart(RealPart+1i*ImagPart); % compatibility with old versions
    set(lineseries,'LineWidth',3);
    set(hsm,'LineWidth',3,'LabelSize',18,'Color',[0 0 0]);
end

clear('info','RealPart','ImagPart');

% To compare on the same plot with other data or theory stored in the
% complex variable AdditionalData
% hold on;
% plot(real(AdditionalData),imag(AdditionalData),'b','Linewidth',5);
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