clear; clc; close all;

% Parametri dell'onda quadra
A = 0.5;             % Tensione di picco [V]
f0 = 1e6;            % Frequenza fondamentale [Hz]
fs = 100e6;          % Frequenza di campionamento [Hz]
Tobs = 100e-6;       % Tempo di osservazione [s]
R = 50;              % Resistenza [Ohm]

% Asse temporale
N = round(fs*Tobs);
n = 0:N-1;
t = n/fs;

% Onda quadra bipolare: da -0.5 V a +0.5 V
x = A * (2*(mod(n,fs/f0) < fs/(2*f0))-1);

% Calcolo FFT
X = fft(x)/N;

% Spettro monolatero
X_amp = abs(X(1:N/2+1));
X_amp(2:end-1) = 2*X_amp(2:end-1);

% Asse delle frequenze
f = (0:N/2)*(fs/N);

% Conversione da tensione a potenza in dBm
Vrms = X_amp/sqrt(2);
Vrms(1) = X_amp(1);
Vrms(end) = X_amp(end);

P = Vrms.^2/R;
P_dBm = 10*log10(P/1e-3);

% Limite inferiore per la visualizzazione
P_dBm = max(P_dBm, -80);

% Grafico dell'onda quadra nel tempo
figure;
plot(t*1e6, x);
xlabel('Tempo [us]');
ylabel('Tensione [V]');
title('Onda quadra');
xlim([0 5]);
grid on;

% Grafico FFT
figure;
plot(f/1e6, P_dBm, 'b');
xlabel('Frequenza [MHz]');
ylabel('Potenza [dBm]');
title('FFT onda quadra');
xlim([0 8.6]);
ylim([-80 10]);
grid on;