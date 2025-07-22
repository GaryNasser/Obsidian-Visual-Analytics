function createDualYAxisChart(data1, data2, chartParams, visualParams)
% createDualYAxisChart - Creates a generic dual Y-axis combination chart
% with a smart label collision avoidance feature.
%
% Inputs:
%   data1, data2 - 1D numerical vectors for left and right Y-axes.
%   chartParams  - Struct with chart-specific parameters.
%   visualParams - Struct with general visualization parameters.

% --- Data Preparation ---
numDays = length(data1);
x_values = 1:numDays;
data1(data1 == 0) = NaN; % Treat 0 as missing data
data2(data2 == 0) = NaN;

% Set default optional parameters if not provided
if ~isfield(chartParams, 'markerLeft'), chartParams.markerLeft = 'o'; end
if ~isfield(chartParams, 'markerRight'), chartParams.markerRight = 's'; end
if ~isfield(chartParams, 'showAvgLeft'), chartParams.showAvgLeft = false; end
if ~isfield(chartParams, 'showAvgRight'), chartParams.showAvgRight = false; end

% --- Plotting ---
figure('Position', visualParams.wide16x9Size);
hold on;
set(0, 'DefaultAxesFontName', visualParams.fontName);
set(0, 'DefaultTextFontName', visualParams.fontName);

% --- Plot Left Y-Axis Data ---
yyaxis left;
ax1 = gca;
y1_max = max(data1, [], 'omitnan'); if isempty(y1_max), y1_max = 1; end

plot(x_values, data1, '-', 'LineWidth', 2.5, 'Color', chartParams.lineColorLeft);
scatter(x_values, data1, 80, chartParams.markerLeft, 'filled', ...
    'MarkerFaceColor', chartParams.lineColorLeft, 'MarkerEdgeColor', 'w', 'LineWidth', 1.5);
ylabel(chartParams.yLabelLeft, 'FontSize', visualParams.labelFontSize);
set(ax1, 'YColor', chartParams.lineColorLeft, 'FontSize', visualParams.axisFontSize, 'YLim', [0, y1_max * 1.25]);

% --- Plot Right Y-Axis Data ---
yyaxis right;
ax2 = gca;
y2_max = max(data2, [], 'omitnan'); if isempty(y2_max), y2_max = 1; end

plot(x_values, data2, '-', 'LineWidth', 2.5, 'Color', chartParams.lineColorRight);
scatter(x_values, data2, 70, chartParams.markerRight, 'filled', ...
    'MarkerFaceColor', chartParams.lineColorRight, 'MarkerEdgeColor', 'w', 'LineWidth',1.5);
ylabel(chartParams.yLabelRight, 'FontSize', visualParams.labelFontSize);
set(ax2, 'YColor', chartParams.lineColorRight, 'FontSize', visualParams.axisFontSize, 'YLim', [0, y2_max * 1.4]);

% --- CORE MODIFICATION: Smart Label Collision Avoidance ---
% Define a "low-value zone" threshold (e.g., bottom 15% of the axis)
proximity_threshold_1 = y1_max * 0.15;
proximity_threshold_2 = y2_max * 0.15;

% Add labels for the left axis data points
yyaxis left;
for i = 1:numDays
    if ~isnan(data1(i))
        text(i, data1(i) + (y1_max * 0.03), num2str(data1(i), '%.1f'), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
            'FontSize', visualParams.axisFontSize-1, 'FontWeight', 'bold', 'Color', 'k');
    end
end

% Add labels for the right axis data points (with avoidance logic)
yyaxis right;
for i = 1:numDays
    if ~isnan(data2(i))
        vertical_alignment = 'bottom'; % Default: label above point
        y_offset_multiplier = 1; % Default: shift upwards
        
        % Check if both data points are in the "low-value zone"
        if data1(i) <= proximity_threshold_1 && data2(i) <= proximity_threshold_2
            % If so, flip the right-axis label to be below the point to avoid overlap
            vertical_alignment = 'top';
            y_offset_multiplier = -1; % Shift downwards
        end
        
        text(i, data2(i) + (y2_max * 0.05 * y_offset_multiplier), num2str(data2(i), '%.1f'), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', vertical_alignment, ...
            'FontSize', visualParams.axisFontSize-1, 'FontWeight', 'bold', 'Color', 'k');
    end
end

% --- Plot Average Lines ---
if chartParams.showAvgLeft && ~all(isnan(data1))
    yyaxis left;
    avg1 = mean(data1, 'omitnan');
    plot(ax1, [x_values(1), x_values(end)], [avg1, avg1], '--', 'LineWidth', 1.8, 'Color', chartParams.lineColorLeft);
    text(ax1, x_values(1)-0.3, avg1, sprintf('Avg: %.1f', avg1), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'Color', chartParams.lineColorLeft, 'FontSize', visualParams.axisFontSize - 1, 'FontWeight', 'bold');
end

if chartParams.showAvgRight && ~all(isnan(data2))
    yyaxis right;
    avg2 = mean(data2, 'omitnan');
    plot(ax2, [x_values(1), x_values(end)], [avg2, avg2], '--', 'LineWidth', 1.8, 'Color', chartParams.lineColorRight);
    text(ax2, x_values(end)+0.3, avg2, sprintf('Avg: %.1f', avg2), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'Color', chartParams.lineColorRight, 'FontSize', visualParams.axisFontSize - 1, 'FontWeight', 'bold');
end

% --- Global and Shared Axis Properties ---
sgtitle(chartParams.title, 'FontSize', visualParams.titleFontSize, 'FontWeight', 'bold');
yyaxis left;
set(ax1, 'XTick', x_values, 'XTickLabel', visualParams.dateLabels(1:numDays), 'XLim', [0.5 numDays + 0.5]);
set(ax2, 'XTick', [], 'XTickLabel', [], 'XLim', [0.5 numDays + 0.5]);
xlabel('Date', 'FontSize', visualParams.labelFontSize, 'FontWeight', 'normal');
grid on;
box on;
hold off;

% --- Save Chart ---
if isfield(chartParams, 'saveName') && ~isempty(chartParams.saveName), print(gcf, chartParams.saveName, '-dpng', '-r300'); fprintf('Chart saved as: %s.png\n', chartParams.saveName); end

end
