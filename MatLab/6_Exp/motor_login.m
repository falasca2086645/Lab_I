function motor = motor_login(ip_address)
%MOTOR_LOGIN Connects to the motor controller.
%
%   motor = motor_login(ip_address)
%
%   Example:
%       pippo = motor_login("192.168.0.41");

    %% ============================================================
    %  INPUT CHECK
    %  ============================================================

    if nargin ~= 1
        error("The function requires one input: ip_address.");
    end

    if isstring(ip_address)
        ip_address = char(ip_address);
    end

    if ~ischar(ip_address)
        error("ip_address must be a string or a character vector.");
    end

    %% ============================================================
    %  MOTOR CONFIGURATION
    %  ============================================================

    motor = struct();

    motor.ipAddr              = ip_address;
    motor.port                = 23;
    motor.password            = "ipses";

    % Fixed motor geometry
    motor.ShaftDiameter       = 12.0;   % mm
    motor.StepsPerRevolution  = 400;

    % TCP object
    motor.tc                  = [];

    %% ============================================================
    %  MOTOR CONNECTION
    %  ============================================================

    fprintf('\n============================================================\n');
    fprintf(' MOTOR LOGIN\n');
    fprintf('============================================================\n');
    fprintf('Motor IP              : %s\n', motor.ipAddr);
    fprintf('Motor port            : %d\n', motor.port);
    fprintf('Shaft diameter        : %.3f mm\n', motor.ShaftDiameter);
    fprintf('Steps per revolution  : %d\n', motor.StepsPerRevolution);
    fprintf('============================================================\n\n');

    try
        fprintf('Connecting to motor...\n');

        motor.tc = tcpclient(motor.ipAddr, motor.port, 'Timeout', 5);

        pause(0.2);

        % Clear possible initial message from the controller
        nBytes = getBytesAvailable(motor.tc);

        if nBytes > 0
            read(motor.tc, nBytes, 'uint8');
        end

        % Send password
        motorSendCommand(motor, motor.password);

        fprintf('Motor connected and authenticated.\n');

    catch ME
        warning(ME.identifier, 'Motor login failed: %s', ME.message);
        rethrow(ME);
    end

end


%% ========================================================================
%  SEND MOTOR COMMAND
%  ========================================================================

function out = motorSendCommand(motor, cmd, timeout)
%MOTORSENDCOMMAND Sends a command to the motor controller and reads the reply.

    if nargin < 3
        timeout = 1.0;
    end

    write(motor.tc, uint8([char(cmd) 13 10]));

    t0 = tic;
    out = '';

    while toc(t0) < timeout
        pause(0.05);

        nBytes = getBytesAvailable(motor.tc);

        if nBytes > 0
            raw = char(read(motor.tc, nBytes, 'uint8'));

            % Keep printable ASCII characters only
            raw = raw(double(raw) >= 32 & double(raw) <= 126);

            out = strtrim(raw);
            return;
        end
    end

end


%% ========================================================================
%  GET BYTES AVAILABLE
%  ========================================================================

function nBytes = getBytesAvailable(tcpObj)
%GETBYTESAVAILABLE Returns the number of bytes available in the TCP buffer.

    if isprop(tcpObj, 'NumBytesAvailable')
        nBytes = tcpObj.NumBytesAvailable;

    elseif isprop(tcpObj, 'BytesAvailable')
        nBytes = tcpObj.BytesAvailable;

    else
        nBytes = 0;
    end

end