

%% Basic evaluation: plot formatted data of the imaginary part of the admittance
% and make a basic fitting

% Measured data in the MeasuredData struct
MeasuredData=dataStruct;

xaxis=MeasuredData.xaxis;
formattedData=MeasuredData.formattedData;

% Data to be fitted are 
xaxisFit=sqrt(xaxis); % Needed for cable measurent
%xaxisFit=xaxis; % for lumped elements
DataFit=formattedData;

% Step one: perform the fit
% Choose the number of points to fit (depending on the experiment). Typical
% acquisition is of 1600 points
NN=100; % Number of points to be fit

% Example: to fit the first NN data
NNstart=1;
NNend=NNstart+NN-1;
[p,unc_p,q,unc_q,rfactor]=regression3(xaxisFit(NNstart:NNend),DataFit(NNstart:NNend));

% Compute the linear fit model expectation
LinearFitValue=p.*xaxisFit+q;


% Step two: plot the data measured

fig=figure; %Open the figure

% Set the plot format configuration
set(gca,'FontSize',22,'LineWidth',2); % Set the text size and the box line width 
grid(gca,'on'); % Set the grid on the plot
box(gca,'on');  % Set the outer box
hold(gca,'all'); % Hold the following plot on the same figure

plot(xaxis,formattedData,'r','Linewidth',2)

% Axis labelling
xlabel(MeasuredData.xlabel)
if isfield(MeasuredData,'ylabel')
    ylabel(MeasuredData.ylabel);
end

% Step three: superimpose the fit to the measured data
figure(fig)
plot(xaxis,LinearFitValue,'b--','Linewidth',2);
%plot(xaxis, 20*log10(exp(1))*sqrt(2*pi)*p.*sqrt(xaxis),'m--','Linewidth',2);

% Put a legend if needed
legend('data','fit','Location','Best')
%% End of plot formatted data
