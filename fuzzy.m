% Create a new fuzzy inference system
fis = mamfis('Name', 'IntelligentAssistiveCare');

% Add inputs with their membership functions
fis = addInput(fis, [10 35], 'Name', 'Temperature');
fis = addMF(fis, 'Temperature', 'trapmf', [10 10 15 18], 'Name', 'VeryCold');
fis = addMF(fis, 'Temperature', 'trimf', [15 18 21], 'Name', 'Cold');
fis = addMF(fis, 'Temperature', 'trimf', [18 21 24], 'Name', 'Comfortable');
fis = addMF(fis, 'Temperature', 'trimf', [21 24 27], 'Name', 'Warm');
fis = addMF(fis, 'Temperature', 'trapmf', [24 27 35 35], 'Name', 'Hot');

fis = addInput(fis, [0 100], 'Name', 'Humidity');
fis = addMF(fis, 'Humidity', 'trapmf', [0 0 30 45], 'Name', 'Low');
fis = addMF(fis, 'Humidity', 'trimf', [30 50 70], 'Name', 'Medium');
fis = addMF(fis, 'Humidity', 'trapmf', [55 70 100 100], 'Name', 'High');

fis = addInput(fis, [0 100], 'Name', 'LightLevel');
fis = addMF(fis, 'LightLevel', 'trapmf', [0 0 20 40], 'Name', 'Dark');
fis = addMF(fis, 'LightLevel', 'trimf', [20 50 80], 'Name', 'Dim');
fis = addMF(fis, 'LightLevel', 'trapmf', [60 80 100 100], 'Name', 'Bright');

fis = addInput(fis, [0 24], 'Name', 'TimeOfDay');
fis = addMF(fis, 'TimeOfDay', 'trapmf', [0 0 5 7], 'Name', 'Night');
fis = addMF(fis, 'TimeOfDay', 'trimf', [5 12 17], 'Name', 'Day');
fis = addMF(fis, 'TimeOfDay', 'trapmf', [17 19 24 24], 'Name', 'Evening');

fis = addInput(fis, [0 10], 'Name', 'ActivityLevel');
fis = addMF(fis, 'ActivityLevel', 'trapmf', [0 0 2 4], 'Name', 'Low');
fis = addMF(fis, 'ActivityLevel', 'trimf', [2 5 8], 'Name', 'Medium');
fis = addMF(fis, 'ActivityLevel', 'trapmf', [6 8 10 10], 'Name', 'High');

% Add outputs with their membership functions
fis = addOutput(fis, [-2 2], 'Name', 'HVACControl');
fis = addMF(fis, 'HVACControl', 'trapmf', [-2 -2 -1.5 -1], 'Name', 'CoolStrongly');
fis = addMF(fis, 'HVACControl', 'trimf', [-1.5 -1 -0.5], 'Name', 'CoolMildly');
fis = addMF(fis, 'HVACControl', 'trimf', [-0.5 0 0.5], 'Name', 'Maintain');
fis = addMF(fis, 'HVACControl', 'trimf', [0.5 1 1.5], 'Name', 'HeatMildly');
fis = addMF(fis, 'HVACControl', 'trapmf', [1 1.5 2 2], 'Name', 'HeatStrongly');

fis = addOutput(fis, [0 1], 'Name', 'LightControl');
fis = addMF(fis, 'LightControl', 'trapmf', [0 0 0.2 0.4], 'Name', 'Off');
fis = addMF(fis, 'LightControl', 'trimf', [0.2 0.5 0.8], 'Name', 'Dim');
fis = addMF(fis, 'LightControl', 'trapmf', [0.6 0.8 1 1], 'Name', 'Bright');

fis = addOutput(fis, [0 1], 'Name', 'BlindControl');
fis = addMF(fis, 'BlindControl', 'trapmf', [0 0 0.2 0.4], 'Name', 'Closed');
fis = addMF(fis, 'BlindControl', 'trimf', [0.2 0.5 0.8], 'Name', 'PartiallyOpen');
fis = addMF(fis, 'BlindControl', 'trapmf', [0.6 0.8 1 1], 'Name', 'Open');

fis = addOutput(fis, [0 2], 'Name', 'PowerManagement');
fis = addMF(fis, 'PowerManagement', 'trapmf', [0 0 0.5 1], 'Name', 'Off');
fis = addMF(fis, 'PowerManagement', 'trimf', [0.5 1 1.5], 'Name', 'Standby');
fis = addMF(fis, 'PowerManagement', 'trapmf', [1 1.5 2 2], 'Name', 'On');

