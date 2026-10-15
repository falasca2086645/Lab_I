function [out_modulus,out_phase]=s11resonance2(freq,fris,beta,Q0)
% Computes the S11 of a single resonace with ...
% It gives modulus and phase directly
% function [modulus,phase]=s11resonance2(freq,fris,beta,Q0)

% Qload=Q0/(beta+1);
delta=freq./fris-fris./freq;

out_modulus=sqrt(((beta-1).^2+(Q0.*delta).^2)./((beta+1).^2+(Q0.*delta).^2));
out_phase=atan2(Q0.*delta./(1-beta),1)-atan2(Q0.*delta./(1+beta),1);
