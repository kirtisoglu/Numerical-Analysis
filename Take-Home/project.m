% Define the system of ODEs
dydt = @(t, y) [-2*y(1) + y(2) + 2; -1.999*y(1) + 0.999*y(2) + 0.999*(sin(t) - cos(t))];

% Exact solutions
exact_sol = @(t) [exp(-t) + exp(-0.001*t) + sin(t); exp(-t) + 1.999*exp(-0.001*t) + cos(t)];

% Initial conditions
y0 = [2; 3.999];

% Time interval
tspan = [0, 5];

% Time steps to test
h_values = [0.1, 0.05, 0.025, 0.01];

% Adams-Bashforth 2-step method
for i = 1:length(h_values)
    h = h_values(i);
    t = 0:h:5;
    y = zeros(length(t), 2);
    y(1, :) = y0;

    % Use Euler's method for the first step
    y(2, :) = y(1, :) + h * dydt(t(1), y(1, :)')';

    % Adams-Bashforth 2-step method
    for j = 2:length(t)-1
        y(j+1, :) = y(j, :) + (h/2) * (3*dydt(t(j), y(j, :)') - dydt(t(j-1), y(j-1, :)'))';
    end

    % Calculate exact solution
    exact = zeros(length(t), 2);
    for k = 1:length(t)
        exact(k, :) = exact_sol(t(k))';
    end

    % Calculate error
    error_AB = abs(y - exact) ./ abs(exact);

    % Check if error at t = 5 is less than 0.01%
    if error_AB(end, 1) < 0.0001 && error_AB(end, 2) < 0.0001
        fprintf('Adams-Bashforth method: h = %f is sufficient\n', h);
        break;
    end
end

% Trapezoidal rule
for i = 1:length(h_values)
    h = h_values(i);
    t = 0:h:5;
    y = zeros(length(t), 2);
    y(1, :) = y0;

    % Trapezoidal rule
    for j = 1:length(t)-1
        k1 = dydt(t(j), y(j, :)')';
        k2 = dydt(t(j+1), y(j, :)' + h*k1)';
        y(j+1, :) = y(j, :) + (h/2) * (k1 + k2);
    end

    % Calculate exact solution
    exact = zeros(length(t), 2);
    for k = 1:length(t)
        exact(k, :) = exact_sol(t(k))';
    end

    % Calculate error
    error_TR = abs(y - exact) ./ abs(exact);

    % Check if error at t = 5 is less than 0.01%
    if error_TR(end, 1) < 0.0001 && error_TR(end, 2) < 0.0001
        fprintf('Trapezoidal rule: h = %f is sufficient\n', h);
        break;
    end
end

% Plot solutions and errors
figure;
subplot(2, 1, 1);
plot(t, y, '--', t, exact, '-');
legend('y_1 (AB)', 'y_2 (AB)', 'y_1 (Exact)', 'y_2 (Exact)');
title('Solutions using Adams-Bashforth method');
xlabel('Time');
ylabel('Solution');

subplot(2, 1, 2);
plot(t, error_AB);
title('Error using Adams-Bashforth method');
xlabel('Time');
ylabel('Relative Error');

figure;
subplot(2, 1, 1);
plot(t, y, '--', t, exact, '-');
legend('y_1 (TR)', 'y_2 (TR)', 'y_1 (Exact)', 'y_2 (Exact)');
title('Solutions using Trapezoidal rule');
xlabel('Time');
ylabel('Solution');

subplot(2, 1, 2);
plot(t, error_TR);
title('Error using Trapezoidal rule');
xlabel('Time');
ylabel('Relative Error');


fprintf('Adams-Bashforth method: h = %f is sufficient\n', h);
fprintf('Trapezoidal rule: h = %f is sufficient\n', h);