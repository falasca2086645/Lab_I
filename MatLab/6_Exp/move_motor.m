function dataStruct = move_motor(motor, user_length_mm, user_time_s, rotation, enable_movement)
%MOVE_MOTOR Calculates and optionally performs a motor movement.
%
%   dataStruct = move_motor(motor, user_length_mm, user_time_s, rotation, enable_movement)
%
%   INPUTS:
%       motor            : motor object/struct created by motor_login
%       user_length_mm   : requested movement length [mm]
%       user_time_s      : requested movement time [s]
%       rotation         : "clock" or "anticlock"
%       enable_movement  : true or false
%
%   OUTPUT:
%       dataStruct       : structure containing user and effective movement data

    %% INPUT CHECK

    if nargin ~= 5
        error("The function requires five inputs: motor, user_length_mm, user_time_s, rotation, enable_movement.");
    end

    if isempty(motor) || ~isstruct(motor)
        error("The input motor is not valid.");
    end

    if ~isfield(motor, 'ShaftDiameter')
        error("The motor struct must contain the field ShaftDiameter.");
    end

    if ~isfield(motor, 'StepsPerRevolution')
        error("The motor struct must contain the field StepsPerRevolution.");
    end

    if user_length_mm <= 0
        error("user_length_mm must be greater than zero.");
    end

    if user_time_s <= 0
        error("user_time_s must be greater than zero.");
    end

    if isstring(rotation)
        rotation = char(rotation);
    end

    if ~ischar(rotation)
        error("rotation must be either 'clock' or 'anticlock'.");
    end

    rotation = lower(strtrim(rotation));

    if ~strcmp(rotation, 'clock') && ~strcmp(rotation, 'anticlock')
        error("rotation must be either 'clock' or 'anticlock'.");
    end

    if ~islogical(enable_movement)
        error("enable_movement must be true or false.");
    end

    %% MOVEMENT PARAMETER CALCULATION

    shaft_circumference_mm = pi * motor.ShaftDiameter;

    step_length_mm = shaft_circumference_mm / motor.StepsPerRevolution;

    steps = round(user_length_mm / step_length_mm);

    if steps == 0
        error("The requested movement is too small and gives zero motor steps.");
    end

    step_time_ms = round((user_time_s * 1000) / steps);

    if step_time_ms <= 0
        error("The calculated step time is zero. Increase user_time_s.");
    end

    effective_length_mm = steps * step_length_mm;

    effective_time_s = steps * step_time_ms / 1000;

    user_velocity = user_length_mm / user_time_s;

    effective_velocity = effective_length_mm / effective_time_s;

    %% MOTOR COMMAND SIGN

    if strcmp(rotation, 'clock')
        measurement_signed_steps = steps;
    else
        measurement_signed_steps = -steps;
    end

    motor_command_steps = -measurement_signed_steps;

    %% CREATE DATA STRUCT

    dataStruct = struct();

    dataStruct.user_length_mm       = user_length_mm;
    dataStruct.user_time_s          = user_time_s;
    dataStruct.user_velocity        = user_velocity;
    dataStruct.rotation             = rotation;

    dataStruct.steps                = steps;
    dataStruct.step_time_ms         = step_time_ms;
    dataStruct.step_length_mm       = step_length_mm;
    dataStruct.effective_length_mm  = effective_length_mm;
    dataStruct.effective_time_s     = effective_time_s;
    dataStruct.effective_velocity   = effective_velocity;

    %% PRINT DATA STRUCT INFORMATION

    fprintf('\n============================================================\n');
    fprintf(' MOTOR MOVEMENT DATA\n');
    fprintf('============================================================\n');
    fprintf('User length              : %.6f mm\n', dataStruct.user_length_mm);
    fprintf('User time                : %.6f s\n', dataStruct.user_time_s);
    fprintf('User velocity            : %.9g mm/s\n', dataStruct.user_velocity);
    fprintf('Rotation                 : %s\n', dataStruct.rotation);
    fprintf('------------------------------------------------------------\n');
    fprintf('Steps                    : %d\n', dataStruct.steps);
    fprintf('Step time                : %d ms\n', dataStruct.step_time_ms);
    fprintf('Step length              : %.9f mm\n', dataStruct.step_length_mm);
    fprintf('Effective length         : %.9f mm\n', dataStruct.effective_length_mm);
    fprintf('Effective time           : %.6f s\n', dataStruct.effective_time_s);
    fprintf('Effective velocity       : %.9g mm/s\n', dataStruct.effective_velocity);
    fprintf('------------------------------------------------------------\n');
    fprintf('Movement enabled         : %d\n', enable_movement);
    fprintf('Motor command steps      : %d\n', motor_command_steps);
    fprintf('============================================================\n\n');

    %% OPTIONAL MOTOR MOVEMENT

    if enable_movement

        tcpObj = getMotorTcpObject(motor);

        if isempty(tcpObj)
            error("The motor connection is not available. Run motor_login first.");
        end

        try
            fprintf('Starting motor movement...\n');

            motorMoveRelative(motor, motor_command_steps, step_time_ms);

            fprintf('Motor movement completed.\n');

        catch ME
            warning(ME.identifier, 'Motor movement failed: %s', ME.message);
            rethrow(ME);
        end

    else
        fprintf('Motor movement disabled. Data struct created only.\n');
    end

end


%% RELATIVE MOTOR MOVEMENT

function motorMoveRelative(motor, motor_command_steps, stepTime_ms)

    motorSendCommand(motor, 'fx0');

    motorSendCommand(motor, 'i1,1');

    motorSendCommand(motor, sprintf('sx%d', stepTime_ms));

    motorSendCommand(motor, sprintf('d%d,0', motor_command_steps));

    pause((abs(motor_command_steps) * stepTime_ms / 1000) + 0.5);

end


%% SEND MOTOR COMMAND

function out = motorSendCommand(motor, cmd, timeout)

    if nargin < 3
        timeout = 1.0;
    end

    tcpObj = getMotorTcpObject(motor);

    if isempty(tcpObj)
        error("The motor TCP connection is empty.");
    end

    write(tcpObj, uint8([char(cmd) 13 10]));

    t0 = tic;
    out = '';

    while toc(t0) < timeout
        pause(0.05);

        nBytes = getBytesAvailable(tcpObj);

        if nBytes > 0
            raw = char(read(tcpObj, nBytes, 'uint8'));

            raw = raw(double(raw) >= 32 & double(raw) <= 126);

            out = strtrim(raw);
            return;
        end
    end

end


%% GET MOTOR TCP OBJECT

function tcpObj = getMotorTcpObject(motor)

    tcpObj = [];

    if isfield(motor, 'tc') && ~isempty(motor.tc)
        tcpObj = motor.tc;
        return;
    end

    if isfield(motor, 'tcp') && ~isempty(motor.tcp)
        tcpObj = motor.tcp;
        return;
    end

end


%% GET BYTES AVAILABLE

function nBytes = getBytesAvailable(tcpObj)

    if isprop(tcpObj, 'NumBytesAvailable')
        nBytes = tcpObj.NumBytesAvailable;

    elseif isprop(tcpObj, 'BytesAvailable')
        nBytes = tcpObj.BytesAvailable;

    else
        nBytes = 0;
    end

end