% Add rules
rules = [
    "Temperature==VeryCold => HVACControl=HeatStrongly"
    "Temperature==Cold & Humidity==Low => HVACControl=HeatMildly"
    "Temperature==Comfortable & Humidity==Medium => HVACControl=Maintain"
    "Temperature==Warm & Humidity==High => HVACControl=CoolMildly"
    "Temperature==Hot => HVACControl=CoolStrongly"
    "LightLevel==Dark & TimeOfDay==Night => LightControl=Off"
    "LightLevel==Dim & TimeOfDay==Evening => LightControl=Dim"
    "LightLevel==Bright & TimeOfDay==Day => LightControl=Bright"
    "ActivityLevel==Low & TimeOfDay==Night => PowerManagement=Off"
    "ActivityLevel==Medium & TimeOfDay==Day => PowerManagement=Standby"
    "ActivityLevel==High & TimeOfDay==Day => PowerManagement=On"
    "LightLevel==Bright => BlindControl=Closed"
    "LightLevel==Dim => BlindControl=PartiallyOpen"
    "LightLevel==Dark => BlindControl=Open"
];

fis = addRule(fis, rules);

% Sample input values
input = [22, 60, 50, 14, 5]; % [Temperature, Humidity, LightLevel, TimeOfDay, ActivityLevel]

% Evaluate the FIS
output = evalfis(fis, input);

% Display the result
disp(['HVAC Control Output: ', num2str(output(1))]);
disp(['Light Control Output: ', num2str(output(2))]);
disp(['Blind Control Output: ', num2str(output(3))]);
disp(['Power Management Output: ', num2str(output(4))]);

% Plot membership functions for Temperature
figure;
plotmf(fis, 'input', 1);
title('Temperature Membership Functions');

% Plot membership functions for Humidity
figure;
plotmf(fis, 'input', 2);
title('Humidity Membership Functions');

% Plot membership functions for Light Level
figure;
plotmf(fis, 'input', 3);
title('Light Level Membership Functions');

% Plot membership functions for Time of Day
figure;
plotmf(fis, 'input', 4);
title('Time of Day Membership Functions');

% Plot membership functions for Activity Level
figure;
plotmf(fis, 'input', 5);
title('Activity Level Membership Functions');

% Plot membership functions for HVAC Control
figure;
plotmf(fis, 'output', 1);
title('HVAC Control Membership Functions');

% Plot membership functions for Light Control
figure;
plotmf(fis, 'output', 2);
title('Light Control Membership Functions');

% Plot membership functions for Blind Control
figure;
plotmf(fis, 'output', 3);
title('Blind Control Membership Functions');

% Plot membership functions for Power Management
figure;
plotmf(fis, 'output', 4);
title('Power Management Membership Functions');

% Show the rule viewer
figure;
ruleview(fis);

% Show the surface viewer
figure;
gensurf(fis);

% Create a range of temperature and humidity values
temp_range = 10:0.5:35;
humidity_range = 0:2:100;

% Initialize output matrix
output_matrix = zeros(length(temp_range), length(humidity_range));

% Evaluate FIS for each combination of temperature and humidity
for i = 1:length(temp_range)
    for j = 1:length(humidity_range)
        input = [temp_range(i), humidity_range(j), 50, 12, 5]; % Fixed values for other inputs
        output = evalfis(fis, input);
        output_matrix(i,j) = output(1); % Extracting the HVACControl output
    end
end

% Plot control surface
figure;
surf(humidity_range, temp_range, output_matrix);
xlabel('Humidity (%)');
ylabel('Temperature (°C)');
zlabel('HVAC Control');
title('Control Surface: HVAC Control');
colorbar;

% Analyze specific scenarios
scenarios = [
    15, 30;  % Cold and dry
    22, 50;  % Comfortable
    28, 70;  % Warm and humid
];

figure;
for i = 1:size(scenarios, 1)
    input = [scenarios(i,1), scenarios(i,2), 50, 12, 5]; % Fixed values for other inputs
    
    subplot(size(scenarios, 1), 1, i);
    [output, mfGrades] = evalfis(fis, input, 'OutputFormat', 'Detailed');
    
    % Plot rule activation
    bar(mfGrades.rule);
    title(sprintf('Rule Activation (Temp: %.1f°C, Humidity: %.1f%%)', scenarios(i,1), scenarios(i,2)));
    xlabel('Rule Number');
    ylabel('Activation Level');
    ylim([0 1]);
    
    % Display HVAC control output
    text(0.5, 0.9, sprintf('HVAC Control: %.2f', output), 'Units', 'normalized', 'HorizontalAlignment', 'center');
end

% Analyze controller behavior over time
time = 0:23; % 24-hour period
temp_profile = 15 + 10 * sin((time - 6) * pi / 12); % Temperature profile
humidity_profile = 50 + 20 * sin((time - 3) * pi / 12); % Humidity profile

hvac_output = zeros(size(time));
for i = 1:length(time)
    input = [temp_profile(i), humidity_profile(i), 50, time(i), 5]; % Fixed values for other inputs
    hvac_output(i) = evalfis(fis, input);
end

figure;
subplot(2,1,1);
plot(time, temp_profile, 'r-', time, humidity_profile, 'b--');
xlabel('Time (hours)');
ylabel('Value');
legend('Temperature (°C)', 'Humidity (%)');
title('Temperature and Humidity Profile over 24 hours');

subplot(2,1,2);
plot(time, hvac_output, 'g-');
xlabel('Time (hours)');
ylabel('HVAC Control');
title('HVAC Control Output over 24 hours');
ylim([-2 2]);
