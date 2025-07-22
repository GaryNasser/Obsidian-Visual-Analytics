function plotSleepPattern(results, visualParams, sleepParams)
% plotSleepPattern - Visualizes sleep patterns using paired cross-day data.
%
% Inputs:
%   results - Table with sleep data, must contain 'sleep-in' and 'wake-up' variables.
%   visualParams - Struct with general visualization parameters.
%   sleepParams - Struct with sleep-chart specific parameters.

% Check for required variables in the input table
if ~ismember(sleepParams.sleepInVar, results.Properties.VariableNames) || ...
   ~ismember(sleepParams.wakeUpVar, results.Properties.VariableNames)
    error(['Results table must contain ''' sleepParams.sleepInVar ''' and ''' sleepParams.wakeUpVar ''' variables.']);
end

% --- CORE LOGIC: Pair sleep data across consecutive days ---
numDays = height(results);
if numDays < 2
    warning('Less than 2 days of data provided. Cannot form a complete sleep cycle.');
    return;
end
numSleepCycles = numDays - 1; % N days of data can form N-1 sleep cycles.

% Pair the sleep-in time of day 'i' with the wake-up time of day 'i+1'
sleepTimes = results.(sleepParams.sleepInVar)(1:numSleepCycles);
wakeupTimes = results.(sleepParams.wakeUpVar)(2:numDays);

sleepHours = NaN(numSleepCycles, 1);
wakeupHours = NaN(numSleepCycles, 1);

% --- Data Processing ---
% This mapping converts time to a numeric value where 22:00 is 0.
% Example: 22:00 -> 0, 00:00 -> 2, 06:00 -> 8, etc.
for i = 1:numSleepCycles
    % Parse sleep-in time (from day i)
    if ~isempty(sleepTimes{i})
        tokens = split(sleepTimes{i}, ':');
        if length(tokens) == 2
            hour = str2double(tokens{1}); minute = str2double(tokens{2});
            if hour >= 22, sleepHours(i) = hour - 22 + minute/60; else, sleepHours(i) = hour + 2 + minute/60; end
        end
    end
    
    % Parse wake-up time (from day i+1)
    if ~isempty(wakeupTimes{i})
        tokens = split(wakeupTimes{i}, ':');
        if length(tokens) == 2
            hour = str2double(tokens{1}); minute = str2double(tokens{2});
            if hour >= 22, wakeupHours(i) = hour - 22 + minute/60; else, wakeupHours(i) = hour + 2 + minute/60; end
        end
    end
    
    % Handle overnight logic: if wake-up hour is numerically smaller, add 12 (since our scale is ~12 hours from 22:00 to 10:00)
    if ~isnan(sleepHours(i)) && ~isnan(wakeupHours(i))
        if wakeupHours(i) < sleepHours(i), wakeupHours(i) = wakeupHours(i) + 12; end
    end
end

% --- Plotting ---
figure('Position', visualParams.wide16x9Size);
hold on;

set(0, 'DefaultAxesFontName', visualParams.fontName);
set(0, 'DefaultTextFontName', visualParams.fontName);
if isfield(sleepParams, 'title') && ~isempty(sleepParams.title)
    sgtitle(sleepParams.title, 'FontSize', visualParams.titleFontSize, 'FontWeight', 'bold');
end

% Draw rounded rectangle bars for each sleep duration
barWidth = 0.1; radius = barWidth / 2;
for i = 1:numSleepCycles
    if isnan(sleepHours(i)) || isnan(wakeupHours(i)), continue; end
    startTime = sleepHours(i); endTime = wakeupHours(i);
    
    % Draw rounded caps and the main rectangle body
    theta = linspace(pi, 2*pi, 100); xCircle = i + radius * cos(theta); yCircle = startTime + radius * sin(theta); fill(xCircle, yCircle, sleepParams.sleepBarColor, 'EdgeColor', 'none');
    theta = linspace(0, pi, 100); xCircle = i + radius * cos(theta); yCircle = endTime + radius * sin(theta); fill(xCircle, yCircle, sleepParams.sleepBarColor, 'EdgeColor', 'none');
    xRect = [i-radius, i+radius, i+radius, i-radius]; yRect = [startTime, startTime, endTime, endTime]; fill(xRect, yRect, sleepParams.sleepBarColor, 'EdgeColor', 'none');
    
    % Draw markers for exact sleep-in and wake-up times
    plot(i, startTime, 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.2 0.6], 'MarkerEdgeColor', [0.8 0.8 0.8], 'LineWidth', 1.5);
    plot(i, endTime, 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.2], 'MarkerEdgeColor', [0.8 0.8 0.8], 'LineWidth', 1.5);
end

% Set axis labels and properties
ylabel('Time', 'FontSize', visualParams.labelFontSize);
xlabel('Day of the Week (Day of falling asleep)', 'FontSize', visualParams.labelFontSize);

% Set X and Y axis ticks and labels
set(gca, ...
    'XTick', 1:numSleepCycles, 'XTickLabel', visualParams.dateLabels, ...
    'YTick', 0:2:12, 'YTickLabel', {'22:00', '00:00', '02:00', '04:00', '06:00', '08:00', '10:00'}, ...
    'FontSize', visualParams.axisFontSize, ...
    'YLim', [-0.5 12.5], 'XLim', [0.5 numSleepCycles + 0.5], ...
    'Box', 'on', 'GridAlpha', 0.3, 'Layer', 'top', 'YDir', 'reverse');
grid on;

% Add data labels (duration and exact times)
for i = 1:numSleepCycles
    if isnan(sleepHours(i)) || isnan(wakeupHours(i)), continue; end
    startTime = sleepHours(i); endTime = wakeupHours(i); duration = endTime - startTime;
    
    % Duration label
    text(i + radius + 0.05, startTime + duration/2, sprintf('%.1fh', duration), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'FontSize', visualParams.axisFontSize -1, 'FontWeight', 'bold', 'Color', 'k');
    
    % Exact time labels
    timeStrStart = convertNumericToTimeStr(startTime); 
    text(i + 0.05, startTime, timeStrStart, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'FontSize', visualParams.axisFontSize - 2, 'Color', 'k');
    timeStrEnd = convertNumericToTimeStr(endTime); 
    text(i + 0.05, endTime, timeStrEnd, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', visualParams.axisFontSize - 2, 'Color', 'k');
end

hold off;

if isfield(sleepParams, 'saveName') && ~isempty(sleepParams.saveName), print(gcf, sleepParams.saveName, '-dpng', '-r300'); fprintf('Sleep pattern chart saved as: %s.png\n', sleepParams.saveName); end
end

% --- Helper Function ---
function timeStr = convertNumericToTimeStr(numericTime)
    % Converts the internal numeric time back to a 'HH:MM' string for display.
    numericTime = mod(numericTime, 12); % Handle times that crossed the 12-hour boundary
    if numericTime < 2
        hours = floor(numericTime + 22); 
    else
        hours = floor(numericTime - 2); 
    end
    minutes = round(mod(numericTime, 1) * 60);
    timeStr = sprintf('%02d:%02d', hours, minutes);
end
