%% PARAMETRI
L = 0.34;             % Lunghezza guida [m]
a = 0.04775;          % Lato maggiore guida [m]
c = 299792458;        % Velocità della luce [m/s]

%% ESTRAZIONE DATI MISURATI
f = dataStruct.xaxis(:);

% Fase S21 (in radianti)
phase_rad = dataStruct.phase_rad(:);

%% CALCOLO BETA Z MISURATA
phase_unwrapped = unwrap(phase_rad);
beta_z_mis = -phase_unwrapped/L;

%% CALCOLO BETA Z TEORICA - MODO TE10
fc = c/(2*a);

beta_z_teo = nan(size(f));
idx = f > fc;

beta_z_teo(idx) = sqrt( ...
    (2*pi*f(idx)/c).^2 - (pi/a)^2 );

%% CREAZIONE DATASTRUCT PER IL PLOT
betaStruct = dataStruct;
betaStruct.xaxis = f;
betaStruct.formattedData = beta_z_mis;

%% GRAFICO CURVA MISURATA
[fig, ax, lineHandle] = plotDataStruct(betaStruct, ...
    Title = "Confronto beta_z misurata e teorica", ...
    FrequencyUnit = "GHz", ...
    YLabel = "$\beta_z\;[\mathrm{rad/m}]$", ...
    XLabel = "Frequenza [GHz]", ...
    Color = [1 0 0], ...
    LineWidth = 2);

%% CORREZIONE ETICHETTE ASSI CON LATEX
xlabel(ax, 'Frequenza [GHz]', ...
    'Interpreter', 'latex', ...
    'FontSize', 22);

ylabel(ax, '$\beta_z\;[\mathrm{rad/m}]$', ...
    'Interpreter', 'latex', ...
    'FontSize', 22);

%% SOVRAPPOSIZIONE CURVA TEORICA
hold(ax, 'on');

for k = 1:length(f)-1

    if isfinite(beta_z_teo(k)) && isfinite(beta_z_teo(k+1))

        line(ax, f(k:k+1)/1e9, beta_z_teo(k:k+1), ...
            'Color', [0 0.3 0.75], ...
            'LineWidth', 2);

    end
end

%% LEGENDA
h_mis = line(ax, NaN, NaN, ...
    'Color', [1 0 0], 'LineWidth', 2);

h_teo = line(ax, NaN, NaN, ...
    'Color', [0 0.3 0.75], 'LineWidth', 2);

legend(ax, [h_mis h_teo], ...
    {'$\beta_{z,\mathrm{misurata}}$', ...
    '$\beta_{z,\mathrm{teorica}}$'}, ...
    'Interpreter', 'latex', ...
    'FontSize', 16, ...
    'Location', 'best');

hold(ax, 'off');