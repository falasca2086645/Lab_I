function data=getdataLecroyfile(filename) 
% getdataLecroy - Get data from the Lecroy oscilloscope when saved as
%                   matlab file (*.dat) from the instrument
%
% The function returns the struct data with the following informations:
%       - formatted data (formattedData)
%       - frequency (xaxis) 
%       - xlabel
%       - ylabel
%   
%   data = getdataLecroyfile(filename)
%
% Mostacci version 1.0  04/07/2026

% Set the import options for .dat file set to importa matlab tables
opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["xaxis", "signal"];
opts.VariableTypes = ["double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Import the data
aux = readtable(filename, opts);
xaxis=aux.xaxis;
formattedData=aux.signal;

% Build the output Struct
data=struct('formattedData',formattedData,'xaxis',xaxis);

% Lecroy oscilloscope can have time signals (in Volts) or frequency
% spectrum in dBm

% To select between time or frequency we see if the value on the xaxis are
% smaller than 1 (probably time) or bigger than 1 (probably frequncy)
if mean(formattedData)< 1 
    data.xlabel='Time (s)';
    data.ylabel='Volt';
elseif mean(formattedData)> 1 
    data.xlabel='Frequency (s)';
    data.ylabel='dBm';
end
