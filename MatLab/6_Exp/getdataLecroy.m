function dataStruct = getdataLecroy(IPaddress, varargin)
%GETDATALECROY Read WavePro HD channel waveforms using remote commands only.
%   D = GETDATALECROY(IPaddress) reads displayed channels C1 through C4.
%   No LeCroy .mdd/.mat driver, ActiveDSO, or VISA installation is used.
%   Requires MATLAB tcpclient (Instrument Control Toolbox in MATLAB R2022a).
%
%   On the scope select Utilities > Utilities Setup > Remote > TCP/IP (VICP).
%   Port 1861 uses VICP: the commands require an eight-byte transport header.
%   All instrument operations below use LeCroy IEEE 488.2/SCPI-style commands;
%   there are no VBS/COM Automation commands.
%
%   Name/value options:
%     'Timeout'              Seconds per complete query (default 90).
%     'PeakToPeakThreshold'   Reject traces below this amplitude (default 1e-9,
%                            matching the original). Use 0 to retain DC traces.
%     'MaxPoints'             Maximum transferred points/channel (default 0,
%                            meaning all points). Does not change acquisition.
%     'Port'                  TCP port (default 1861).
%
%   Compatible output fields:
%     formattedData          First retained channel, as an N-by-1 vector.
%     xaxis                  Time axis of that same channel, as a column.
%     activeChannels         Physical channel numbers of retained traces.
%     formattedDataCH1..CH4   Channel data, or [] if off/empty/rejected.
%     xlabel, ylabel         Axis labels for the first retained channel.
%   Additional fields:
%     xaxisCH1..CH4           Individual time axes (lengths may differ).
%     enabledChannels        Channels whose TRACE? state is ON.
%     channelInfo            1-by-4 cell array of waveform metadata.
%     instrument             Response to *IDN?.
%
%   Reads the current waveforms; it does not initiate a new acquisition.
%   Stop acquisition on the scope before calling if all channels must belong
%   to one frozen acquisition. While running, channels may be read from
%   different acquisitions. The run/trigger mode is not changed here.
%
%   Supports ordinary single-record waveforms, including averaged records.
%   Sequence, RIS, two-array/peak-detect and extended multi-block records are
%   rejected explicitly. Binary blocks must fit the DEF9 size field (<1 GB).
%   Long records also require enough MATLAB memory for double-valued outputs.
%   Transfer settings are left at CHDR OFF, CFMT DEF9,WORD,BIN, CORD LO,
%   WFSU SP,1,NP,<MaxPoints>,FP,0,SN,0.
%
%   Examples:
%     d = getdataLecroy('192.168.0.106');
%     d = getdataLecroy('192.168.0.106', 'PeakToPeakThreshold', 0);
%     plot(d.xaxis, d.formattedData);
%     % For a specific channel: plot(d.xaxisCH3, d.formattedDataCH3)
%
%   Reference: Teledyne LeCroy MAUI Remote Control and Automation Manual,
%   VICP headers, waveform file format, CFMT/CORD/CHDR/WFSU/WF/TRACE.
%   https://cdn.teledynelecroy.com/files/manuals/maui-remote-control-and-automation-manual.pdf

p = inputParser;
p.FunctionName = mfilename;
addRequired(p, 'IPaddress', @(x) (ischar(x) && isrow(x) && ~isempty(x)) || ...
    (isstring(x) && isscalar(x) && strlength(x) > 0));
addParameter(p, 'Timeout', 90, @(x) isnumeric(x) && isscalar(x) && ...
    isreal(x) && isfinite(x) && x >= 1);
addParameter(p, 'PeakToPeakThreshold', 1e-9, @(x) isnumeric(x) && ...
    isscalar(x) && isreal(x) && isfinite(x) && x >= 0);
addParameter(p, 'MaxPoints', 0, @(x) isnumeric(x) && isscalar(x) && ...
    isreal(x) && isfinite(x) && x >= 0 && x == fix(x) && x <= 499999000);
