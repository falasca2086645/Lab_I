%% Basic evaluation: plot formatted data
% Select the quantities to be plot
xaxis=dataStruct.xaxis;
formattedData=dataStruct.formattedData;

if abs(xaxis(1)-xaxis(end))<1e-10, % if it is a Zero Span mode
     prompt = 'What is the sweep Time in ms? ';
     xmax=input(prompt);
     xaxis=0:xmax/(length(formattedData)-1):xmax;
     dataStruct.xlabel='Time (ms)';
end

fig=figure; %Open the figure

% Set the plot format configuration
set(gca,'FontSize',22,'LineWidth',2); % Set the text size and the box line width 
grid(gca,'on'); % Set the grid on the plot
box(gca,'on');  % Set the outer box
hold(gca,'on'); % Hold the following plot on the same figure

% Perform the plot
plot(xaxis,formattedData,'r','Linewidth',2);
 
 % Axis labelling
xlabel(dataStruct.xlabel)
if isfield(dataStruct,'ylabel') % Check if there is the y label on the struct
    if exist('contains','file')
        if contains(dataStruct.ylabel,'MLO')
             ylabel(strrep(dataStruct.ylabel, ': MLO', ' (dB)'))
        elseif contains(dataStruct.ylabel,'MLI')
             ylabel(strrep(dataStruct.ylabel, ': MLI', ' (arb. units)'))
        end
    else
        ylabel(dataStruct.ylabel);
    end
 end

clear('xaxis','formattedData')
%% End of plot formatted data