%% Calculate Atmospheric Properties Using K1, K2, and K3 (MATLAB Code)
clear; clc; close all;

%% Define Standard Constants
g     = 9.80665;      % Acceleration due to gravity (m/s^2)
R     = 287.05;       % Specific gas constant for air (J/(kg·K))
gamma = 1.4;          % Ratio of specific heats for air

T0    = 288.15;       % Sea level standard temperature (K)
p0    = 101325;       % Sea level standard pressure (Pa)

%% Get altitude input from the user (in meters)
h_input = getAltitude();

% Define temperature lapse rates for layers (in K/m)
K1 = 0.0065; % OR 0.0065  % Lapse rate for Layer 1 (0-11 km): T = T0 - K1*h
K2 = 0.0000; % OR 0.0     % Lapse rate for Layer 2 (11-25 km): 0 for isothermal layer (or set a value if needed)
K3 = getLapseRate(h_input); % OR 0.0028  % Lapse rate for Layer 3 (above 25 km): e.g., 2.8 K/km

%% Define altitude range for plotting (from sea level to h_input)
num_points = 500;
h_range = linspace(0, h_input, num_points);

% Preallocate arrays for Temperature, Pressure, Density, and Speed of Sound
T_range   = zeros(size(h_range));
p_range   = zeros(size(h_range));
rho_range = zeros(size(h_range));
a_range   = zeros(size(h_range));

%% Loop over altitude range and calculate atmospheric properties
for i = 1:length(h_range)
    h = h_range(i);

    if h < 11000
        % Layer 1: 0 to 11 km using K1
        T = T0 - K1 * h;
        p = p0 * (T / T0)^(g / (R * K1));

    elseif h < 25000
        % Layer 2: 11 km to 25 km using K2
        % First, compute conditions at 11 km from Layer 1:
        T1 = T0 - K1 * 11000;
        p1 = p0 * (T1 / T0)^(g / (R * K1)); 

        if K2 == 0
            % Isothermal layer: temperature remains constant
            T = T1;
            p = p1 * exp(-g * (h - 11000) / (R * T1));
        else
            % Non-isothermal layer: temperature changes linearly with rate K2
            T = T1 + K2 * (h - 11000);
            p = p1 * (T / T1)^(-g / (R * K2));
        end

    else
        % Layer 3: h >= 25000, using K3
        % First, compute conditions at 25 km from Layer 2:
        % Calculate conditions at 11 km as before:
        T1 = T0 - K1 * 11000;
        p1 = p0 * (T1 / T0)^(g / (R * K1));
        if K2 == 0
            T25 = T1;  % If layer 2 is isothermal
            p25 = p1 * exp(-g * (25000 - 11000) / (R * T1));
        else
            T25 = T1 + K2 * (25000 - 11000);
            p25 = p1 * (T25 / T1)^(-g / (R * K2));
        end

        if K3 == 0
            % Isothermal in Layer 3
            T = T25;
            p = p25 * exp(-g * (h - 25000) / (R * T25));
        else
            % Non-isothermal in Layer 3: temperature changes with rate K3
            T = T25 + K3 * (h - 25000);
            p = p25 * (T / T25)^(-g / (R * K3));
        end
    end
    

    % Calculate air density using the ideal gas law
    rho = p / (R * T);

    % Calculate speed of sound: a = sqrt(gamma * R * T)
    a = sqrt(gamma * R * T);

    % Store the results in the arrays
    T_range(i)   = T;
    p_range(i)   = p;
    rho_range(i) = rho;
    a_range(i)   = a;
end

%% Extract final results for the input altitude
T_input   = T_range(end);
p_input   = p_range(end);
rho_input = rho_range(end);
a_input   = a_range(end);

