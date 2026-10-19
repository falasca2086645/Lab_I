function [fig, ax, lineHandle] = plotDataStruct(dataStruct, options)
%PLOTDATASTRUCT Plot a laboratory spectrum with the reference formatting.
%   plotDataStruct(dataStruct) plots dataStruct.formattedData against
%   dataStruct.xaxis using the same appearance as the reference plots:
%   continuous red trace, frequency in Hz, Helvetica 22 pt text, grid and
%   two-point-wide axes.
%
%   [FIG, AX, LINES] = plotDataStruct(...) returns the graphics handles.
%   LINES contains one short line object per pair of adjacent samples. This
%   is intentional: it works around a Linux graphics-driver defect which
%   drops parts of long MATLAB polylines on this computer.
%
%   Name-value options (MATLAB R2021a or newer):
%     Title          - plot title (default: empty)
%     XLabel         - x label; by default uses dataStruct.xlabel
%     YLabel         - y label; by default uses dataStruct.ylabel when
%                      available, otherwise "power (dBm)"
%     FrequencyUnit  - "Hz", "kHz", "MHz", "GHz", or "auto"
%                      (default: "Hz")
%     XLimits        - [minimum maximum], or [] for the complete x data
%     YLimits        - [minimum maximum], or [] for reference auto limits
%     NoiseFloor     - lower display floor used by reference auto limits
%                      (default: -100)
%     LineWidth      - trace width (default: 2)
%     Color          - trace color (default: red)
%     Parent         - existing axes; [] creates a new figure
%     FigurePosition - [left bottom width height] in pixels
%     ShowGrid       - show major grid (default: true)
%
%   The automatic y range contains every finite sample. It extends down to
%   NoiseFloor when the data do not already go below it, and ends at the
%   largest sample. For the supplied 3_1 data this gives the reference
%   interval [-100, 3.01] dB.
%
%   Example:
%     S = load('3_1_Misura_Sinusoide_Vp1V_f1Mhz_SPAN50kHz_RBW1kHz..mat');
%     plotDataStruct(S.dataStruct)

    arguments
        dataStruct (1,1) struct
        options.Title (1,1) string = ""
        options.XLabel (1,1) string = ""
        options.YLabel (1,1) string = ""
        options.FrequencyUnit (1,1) string = "Hz"
        options.XLimits double = []
        options.YLimits double = []
        options.NoiseFloor (1,1) double = -100
        options.LineWidth (1,1) double {mustBePositive} = 2
        options.Color = [1 0 0]
        options.Parent = []
        options.FigurePosition (1,4) double = [100 100 933 700]
        options.ShowGrid (1,1) logical = true
    end

    requiredFields = {'xaxis', 'formattedData'};
    missing = requiredFields(~isfield(dataStruct, requiredFields));
    if ~isempty(missing)
        error('plotDataStruct:MissingField', ...
            'dataStruct is missing required field(s): %s.', ...
            strjoin(missing, ', '));
    end

    x = dataStruct.xaxis(:);
    y = dataStruct.formattedData(:);
    if ~isnumeric(x) || ~isnumeric(y) || ~isreal(x) || ~isreal(y) || ...
            ~isvector(dataStruct.xaxis) || ~isvector(dataStruct.formattedData)
        error('plotDataStruct:InvalidData', ...
            'xaxis and formattedData must be real numeric vectors.');
    end
    if numel(x) ~= numel(y)
        error('plotDataStruct:SizeMismatch', ...
            'xaxis (%d samples) and formattedData (%d samples) differ in length.', ...
            numel(x), numel(y));
    end

    valid = isfinite(x) & isfinite(y);
    if ~any(valid)
        error('plotDataStruct:NoFiniteData', 'There are no finite samples to plot.');
    end
    x = x(valid);
    y = y(valid);
    [x, order] = sort(x);
    y = y(order);

    [scale, unit] = frequencyScale(x, options.FrequencyUnit);
    xPlot = x ./ scale;

    if isempty(options.XLimits)
        displayXLimits = finiteRange(xPlot);
    else
        validateLimits(options.XLimits, 'XLimits');
        displayXLimits = options.XLimits ./ scale;
    end
    if isempty(options.YLimits)
        displayYLimits = [min(options.NoiseFloor, min(y)), max(y)];
        if displayYLimits(1) == displayYLimits(2)
            padding = max(1, abs(displayYLimits(1)) * 0.05);
            displayYLimits = displayYLimits + [-padding padding];
        end
    else
        validateLimits(options.YLimits, 'YLimits');
        displayYLimits = options.YLimits;
    end

    if isempty(options.Parent)
        fig = figure('Color', 'white', 'GraphicsSmoothing', 'on', ...
            'Name', char(options.Title), 'NumberTitle', 'off', ...
            'Units', 'pixels', 'Position', options.FigurePosition);
        ax = axes('Parent', fig);
    else
        ax = options.Parent;
        if ~isgraphics(ax, 'axes')
            error('plotDataStruct:InvalidParent', 'Parent must be an axes handle.');
        end
        fig = ancestor(ax, 'figure');
        cla(ax, 'reset');
    end
    if isempty(options.Parent)
        % Normalized geometry measured from the supplied reference JPEG.
        set(ax, 'Units', 'normalized', ...
            'Position', [0.13 0.184 0.775 0.74]);
    end

    % A real white patch is used instead of the axes Color property. On the
    % affected Mesa/OpenGL combination MATLAB sometimes exports a white axes
    % background as black. The patch is stable in both the window and files.
    hold(ax, 'on');
    background = patch(ax, ...
        displayXLimits([1 2 2 1]), displayYLimits([1 1 2 2]), 'white', ...
        'EdgeColor', 'none', 'HandleVisibility', 'off', ...
        'PickableParts', 'none'); %#ok<NASGU>

    % Do not replace this with a single plot(x,y) call. MATLAB R2025b with
    % the installed Linux graphics stack loses most segments of that line.
    % Independent two-point objects render as one visually continuous trace.
    if numel(xPlot) == 1
        lineHandle = line(ax, xPlot, y, 'LineStyle', 'none', ...
            'Marker', '.', 'MarkerSize', 6, 'Color', options.Color);
    else
        segmentX = [xPlot(1:end-1).'; xPlot(2:end).'];
        segmentY = [y(1:end-1).'; y(2:end).'];
        lineHandle = line(ax, segmentX, segmentY, ...
            'Color', options.Color, 'LineWidth', options.LineWidth, ...
            'LineStyle', '-', 'Marker', 'none');
    end

    xLabel = options.XLabel;
    if strlength(xLabel) == 0
        if isfield(dataStruct, 'xlabel') && ...
                (ischar(dataStruct.xlabel) || isstring(dataStruct.xlabel))
            xLabel = string(dataStruct.xlabel);
            if ~strcmpi(unit, "Hz")
                xLabel = "frequency (" + unit + ")";
            end
        else
            xLabel = "frequency (" + unit + ")";
        end
    end

    yLabel = options.YLabel;
    if strlength(yLabel) == 0
        if isfield(dataStruct, 'ylabel') && ...
                (ischar(dataStruct.ylabel) || isstring(dataStruct.ylabel)) && ...
                strlength(string(dataStruct.ylabel)) > 0
            yLabel = string(dataStruct.ylabel);
        else
            yLabel = "power (dBm)";
        end
    end

    xlabel(ax, xLabel, 'Interpreter', 'none');
    ylabel(ax, yLabel, 'Interpreter', 'none');
    if strlength(options.Title) > 0
        title(ax, options.Title, 'Interpreter', 'none');
    end

    set(ax, 'FontName', 'Helvetica', 'FontSize', 22, ...
        'LineWidth', 2, 'Box', 'on', 'Layer', 'top', ...
        'Color', 'none', 'XColor', [0.15 0.15 0.15], ...
        'YColor', [0.15 0.15 0.15], ...
        'GridColor', [0.15 0.15 0.15], 'GridAlpha', 0.15);
    grid(ax, onOff(options.ShowGrid));

    xlim(ax, displayXLimits);
    ylim(ax, displayYLimits);

    % Match the sparse horizontal grid of the supplied JPEG for wide dB
    % ranges. Narrow noise measurements retain MATLAB's useful auto ticks.
    if isempty(options.YLimits) && diff(displayYLimits) >= 50
        firstTick = ceil(displayYLimits(1) / 50) * 50;
        lastTick = floor(displayYLimits(2) / 50) * 50;
        ticks = firstTick:50:lastTick;
        if numel(ticks) >= 2
            yticks(ax, ticks);
        end
    end
