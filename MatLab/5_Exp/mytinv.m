function y=mytinv(x,n)
% MYTINV returns inverse cumulative function of the student distribution
%
% x = tinv(p,v);
%
% Computes the quantile (inverse of the CDF) of a the student
%    cumulative distribution with mean m and standard deviation s
% p,v must be matrices of same size, or any one can be a scalar. 
%

% Reference(s):

%	$Revision: 1.1 $
%	$Id: tinv.m,v 1.1 2003/09/12 12:14:45 schloegl Exp $
%	Version 1.28   Date: 13 Mar 2003
%	Copyright (c) 2000-2003 by  Alois Schloegl <a.schloegl@ieee.org>	


% allocate output memory and check size of arguments
y = x+n-n;	% if this line causes an error, size of input arguments do not fit.
n = n+x-x;

y = norminv(x); % do special cases, like x<=0, x>=1, isnan(x), n > 10000;
y(~(n>0)) = NaN; 

ix = find(~isnan(x) & (n>0) & (n<10000));
if ~isempty(ix)
        y(ix) = (sign(x(ix) - 1/2).*sqrt(n(ix)./betainv(2*min(x(ix), 1-x(ix)), n(ix)/2, 1/2) - n(ix)));
end;

y = reshape(y,size(x));

function x = norminv(p,m,s)
% NORMINV returns inverse cumulative function of the normal distribution
%
% x = norminv(p,m,s);
%
% Computes the quantile (inverse of the CDF) of a the normal 
%    cumulative distribution with mean m and standard deviation s
%    default: m=0; s=1;
% p,m,s must be matrices of same size, or any one can be a scalar. 
%
% see also: NORMPDF, NORMCDF 

% Reference(s):

%	$Revision: 1.6 $
%	$Id: norminv.m,v 1.6 2003/03/13 16:00:33 schloegl Exp $
%	Version 1.28   Date: 13 Mar 2003
%	Copyright (c) 2000-2003 by  Alois Schloegl <a.schloegl@ieee.org>	


if nargin==1,
        m=0; s=1;
elseif nargin==2,
        s=1;
end;        

% allocate output memory and check size of arguments
x = sqrt(2)*erfinv(2*p - 1).*s + m;  % if this line causes an error, input arguments do not fit. 

x((p>1) | (p<0) | isnan(p) | isnan(m) | isnan(s) | (s<0)) = nan;

k = (s==0) & ~isnan(m);		% temporary variable, reduces number of tests.

x((p==0) & k) = -inf;

x((p==1) & k) = +inf;

k = (p>0) & (p<1) & k;
if prod(size(m))==1,
        x(k) = m;
else
        x(k) = m(k);
end;   

function x = betainv(p,a,b)
%BETAINV Inverse of the beta cumulative distribution function (cdf).
%   X = BETAINV(P,A,B) returns the inverse of the beta cdf with 
%   parameters A and B at the values in P.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   BETAINV uses Newton's method to converge to the solution.

%   Reference:
%      [1]     M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964.

%   B.A. Jones 1-12-93
%   Copyright (c) 1993-98 by The MathWorks, Inc.
%   $Revision: 2.7 $  $Date: 1997/11/29 01:44:51 $

if nargin <  3, 
    error('Requires three input arguments.'); 
end

[errorcode p a b] = distchck(3,p,a,b);

if errorcode > 0
    error('Requires non-scalar arguments to match in size.');
end

%   Initialize x to zero.
x = zeros(size(p));

%   Return NaN if the arguments are outside their respective limits.
k = find(p < 0 | p > 1 | a <= 0 | b <= 0);
if any(k),
   tmp = NaN;
   x(k) = tmp(ones(size(k))); 
end

% The inverse cdf of 0 is 0, and the inverse cdf of 1 is 1.  
k0 = find(p == 0 & a > 0 & b > 0);
if any(k0), 
    x(k0) = zeros(size(k0)); 
end

k1 = find(p==1);
if any(k1), 
    x(k1) = ones(size(k1)); 
end

% Newton's Method.
% Permit no more than count_limit interations.
count_limit = 100;
count = 0;

k = find(p > 0 & p < 1 & a > 0 & b > 0);
if isempty(k)
   return;
end
pk = p(k);

%   Use the mean as a starting guess. 
xk = a(k) ./ (a(k) + b(k));


