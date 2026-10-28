function dataStruct = getdataLecroyRB

load('interface_scope-Lecroy_WavePro960.mat')
load('device_scope-Lecroy_WavePro960.mat')

interfaceObj = instrfind('Type','tcpip','RemoteHost','192.168.0.106','RemotePort',1861);

if isempty(interfaceObj)
    interfaceObj = tcpip('192.168.0.106',1861);
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end

deviceObj = icdevice('lecroy_WavePro960.mdd', interfaceObj);
connect(deviceObj);

groupObj = get(deviceObj,'Waveform');

channels = ["channel1","channel2","channel3","channel4"];

thr_p2p = 0.000000001;

formattedData = [];
timeAxis = [];
activeChannels = [];

yUnit = '';
xUnit = '';

for k = 1:length(channels)
    try
        [Y, X, YUNIT, XUNIT, HEADER] = invoke(groupObj,'readwaveform',channels(k));

        if isempty(timeAxis)
            timeAxis = X';
            yUnit = YUNIT;
            xUnit = XUNIT;
        end

        p2p = max(Y) - min(Y);

        if p2p < thr_p2p
            continue
        end

        formattedData(:, end+1) = Y';
        activeChannels(end+1) = k;

    catch
    end
end

dataStruct.formattedData = formattedData;
dataStruct.xaxis = timeAxis;
dataStruct.activeChannels = activeChannels;

if strcmp(xUnit,'S')
    dataStruct.xlabel = 'Time (s)';
end

if ~isempty(yUnit)
    dataStruct.ylabel = ['(' yUnit ')'];
end

disconnect(deviceObj);
delete(deviceObj);

end
