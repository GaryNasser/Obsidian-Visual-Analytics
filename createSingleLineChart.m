function createSingleLineChart(data, chartParams, visualParams)
% createSingleLineChart - Creates a generic single line chart with a smoothed 
% curve, data points, and an optional average line.
%
% Inputs:
%   data         - 1D numerical vector to be plotted.
%   chartParams  - Struct with chart-specific parameters:
%                  .title          - Chart title.
%                  .ylabel         - Y-axis label.
%                  .lineColor      - Color for the line and markers.
%                  .saveName       - Filename for saving the chart.
%                  .showAverageLine- (Optional) Boolean to show average line.
%   visualParams - Struct with general visualization parameters.

% --- Data Preparation ---
numDays = length(data);
x_values = 1:numDays;
data(data == 0) = NaN; % Treat 0 as missing data for cleaner plotting

% Check for optional parameter, set default if not present
if ~isfield(chartParams, 'showAverageLine'), chartParams.showAverageLine = false; end

% --- Plotting ---
figure('Position', visualParams.wide16x9Size);
hold on;
set(0, 'DefaultAxesFontName', visualParams.fontName);
set(0, 'DefaultTextFontName', visualParams.fontName);

% 1. Plot the smoothed curve
x_smooth = linspace(x_values(1), x_values(end), 200);
y_smooth = interp1(x_values, data, x_smooth, 'pchip'); % pchip for shape-preserving interpolation
plot(x_smooth, y_smooth, '-', 'LineWidth', 2.5, 'Color', chartParams.lineColor);

% 2. Plot the original data points
scatter(x_values, data, 80, 'o', 'filled', ...
    'MarkerFaceColor', chartParams.lineColor, ...
    'MarkerEdgeColor', 'w', 'LineWidth', 1.5, 'MarkerFaceAlpha', 0.8);

% 3. Plot the average value reference line
if chartParams.showAverageLine && ~all(isnan(data))
    avgValue = mean(data, 'omitnan'); % Use 'omitnan' for robustness
    yline(avgValue, '--', 'LineWidth', 1.8, 'Color', [0.5 0.5 0.5]);
    
    % Add a label for the average line on the left side
    text(x_values(1) - 0.3, avgValue, sprintf('Avg: %.1f', avgValue), ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'middle', ...
        'Color', 'k', ...
        'FontSize', visualParams.axisFontSize, ...
        'FontWeight', 'bold');
end

% 4. Set titles and labels
sgtitle(chartParams.title, 'FontSize', visualParams.titleFontSize, 'FontWeight', 'bold');
xlabel('Date', 'FontSize', visualParams.labelFontSize);
ylabel(chartParams.ylabel, 'FontSize', visualParams.labelFontSize);

% 5. Configure axes details
y_max = max(data, [], 'omitnan'); if isempty(y_max), y_max = 1; end
y_padding = y_max * 0.05;
set(gca, ...
    'XTick', x_values, ...
    'XTickLabel', visualParams.dateLabels(1:numDays), ...
    'FontSize', visualParams.axisFontSize, ...
    'XLim', [0.5 numDays + 0.5], ...
    'YLim', [0, y_max * 1.25], ... % Start Y-axis at 0
    'Box', 'on', ...
    'GridAlpha', 0.3);
grid on;

% 6. Add data point labels
for i = 1:numDays
    if ~isnan(data(i))
        text(i, data(i), sprintf(' %.1f', data(i)), ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
            'FontSize', visualParams.axisFontSize, 'FontWeight', 'bold', 'Color', 'k');
    end
end

hold off;

% 7. Save the chart
if isfield(chartParams, 'saveName') && ~isempty(chartParams.saveName)
    print(gcf, chartParams.saveName, '-dpng', '-r300');
    fprintf('Chart saved as: %s.png\n', chartParams.saveName);
end
end
