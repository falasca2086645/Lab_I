function [p,unc_p,q,unc_q,rfactor]=regression3(x,y)
% Finds the regression line y = p x + q
% p slope
% q intercept
% unc_p p uncertanty
% unc_q q uncertainty
% rfactor	fit quality factor
% function [p,unc_p,q,unc_q,rfactor]=regression3(x,y)

% Codice dato da Mostaccci per trovare la retta per la regressione linare.
% X e Y vettori di ingresso
if length(x)~= length(y)
    error('Vectors must be of the same length');
end

N=length(x);

p=(N*sum(x.*y)-sum(x)*sum(y))/(N*sum(x.^2)-(sum(x))^2);
q=(sum(x.^2)*sum(y)-sum(x)*sum(x.*y))/(N*sum(x.^2)-(sum(x))^2);

mean_x=mean(x);
sigma_x=sqrt(sum((x-mean(x)).^2)/N);
sigma_y=sqrt(sum((y-(p.*x+q)).^2)/(N-2));
unc_p=sigma_y/(sqrt(N)*sigma_x);
unc_q=sigma_y/(sqrt(N)*sigma_x)*sqrt(sigma_x^2+mean_x^2);
rfactor=(N*sum(x.*y)-sum(x)*sum(y))/...
    sqrt((N*sum(x.^2)-(sum(x))^2).*(N*sum(y.^2)-(sum(y))^2));
Visualizzazione di regression3.m.