addParameter(p, 'Port', 1861, @(x) isnumeric(x) && isscalar(x) && ...
    isreal(x) && isfinite(x) && x >= 1 && x <= 65535 && x == fix(x));
parse(p, IPaddress, varargin{:});
opt = p.Results;

socket = tcpclient(char(IPaddress), double(opt.Port), ...
    'Timeout', double(opt.Timeout), 'ConnectTimeout', double(opt.Timeout));
socketCleanup = onCleanup(@() delete(socket)); %#ok<NASGU>
sequence = 0;

dataStruct = struct('formattedData', [], 'xaxis', [], ...
    'activeChannels', [], 'xlabel', '', 'ylabel', '', ...
    'enabledChannels', [], 'channelInfo', {cell(1, 4)}, 'instrument', '');
for ch = 1:4
    dataStruct.(sprintf('formattedDataCH%d', ch)) = [];
    dataStruct.(sprintf('xaxisCH%d', ch)) = [];
end

sendCommand('CHDR OFF');
dataStruct.instrument = strtrim(char(query('*IDN?')));
sendCommand('CFMT DEF9,WORD,BIN');  % Keep the HD scope's 16-bit precision.
sendCommand('CORD LO');
sendCommand(sprintf('WFSU SP,1,NP,%.0f,FP,0,SN,0', opt.MaxPoints));

for ch = 1:4
    state = strtrim(char(query(sprintf('C%d:TRA?', ch))));
    if strcmpi(state, 'OFF')
        continue;
    elseif ~strcmpi(state, 'ON')
        error('getdataLecroy:TraceState', ...
            'Unexpected C%d:TRA? response: %s', ch, state);
    end
    dataStruct.enabledChannels(end+1) = ch;

    % One WF? ALL response keeps the descriptor and its samples together.
    reply = query(sprintf('C%d:WF? ALL', ch));
    [y, x, info] = decodeWaveform(reply);
    dataStruct.channelInfo{ch} = info;
    if isempty(y)
        warning('getdataLecroy:NoData', 'C%d is displayed but has no valid samples.', ch);
        continue;
    end
    if max(y) - min(y) < opt.PeakToPeakThreshold
        continue;
    end

    dataStruct.(sprintf('formattedDataCH%d', ch)) = y;
    dataStruct.(sprintf('xaxisCH%d', ch)) = x;
    dataStruct.activeChannels(end+1) = ch;
    if numel(dataStruct.activeChannels) == 1
        dataStruct.formattedData = y;
        dataStruct.xaxis = x;
        if strcmpi(info.xUnit, 'S')
            dataStruct.xlabel = 'Time (s)';
        elseif ~isempty(info.xUnit)
            dataStruct.xlabel = ['(' info.xUnit ')'];
        end
        if ~isempty(info.yUnit)
            dataStruct.ylabel = ['(' info.yUnit ')'];
        end
    end