%% Display results in English in the Command Window
fprintf('\nResults for altitude %.2f m:\n', h_input);
fprintf('-------------------------------------------\n');
fprintf('Air Temperature: %.2f K\n', T_input);
fprintf('Air Pressure:    %.2f Pa\n', p_input);
fprintf('Air Density:     %.4f kg/m^3\n', rho_input);
fprintf('Speed of Sound:  %.2f m/s\n', a_input);
fprintf('-------------------------------------------\n\n');

%% Plot the results with altitude on the y-axis
figure;
tiledlayout(1, 4);  % Create a 1x2 layout for two plots

% 2x2 subplots for the four parameters

% Subplot 1: Air Pressure vs. Altitude
nexttile;  % Move to the second tile in the layout
plot(p_range, h_range, 'k', 'LineWidth', 2);
xlabel('Air Pressure (Pa)');
ylabel('Altitude (m)');
title('Air Pressure vs. Altitude');
grid on;

% Subplot 2: Air Density vs. Altitude
nexttile;  % Move to the second tile in the layout
plot(rho_range, h_range, 'r', 'LineWidth', 2);
xlabel('Air Density (kg/m^3)');
ylabel('Altitude (m)');
title('Air Density vs. Altitude');
grid on;

% Subplot 3: Air Temperature vs. Altitude
nexttile;  % Move to the second tile in the layout
plot(T_range, h_range, 'b', 'LineWidth', 2);
xlabel('Air Temperature (K)');
ylabel('Altitude (m)');
title('Air Temperature vs. Altitude');
grid on;

% Subplot 4: Speed of Sound vs. Altitude
nexttile;  % Move to the second tile in the layout
plot(a_range, h_range, 'm', 'LineWidth', 2);
xlabel('Speed of Sound (m/s)');
ylabel('Altitude (m)');
title('Speed of Sound vs. Altitude');
grid on;


function h_input = getAltitude()
    h_input = input('Enter altitude in meters (max 32000 m): ');
    if h_input < 0 || h_input > 32000
        fprintf('Invalid input! Please enter a value between 0 and 32000 meters.\n');
        h_input = getAltitude();
    end
end

function K = getLapseRate(h)
    alt_breaks = [0, 5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, ...
                  55000, 60000, 65000, 70000, 75000, 80000, 85000, 90000, 95000, 100000];
    
    % تعریف مقادیر K برای هر بلوک (مقدار تقریبی طبق مدل استاندارد یا فرضیات)
    % 0-5 km:       0.0065 K/m (کاهش دما)
    % 5-10 km:      0.0065 K/m
    % 10-15 km:     0 K/m (لایه ایزوترمال)
    % 15-20 km:     0 K/m
    % 20-25 km:     0.0010 K/m (افزایش دما)
    % 25-30 km:     0.0010 K/m
    % 30-35 km:     0.0028 K/m (افزایش بیشتر دما)
    % 35-40 km:     0.0028 K/m
    % 40-45 km:     0.0028 K/m
    % 45-50 km:     0 K/m (ایزوترمال)
    % 50-55 km:    -0.0028 K/m (کاهش دما)
    % 55-60 km:    -0.0028 K/m
    % 60-65 km:    -0.0028 K/m
    % 65-70 km:    -0.0020 K/m (کاهش دما کمتر)
    % 70-75 km:    -0.0020 K/m
    % 75-80 km:    -0.0020 K/m
    % 80-85 km:    -0.0020 K/m
    % 85-90 km:    -0.0020 K/m
    % 90-95 km:    -0.0020 K/m
    % 95-100 km:   -0.0020 K/m

    K_values = [0.0065, 0.0065, 0, 0, 0.0010, 0.0010, 0.0028, 0.0028, 0.0028, 0, ...
                -0.0028, -0.0028, -0.0028, -0.0020, -0.0020, -0.0020, -0.0020, -0.0020, -0.0020, -0.0020];

    if h >= alt_breaks(end)
        K = K_values(end);
    else
        idx = find(h >= alt_breaks, 1, 'last');
        K = K_values(idx);
    end
end
    