end

function range = finiteRange(values)
    range = [min(values), max(values)];
    if range(1) == range(2)
        padding = max(1, abs(range(1)) * 0.01);
        range = range + [-padding padding];
    end
end

function validateLimits(value, optionName)
    if ~isnumeric(value) || ~isreal(value) || numel(value) ~= 2 || ...
            any(~isfinite(value)) || value(1) >= value(2)
        error('plotDataStruct:InvalidLimits', ...
            '%s must be a finite, increasing two-element vector.', optionName);
    end
end

function [scale, unit] = frequencyScale(x, requestedUnit)
    units = ["Hz", "kHz", "MHz", "GHz"];
    scales = [1, 1e3, 1e6, 1e9];
    if strcmpi(requestedUnit, "auto")
        reference = max(abs(x));
        index = find(reference >= scales, 1, 'last');
        if isempty(index), index = 1; end
    else
        index = find(strcmpi(requestedUnit, units), 1);
        if isempty(index)
            error('plotDataStruct:InvalidFrequencyUnit', ...
                'FrequencyUnit must be Hz, kHz, MHz, GHz, or auto.');
        end
    end
    scale = scales(index);
    unit = units(index);
end

function value = onOff(tf)
    if tf
        value = 'on';
    else
        value = 'off';
    end
end