% Move starting values away from the boundaries.
if xk == 0,
    xk = sqrt(eps);
end
if xk == 1,
    xk = 1 - sqrt(eps);
end


h = ones(size(pk));
crit = sqrt(eps); 

% Break out of the iteration loop for the following:
%  1) The last update is very small (compared to x).
%  2) The last update is very small (compared to 100*eps).
%  3) There are more than 100 iterations. This should NEVER happen. 

while(any(abs(h) > crit * abs(xk)) & max(abs(h)) > crit    ...
                                 & count < count_limit), 
                                 
    count = count+1;    
    h = (betacdf(xk,a(k),b(k)) - pk) ./ betapdf(xk,a(k),b(k));
    xnew = xk - h;

% Make sure that the values stay inside the bounds.
% Initially, Newton's Method may take big steps.
    ksmall = find(xnew < 0);
    klarge = find(xnew > 1);
    if any(ksmall) | any(klarge)
        xnew(ksmall) = xk(ksmall) /10;
        xnew(klarge) = 1 - (1 - xk(klarge))/10;
    end

    xk = xnew;  
end

% Return the converged value(s).
x(k) = xk;

if count==count_limit, 
    fprintf('\nWarning: BETAINV did not converge.\n');
    str = 'The last step was:  ';
    outstr = sprintf([str,'%13.8f'],h);
    fprintf(outstr);
end

function [errorcode,out1,out2,out3,out4] = distchck(nparms,arg1,arg2,arg3,arg4)
%DISTCHCK Checks the argument list for the probability functions.

%   B.A. Jones  1-22-93
%   Copyright (c) 1993-98 by The MathWorks, Inc.
%   $Revision: 2.6 $  $Date: 1997/11/29 01:45:12 $

errorcode = 0;

if nparms == 1
    out1 = arg1;
    return;
end
    
if nparms == 2
    [r1 c1] = size(arg1);
    [r2 c2] = size(arg2);
    scalararg1 = (prod(size(arg1)) == 1);
    scalararg2 = (prod(size(arg2)) == 1);
    if ~scalararg1 & ~scalararg2
        if r1 ~= r2 | c1 ~= c2
            errorcode = 1;
            return;         
        end     
    end
    if scalararg1
        out1 = arg1(ones(r2,1),ones(c2,1));
    else
        out1 = arg1;
    end
    if scalararg2
        out2 = arg2(ones(r1,1),ones(c1,1));
    else
        out2 = arg2;
    end
end
    
if nparms == 3
    [r1 c1] = size(arg1);
    [r2 c2] = size(arg2);
    [r3 c3] = size(arg3);
    scalararg1 = (prod(size(arg1)) == 1);
    scalararg2 = (prod(size(arg2)) == 1);
    scalararg3 = (prod(size(arg3)) == 1);

    if ~scalararg1 & ~scalararg2
        if r1 ~= r2 | c1 ~= c2
            errorcode = 1;
            return;         
        end
    end

    if ~scalararg1 & ~scalararg3
        if r1 ~= r3 | c1 ~= c3
            errorcode = 1;
            return;                 
        end
    end

    if ~scalararg3 & ~scalararg2
        if r3 ~= r2 | c3 ~= c2
            errorcode = 1;
            return;         
        end
    end

    if ~scalararg1
      out1 = arg1;
    end
    if ~scalararg2
      out2 = arg2;
    end
    if ~scalararg3
      out3 = arg3;
    end
    rows = max([r1 r2 r3]);
   columns = max([c1 c2 c3]);  
       
    if scalararg1
        out1 = arg1(ones(rows,1),ones(columns,1));
    end
   if scalararg2
        out2 = arg2(ones(rows,1),ones(columns,1));
   end
   if scalararg3
       out3 = arg3(ones(rows,1),ones(columns,1));
   end
     out4 =[];
    
end

