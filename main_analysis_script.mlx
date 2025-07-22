%% Personal Data Analysis & Visualization Main Script
%
% This script serves as the main entry point for the analysis.
% It defines global configurations, calls the data extraction function,
% prepares the data, and then uses various plotting functions to
% generate visualizations.

clc;
clear;
close all;

%% 1. Global Configuration
% -------------------------------------------------------------------------
% --- REQUIRED: PLEASE MODIFY THESE VALUES ---
obsidianFolder = 'C:\Users\YourUser\Documents\Obsidian\DailyNotes'; % <-- IMPORTANT: Change this to the path of your notes folder.

% Define the primary analysis period (e.g., a 7-day week).
startDate = '2025-07-07';
endDate = '2025-07-13'; 

% --- CORE LOGIC: Date Range Extension for Sleep Analysis ---
% To correctly plot a sleep cycle (e.g., Monday's sleep-in to Tuesday's wake-up),
% we need to fetch data starting from the day *before* the main analysis period.
startDateForSleep = datestr(datetime(startDate) - days(1), 'yyyy-mm-dd');

% General visualization parameters
visualParams.fontName = 'Arial'; % Use a common font like Arial, Helvetica, etc.
visualParams.titleFontSize = 13;
visualParams.labelFontSize = 14;
visualParams.axisFontSize = 11;
visualParams.wide16x9Size = [100 100 1280 720]; % Figure position and size [left, bottom, width, height]

%% 2. Data Extraction
% -------------------------------------------------------------------------
% Fetch data using the extended date range to ensure all required sleep data is available.
fprintf('Fetching data from %s to %s for full analysis...\n', startDateForSleep, endDate);
results_full = analyzeObsidianNotes(startDateForSleep, endDate, obsidianFolder);

% Check if sufficient data was loaded
if isempty(results_full) || height(results_full) < 2
    disp('Insufficient data for analysis. Program terminated. At least 2 consecutive days of data are required.');
    return;
end

%% 3. Data Distribution & Plotting Preparation
% -------------------------------------------------------------------------
% For all non-sleep charts, we only need the data from the primary analysis period.
% This subset is created by removing the first day's data from the full dataset.
results_primary = results_full(2:end, :);
numPrimaryDays = height(results_primary);

% Generate generic date labels for the X-axis based on the primary period
weekdayLabels = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
dateLabels = cell(numPrimaryDays, 1);
for i = 1:numPrimaryDays
    weekNum = floor((i-1) / 7) + 1;
    dayIdx = mod(i-1, 7) + 1;
    if weekNum > 1
        dateLabels{i} = [weekdayLabels{dayIdx} ' (W' num2str(weekNum) ')'];
    else
        dateLabels{i} = weekdayLabels{dayIdx};
    end
end
visualParams.dateLabels = dateLabels;

%% 4. Call Generic Functions for Visualization
% -------------------------------------------------------------------------

% --- Sleep Chart: Uses the FULL dataset to plot N-1 sleep cycles ---
sleepParams.title = 'Weekly Sleep Pattern Analysis (Sleep-In to Wake-Up)';
sleepParams.sleepInVar = 'sleep-in';
sleepParams.wakeUpVar = 'wake-up';
sleepParams.sleepBarColor = [0.4 0.4 0.8]; % A nice blue for sleep
sleepParams.saveName = 'sleep_pattern_analysis';
plotSleepPattern(results_full, visualParams, sleepParams); % <-- Pass the full dataset

% --- All other charts: Use the PRIMARY dataset ---

% --- Working Outside Duration Chart ---
woParams.title = 'Weekly "Working Outside" Duration Trend';
woParams.ylabel = 'Duration (hours)';
woParams.lineColor = 'b'; % Blue
woParams.saveName = 'working_outside_analysis';
woParams.showAverageLine = true;
createSingleLineChart(results_primary.Working_Outside, woParams, visualParams); % <-- Pass the primary dataset

% --- Sport & Meditation Comparison Chart ---
smParams.title = 'Sport & Meditation Analysis';
smParams.yLabelLeft = 'Running Distance (meters)';
smParams.yLabelRight = 'Meditation Time (minutes)';
smParams.lineColorLeft = [0.8, 0.3, 0.3];  % Reddish for sport
smParams.lineColorRight = [0.3, 0.7, 0.8]; % Teal for meditation
smParams.showAvgLeft = true;
smParams.showAvgRight = true;
smParams.saveName = 'sport_meditation_analysis';
createDualYAxisChart(results_primary.Running, results_primary.Meditation, smParams, visualParams); % <-- Pass the primary dataset

% --- Work & Entertainment Comparison Chart (Optional) ---
if ismember('Entertainment_Time', results_primary.Properties.VariableNames)
    workEntParams.title = 'Work vs. Quality Entertainment Time Analysis';
    workEntParams.yLabelLeft = 'Working Outside (hours)';
    workEntParams.yLabelRight = 'Entertainment Time (hours)';
    workEntParams.lineColorLeft = 'b'; % Blue for work
    workEntParams.lineColorRight = 'r'; % Red for entertainment
    workEntParams.saveName = 'work_entertainment_analysis';
    workEntParams.showAvgLeft = true;
    workEntParams.showAvgRight = true;
    createDualYAxisChart(results_primary.Working_Outside, results_primary.Entertainment_Time, workEntParams, visualParams);
else
    fprintf('\nInfo: "Entertainment_Time" variable not found. Skipping Work vs. Entertainment chart.\n');
end

fprintf('\nAll analysis and plotting tasks completed!\n');
