function out=s11resonance(freq,fris,beta,Q0)
% Computes the S11 of a single resonace with ...
% function out=s11resonance(freq,fris,beta,Q0)

% Qload=Q0/(beta+1);
delta=freq./fris-fris./freq;

out=(beta-1-j*Q0.*delta)./(beta+1+j*Q0.*delta);
