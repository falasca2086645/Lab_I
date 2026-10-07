function m = Media(V)
%MEDIA Restituisce la media degli elementi di V (vettore riga o colonna).
%   m = Media(V)

if ~isvector(V)
    error('Input deve essere un vettore (riga o colonna).')
end

m = sum(V(:)) / numel(V);
end