% Testing fourier Trasform. 
% Comment the signal that you do not want to see.

close all
clear all

% Set the time from 0 to 1ms
tmin=0;         % s
time_step=1e-6; % s
time_step=1e-9; 
tmax=1e-3;      % s
t=tmin:time_step:tmax;

N=length(t);
amp=2;  % Amplitude of the signal

% Frequency
fcarrier=50e6; %Hz
%f1=50e3; % Hz
f1=40e6; % Hz
f2=50e6; % Hz

% Sum of two signal
%signal=amp.*sin(2*pi*f1.*t);
signal=amp.*sin(2*pi*f1.*t)+2.*amp.*sin(2*pi*f2.*t);
%%% Show the time domain over NN periods
%figure;
%NN=10;
%tstop=tmin+NN/min(f1,f2);
%plot(t(t<tstop),signal(t<tstop))

%%%%%%%%%%%%
% Sawtooth wave
% Signal has a DC component (use mean(signal))
signal=amp.*sawtooth(2*pi*f1*t);
signal=signal-mean(signal);
% signal=amp.*sawtooth(2*pi*f1*t)+amp.*sin(2*pi*f2.*t);

% Symmetric Saw tooth wave (triangle)
% signal=amp.*sawtooth(2*pi.*f1.*t,0.5);
% signal=signal-mean(signal);

% Square Wave
% signal=amp.*square(2.*pi.*f1.*t);
% signal=signal-mean(signal);

% Amplitude modulation
%fbase=1e4;
%signal=amp.*square(2.*pi.*fbase.*t).*sin(2*pi*f1*t);
%signal=amp.*sawtooth(2.*pi.*fbase.*t).*sin(2*pi*f1*t);


%figure;
%plot(t,signal);
figure;
NN=10;
tstop=tmin+NN/min(f1,f2);
plot(t(t<tstop),signal(t<tstop))

fourier=fftshift(fft(signal))./N;

xx=real(fourier);
yy=imag(fourier);
mod=abs(fourier);
phase=angle(fourier);
mod_db=20.*log10(mod);

freq=-1./(2.*time_step):1./tmax:1./(2.*time_step);
figure;
plot(freq,mod_db)
%xlim([0 max(freq)])

%figure;
%semilogx(freq(freq>0),mod_db(freq>0))