if nparms == 4
    [r1 c1] = size(arg1);
    [r2 c2] = size(arg2);
    [r3 c3] = size(arg3);
    [r4 c4] = size(arg4);
    scalararg1 = (prod(size(arg1)) == 1);
    scalararg2 = (prod(size(arg2)) == 1);
    scalararg3 = (prod(size(arg3)) == 1);
    scalararg4 = (prod(size(arg4)) == 1);

    if ~scalararg1 & ~scalararg2
        if r1 ~= r2 | c1 ~= c2
            errorcode = 1;
            return;         
        end
    end

    if ~scalararg1 & ~scalararg3
        if r1 ~= r3 | c1 ~= c3
            errorcode = 1;
            return;                 
        end
    end

    if ~scalararg1 & ~scalararg4
        if r1 ~= r4 | c1 ~= c4
            errorcode = 1;
            return;                 
        end
    end

    if ~scalararg3 & ~scalararg2
        if r3 ~= r2 | c3 ~= c2
            errorcode = 1;
            return;         
        end
    end

    if ~scalararg4 & ~scalararg2
        if r4 ~= r2 | c4 ~= c2
            errorcode = 1;
            return;         
        end
    end

    if ~scalararg3 & ~scalararg4
        if r3 ~= r4 | c3 ~= c4
            errorcode = 1;
            return;         
        end
    end


    if ~scalararg1
       out1 = arg1;
    end
    if ~scalararg2
       out2 = arg2;
    end
    if ~scalararg3
      out3 = arg3;
    end
    if ~scalararg4
      out4 = arg4;
    end
 
   rows = max([r1 r2 r3 r4]);
   columns = max([c1 c2 c3 c4]);     
    if scalararg1
       out1 = arg1(ones(rows,1),ones(columns,1));
   end
   if scalararg2
       out2 = arg2(ones(rows,1),ones(columns,1));
   end
   if scalararg3
       out3 = arg3(ones(rows,1),ones(columns,1));
   end
   if scalararg4
       out4 = arg4(ones(rows,1),ones(columns,1));
   end
end

function p = betacdf(x,a,b)
%BETACDF Beta cumulative distribution function.
%   P = BETACDF(X,A,B) returns the beta cumulative distribution
%   function with parameters A and B at the values in X.
%
%   The size of P is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   BETAINC does the computational work.

%   Reference:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.5.

%   Copyright (c) 1993-98 by The MathWorks, Inc.
%   $Revision: 2.6 $  $Date: 1997/11/29 01:44:49 $

if nargin<3, 
   error('Requires three input arguments.'); 
end

[errorcode x a b] = distchck(3,x,a,b);

if errorcode > 0
   error('Requires non-scalar arguments to match in size.');
end

% Initialize P to 0.
p = zeros(size(x));

k1 = find(a<=0 | b<=0);
if any(k1)
   tmp = NaN;
   p(k1) = tmp(ones(size(k1))); 
end

% If is X >= 1 the cdf of X is 1. 
k2 = find(x >= 1);
if any(k2)
   p(k2) = ones(size(k2));
end

k = find(x > 0 & x < 1 & a > 0 & b > 0);
if any(k)
   p(k) = betainc(x(k),a(k),b(k));
end

% Make sure that round-off errors never make P greater than 1.
k = find(p > 1);
p(k) = ones(size(k));

function y = betapdf(x,a,b)
%BETAPDF Beta probability density function.
%   Y = BETAPDF(X,A,B) returns the beta probability density 
%   function with parameters A and B at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.33.

%   Copyright (c) 1993-98 by The MathWorks, Inc.
%   $Revision: 2.7 $  $Date: 1997/11/29 01:44:52 $

if nargin < 3, 
   error('Requires three input arguments.');
end

[errorcode x a b] = distchck(3,x,a,b);

if errorcode > 0
    error('Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero.
y = zeros(size(x));

% Return NaN for parameter values outside their respective limits.
k1 = find(a <= 0 | b <= 0 | x < 0 | x > 1);
if any(k1)
    tmp = NaN;
    y(k1) = tmp(ones(size(k1))); 
end

% Return Inf for x = 0 and a < 1 or x = 1 and b < 1.
% Required for non-IEEE machines.
k2 = find((x == 0 & a < 1) | (x == 1 & b < 1));
if any(k2)
    tmp = Inf;
    y(k2) = tmp(ones(size(k2))); 
end

% Return the beta density function for valid parameters.
k = find(~(a <= 0 | b <= 0 | x <= 0 | x >= 1));
if any(k)
%    y(k) = x(k) .^ (a(k) - 1) .* (1 - x(k)) .^ (b(k) - 1) ./ beta(a(k),b(k));
     tmp(k) = (a(k) - 1).*log(x(k)) + (b(k) - 1).*log((1 - x(k))) - betaln(a(k),b(k));
     y(k) = exp(tmp(k));
end