%% PARAMETRI
L = 0.34;    % Lunghezza della guida [m]

%% ESTRAZIONE DATI
f = dataStruct.xaxis(:);

% Fase S21 in radianti
phase = dataStruct.phase_rad(:);

%% CALCOLO BETA Z MISURATA
phase_unwrapped = unwrap(phase);

beta_z_mis = -phase_unwrapped/L;

%% CREAZIONE DATASTRUCT PER IL PLOT
betaStruct = dataStruct;

betaStruct.xaxis = f;
betaStruct.formattedData = beta_z_mis;

betaStruct.xlabel = 'frequency (GHz)';
betaStruct.ylabel = '\beta_z (rad/m)';

%% GRAFICO
[fig, ax, lineHandle] = plotDataStruct(betaStruct, ...
    Title = "Beta_z misurata", ...
    FrequencyUnit = "GHz", ...
    YLabel = "$\beta_z$ [rad/m]", ...
    XLabel = "Frequenza [GHz]", ...
    Color = [1 0 0], ...
    LineWidth = 2);

% Interprete LaTeX per le etichette
ax.XLabel.Interpreter = 'latex';
ax.YLabel.Interpreter = 'latex';