end

    function sendCommand(command)
        % VICP lengths are always big-endian, regardless of CORD.
        sequence = mod(sequence, 255) + 1;
        payload = uint8([command char(10)]);
        n = numel(payload);
        lengthBytes = uint8(mod(floor(n ./ [2^24 2^16 2^8 1]), 256));
        header = [uint8([193 1 sequence 0]) lengthBytes]; % DATA|REMOTE|EOI
        write(socket, [header payload], 'uint8');
    end

    function reply = query(command)
        sendCommand(command);
        started = tic;
        chunks = {};
        total = 0;
        receivedData = false;
        while true
            header = readExact(8, started, command);
            if header(2) ~= 1
                error('getdataLecroy:VICPHeader', ...
                    'Unsupported VICP header version while reading %s.', command);
            end
            flags = header(1);
            n = double(header(5:8)) * [2^24; 2^16; 2^8; 1];
            if n > 1e9 || total + n > 1e9
                error('getdataLecroy:ResponseTooLarge', ...
                    'Response exceeds the supported DEF9 size. Reduce MaxPoints.');
            end
            part = readExact(n, started, command);
            if bitand(flags, uint8(128)) ~= 0  % DATA
                % Accept unsequenced replies (0); reject other stale replies.
                if header(3) ~= 0 && double(header(3)) ~= sequence
                    error('getdataLecroy:VICPSequence', ...
                        'Unexpected VICP response sequence while reading %s.', command);
                end
                chunks{end+1} = part; %#ok<AGROW>
                total = total + n;
                receivedData = true;
            end
            % SRQ/status frames can occur between data frames. A final
            % DATA|EOI frame may be empty. LF is never a binary delimiter.
            if receivedData && bitand(flags, uint8(128)) ~= 0 && ...
                    bitand(flags, uint8(1)) ~= 0
                break;
            end
        end
        reply = [chunks{:}];
    end

    function bytes = readExact(n, started, command)
        bytes = zeros(1, n, 'uint8');
        pos = 1;
        while pos <= n
            if toc(started) > opt.Timeout
                error('getdataLecroy:Timeout', ...
                    'Timed out receiving %s. The connection will be closed.', command);
            end
            available = double(socket.NumBytesAvailable);
            if available == 0
                pause(0.005);
                continue;
            end
            count = min([available, n-pos+1, 2^20]);
            part = read(socket, count, 'uint8');
            if numel(part) ~= count
                error('getdataLecroy:ShortRead', ...
                    'Incomplete TCP read while receiving %s.', command);
            end
            bytes(pos:pos+count-1) = reshape(part, 1, []);
            pos = pos + count;
        end
    end
end

function [y, x, info] = decodeWaveform(reply)
% Strip an IEEE 488.2 definite-length binary block, allowing a short prefix.
marker = find(reply(1:min(80, numel(reply))) == uint8('#'), 1);
if isempty(marker) || marker + 1 > numel(reply)
    error('getdataLecroy:BinaryBlock', 'Waveform response has no binary block header.');
end
digits = double(reply(marker+1)) - double('0');
if digits < 1 || digits > 9 || marker + 1 + digits > numel(reply)
    error('getdataLecroy:BinaryBlock', ...
        'Unsupported block header. Use a conventional DEF9 waveform record.');
end
sizeText = char(reply(marker+2:marker+1+digits));
if any(sizeText < '0' | sizeText > '9')
    error('getdataLecroy:BinaryBlock', 'Invalid binary block length.');
end
n = str2double(sizeText);
first = marker + 2 + digits;
last = first + n - 1;
if last > numel(reply)
    error('getdataLecroy:BinaryBlock', 'Truncated waveform binary block.');
end
tail = reply(last+1:end);
if any(tail ~= 10 & tail ~= 13 & tail ~= 32)
    error('getdataLecroy:ExtendedRecord', ...
        'Extended/multiple waveform blocks are not supported. Reduce MaxPoints.');
end
b = reply(first:last);
if numel(b) < 344 || ~isequal(b(1:8), uint8('WAVEDESC'))
    error('getdataLecroy:Descriptor', 'Missing or truncated WAVEDESC descriptor.');
end

% COMM_ORDER is at zero-based byte offset 34. Detect it before typecasting.
if isequal(b(35:36), uint8([1 0]))
    littleEndian = true;
elseif isequal(b(35:36), uint8([0 0]))
    littleEndian = false;
else
    error('getdataLecroy:ByteOrder', 'Invalid COMM_ORDER in waveform descriptor.');
end
num = @(offset, kind, width) double(unpack(b(offset+(1:width)), kind, littleEndian));
txt = @(offset, width) readText(b(offset+(1:width)));
info = struct;
info.template = txt(16, 16);
if ~strncmp(info.template, 'LECROY_2_', 9)
    error('getdataLecroy:Template', 'Unsupported waveform template: %s', info.template);
