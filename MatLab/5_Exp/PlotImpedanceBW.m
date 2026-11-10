%% Impedenza da S11 (short position) e misura della banda a -3 dB -> Q0
% Uso:  load('3_1_Smith_Chart_in_short_position.mat');  PlotImpedanceBW
% Richiede dataStruct nel workspace (come PlotComplexChart / PlotFormattedData).
% Se il file non contiene formattedReal/Imag, l'offset di fase viene
% applicato qui (stesso valore impostato sul VNA).

phaseOffsetDeg = -72.4;   % offset per la short position (usato solo se serve)

f = double(dataStruct.xaxis(:));
if isfield(dataStruct,'formattedReal')
    G = dataStruct.formattedReal(:) + 1i*dataStruct.formattedImag(:);  % offset gia' applicato dal VNA
else
    G = (dataStruct.Real(:) + 1i*dataStruct.Imag(:)) .* exp(1i*deg2rad(phaseOffsetDeg));
end

z   = (1 + G)./(1 - G);          % impedenza normalizzata a Z0 = 50 ohm
zdB = 20*log10(abs(z));

% Picco e punti a -3 dB (interpolazione lineare tra i campioni)
[zmax, k] = max(zdB);
f0  = f(k);
thr = zmax - 3;
iL = find(zdB(1:k) < thr, 1, 'last');
iR = k - 1 + find(zdB(k:end) < thr, 1, 'first');
fL = interp1(zdB(iL:iL+1), f(iL:iL+1), thr);
fR = interp1(zdB(iR-1:iR), f(iR-1:iR), thr);
BW = fR - fL;
Q0 = f0/BW;

fprintf('f0 = %.6f GHz   |z|max = %.3f (= beta)\n', f0/1e9, abs(z(k)));
fprintf('fL = %.6f GHz   fR = %.6f GHz\n', fL/1e9, fR/1e9);
fprintf('BW = %.2f kHz   Q0 = f0/BW = %.0f\n', BW/1e3, Q0);

% Grafico (stesso stile degli altri script)
fig = figure;
set(gca,'FontSize',22,'LineWidth',2); grid(gca,'on'); box(gca,'on'); hold(gca,'on');
plot(f/1e9, zdB, 'r', 'LineWidth', 2);
yline(thr, 'b--', '-3 dB', 'LineWidth', 1.5, 'FontSize', 16);
xline(fL/1e9, 'k--', 'LineWidth', 1.5);
xline(fR/1e9, 'k--', 'LineWidth', 1.5);
plot(f0/1e9, zmax, 'ko', 'MarkerFaceColor', 'k');
xlabel('frequency (GHz)');
ylabel('|Z/Z_0| (dB)');
title(sprintf('BW = %.1f kHz,   Q_0 = %.0f', BW/1e3, Q0), 'FontWeight', 'normal');

clear('G','z','k','iL','iR','thr')
