function motor_logout(motor)
%MOTOR_LOGOUT Closes the TCP connection to the motor controller and clears it.
%
%   motor_logout(motor)
%
%   INPUT:
%       motor : motor object/struct created by motor_login
%
%   EXAMPLE:
%       pippo = motor_login("192.168.0.41");
%       motor_logout(pippo);
%
%   After logout, the variable pippo is cleared from the base workspace.

    %% ============================================================
    %  INPUT CHECK
    %  ============================================================

    if nargin ~= 1
        error("The function requires one input: motor.");
    end

    if isempty(motor) || ~isstruct(motor)
        error("The input motor is not valid.");
    end

    motor_var_name = inputname(1);

    %% ============================================================
    %  GET TCP OBJECT
    %  ============================================================

    tcpObj = [];

    if isfield(motor, 'tc') && ~isempty(motor.tc)
        tcpObj = motor.tc;
    elseif isfield(motor, 'tcp') && ~isempty(motor.tcp)
        tcpObj = motor.tcp;
    else
        warning("No TCP connection found inside the motor structure.");
    end

    %% ============================================================
    %  CLOSE CONNECTION
    %  ============================================================

    try
        if ~isempty(tcpObj)
            clear tcpObj
        end

        fprintf('\n============================================================\n');
        fprintf(' MOTOR LOGOUT\n');
        fprintf('============================================================\n');

        if isfield(motor, 'ipAddr')
            fprintf('Motor IP              : %s\n', motor.ipAddr);
        elseif isfield(motor, 'ip_address')
            fprintf('Motor IP              : %s\n', motor.ip_address);
        end

        fprintf('Motor connection closed.\n');

        %% ========================================================
        %  CLEAR MOTOR VARIABLE FROM BASE WORKSPACE
        %  ========================================================

        if ~isempty(motor_var_name)
            evalin('base', ['clear ', motor_var_name]);
            fprintf('Variable cleared      : %s\n', motor_var_name);
        else
            fprintf('Variable cleared      : not available, input was not a named variable\n');
        end

        fprintf('============================================================\n\n');

    catch ME
        warning(ME.identifier, 'Motor logout failed: %s', ME.message);
        rethrow(ME);
    end

end