end
info.commType = num(32, 'int16', 2);
info.descriptorLength = num(36, 'int32', 4);
info.sampleCount = num(116, 'int32', 4);
info.firstValidPoint = num(124, 'int32', 4);
info.lastValidPoint = num(128, 'int32', 4);
info.firstPoint = num(132, 'int32', 4);
info.sparsingFactor = num(136, 'int32', 4);
info.segmentIndex = num(140, 'int32', 4);
info.subarrayCount = num(144, 'int32', 4);
info.verticalGain = num(156, 'single', 4);
info.verticalOffset = num(160, 'single', 4);
info.horizontalInterval = num(176, 'single', 4);
info.horizontalOffset = num(180, 'double', 8);
info.yUnit = txt(196, 48);
info.xUnit = txt(244, 48);
info.recordType = num(316, 'int16', 2);
info.processingDone = num(318, 'int16', 2);
info.risSweeps = num(322, 'int16', 2);

% Lengths of all sections, in file order (including reserved sections).
lengths = zeros(1, 10);
for k = 1:10
    lengths(k) = num(36 + 4*(k-1), 'int32', 4);
end
if any(lengths < 0) || lengths(1) < 344 || sum(lengths) ~= numel(b)
    error('getdataLecroy:Descriptor', 'Inconsistent waveform section lengths.');
end
if info.subarrayCount > 1 || lengths(4) > 0 || info.recordType == 7
    error('getdataLecroy:SequenceRecord', ...
        'Sequence records need a time axis per segment; this routine supports single records.');
end
if lengths(5) > 0 || info.risSweeps > 1 || info.recordType == 8
    error('getdataLecroy:RISRecord', 'RIS records are not supported by this routine.');
end
if lengths(8) > 0 || any(info.recordType == [1 2 3 5 6 9])
    error('getdataLecroy:TwoArrayRecord', ...
        'Two-array/peak-detect records are not supported by this routine.');
end
if info.firstPoint ~= 0 || ~ismember(info.sparsingFactor, [0 1])
    error('getdataLecroy:TransferSetup', ...
        'Unexpected partial/sparsed transfer. Expected WFSU SP,1,FP,0.');
end
if info.commType == 1
    kind = 'int16';
    bytesPerPoint = 2;
elseif info.commType == 0
    kind = 'int8';
    bytesPerPoint = 1;
else
    error('getdataLecroy:DataType', 'Unsupported COMM_TYPE in waveform descriptor.');
end
if info.sampleCount < 0 || lengths(7) ~= info.sampleCount * bytesPerPoint
    error('getdataLecroy:SampleCount', 'Waveform sample count and data length disagree.');
end
y = [];
x = [];
if info.sampleCount == 0 || info.processingDone == 5 || ...
        info.lastValidPoint < info.firstValidPoint
    return;
end
if info.firstValidPoint < 0 || info.lastValidPoint >= info.sampleCount
    error('getdataLecroy:ValidPoints', 'Invalid valid-sample range in waveform descriptor.');
end
if ~all(isfinite([info.verticalGain info.verticalOffset ...
        info.horizontalInterval info.horizontalOffset])) || ...
        info.horizontalInterval <= 0 || info.verticalGain <= 0
    error('getdataLecroy:Scaling', 'Invalid waveform scaling information.');
end

dataStart = sum(lengths(1:6));  % Zero-based DATA_ARRAY_1 offset.
indices = (info.firstValidPoint:info.lastValidPoint).';
firstByte = dataStart + info.firstValidPoint * bytesPerPoint + 1;
lastByte = dataStart + (info.lastValidPoint + 1) * bytesPerPoint;
raw = unpack(b(firstByte:lastByte), kind, littleEndian);
y = double(raw(:)) * info.verticalGain - info.verticalOffset;
x = info.horizontalOffset + indices * info.horizontalInterval;
end

function values = unpack(bytes, kind, littleEndian)
values = typecast(uint8(bytes), kind);
[~, ~, hostOrder] = computer;
if littleEndian ~= (hostOrder == 'L')
    values = swapbytes(values);
end
end

function textValue = readText(bytes)
zero = find(bytes == 0, 1);
if ~isempty(zero)
    bytes = bytes(1:zero-1);
end
textValue = strtrim(char(bytes));
end
