function fig = openFigSafe(filename)
%OPENFIGSAFE Open a trusted FIG file and normalize its display properties.
%   FIG = openFigSafe(FILENAME) loads a FIG invisibly, moves it onto the
%   current screen, enables graphics smoothing, and then displays it.
%   Use this only with trusted FIG files: opening a FIG can execute code.

    arguments
        filename (1,1) string
    end
    if ~isfile(filename)
        error('openFigSafe:FileNotFound', 'File not found: %s', filename);
    end
    [~, ~, extension] = fileparts(filename);
    if ~strcmpi(extension, '.fig')
        error('openFigSafe:NotFig', 'The selected file must have extension .fig.');
    end

    fig = openfig(filename, 'new', 'invisible');
    cleanup = onCleanup(@() closeIfInvalid(fig));

    set(fig, 'GraphicsSmoothing', 'on', 'Color', 'white');
    movegui(fig, 'onscreen');
    axesHandles = findall(fig, 'Type', 'axes');
    for k = 1:numel(axesHandles)
        set(axesHandles(k), 'Layer', 'top', 'FontName', 'DejaVu Sans', ...
            'Color', 'white', 'XColor', [0.15 0.15 0.15], ...
            'YColor', [0.15 0.15 0.15], ...
            'GridColor', [0.15 0.15 0.15], 'GridAlpha', 0.15);
        lines = findall(axesHandles(k), 'Type', 'line');
        for n = 1:numel(lines)
            set(lines(n), 'LineStyle', 'none', ...
                'Marker', '.', 'MarkerSize', 6);
        end
    end
    set(fig, 'Visible', 'on');
    drawnow;
    clear cleanup
end

function closeIfInvalid(fig)
    % Close only when an error interrupts normalization before visibility.
    if isgraphics(fig) && strcmp(fig.Visible, 'off')
        close(fig);
    end
end
