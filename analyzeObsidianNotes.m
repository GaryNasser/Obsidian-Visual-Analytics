function results = analyzeObsidianNotes(startDate, endDate, obsidianFolder)
% analyzeObsidianNotes - Analyzes YAML front matter from Obsidian notes.
% Assumes note filenames are dates and uses them to filter by date range.
%
% Inputs:
%   startDate - Start date string (format: 'yyyy-mm-dd')
%   endDate - End date string (format: 'yyyy-mm-dd')
%   obsidianFolder - Path to the Obsidian notes folder
%
% Outputs:
%   results - A table containing the extracted data.

clc;

% Print start-up information
fprintf('=== Obsidian Note Analyzer ===\n');
fprintf('Start Time: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf('Analyzing Date Range: %s to %s\n', startDate, endDate);
fprintf('Notes Folder: %s\n', obsidianFolder);

try
    % Convert date strings to MATLAB's serial date number format
    startDateNum = datenum(startDate, 'yyyy-mm-dd');
    endDateNum = datenum(endDate, 'yyyy-mm-dd');

    % Get a list of all Markdown files in the directory
    markdownFiles = dir(fullfile(obsidianFolder, '*.md'));

    if isempty(markdownFiles)
        error('No Markdown (.md) files found. Please check the path: %s', obsidianFolder);
    end

    % Filter files that fall within the date range by parsing filenames
    validFilesIdx = [];
    for i = 1:length(markdownFiles)
        fileName = markdownFiles(i).name;
        try
            % Attempt to convert the filename to a date number
            % This assumes a recognizable date format like 'yyyy-mm-dd.md'
            fileDateNum = datenum(fileName(1:10)); 
            if fileDateNum >= startDateNum && fileDateNum <= endDateNum
                validFilesIdx = [validFilesIdx; i]; % Store index of valid file
            end
        catch
            % If filename cannot be parsed as a date, skip it
            continue; 
        end
    end

    % Check if any valid files were found
    if isempty(validFilesIdx)
        error('No Markdown files found for the specified date range (%s to %s).', startDate, endDate);
    end

    % Define property categories for parsing
    numericProps = {'Working Outside', 'Meditation'};
    timeProps = {'wake-up', 'sleep-in'};
    boolProps = {'Fruit'};

    % Initialize the results table
    varNames = [{'FileName'}, ...
                strrep(numericProps, ' ', '_'), ... % Replace spaces for valid table variable names
                timeProps, ...
                strrep(boolProps, ' ', '_')];
    varTypes = [{'string'}, ...
                repmat({'double'}, 1, length(numericProps)), ...
                repmat({'string'}, 1, length(timeProps)), ...
                repmat({'string'}, 1, length(boolProps))];

    results = table('Size', [length(validFilesIdx), length(varNames)], ...
                    'VariableTypes', varTypes, ...
                    'VariableNames', varNames);

    % Process each valid Markdown file
    for i = 1:length(validFilesIdx)
        fileIdx = validFilesIdx(i);
        filePath = fullfile(obsidianFolder, markdownFiles(fileIdx).name);
        fileContent = fileread(filePath);

        % Store the filename in the table
        results.FileName(i) = markdownFiles(fileIdx).name;

        % Initialize row with default values
        for p = 1:length(numericProps), results.(strrep(numericProps{p}, ' ', '_'))(i) = NaN; end
        for p = 1:length(timeProps), results.(timeProps{p})(i) = ""; end
        for p = 1:length(boolProps), results.(strrep(boolProps{p}, ' ', '_'))(i) = "false"; end

        % Extract YAML front matter using a regular expression
        yamlPattern = '---[\r\n]+(.*?)[\r\n]+---';
        yamlContent = regexp(fileContent, yamlPattern, 'tokens', 'once', 'dotexceptnewline');

        if ~isempty(yamlContent)
            yamlText = yamlContent{1};
            yamlLines = regexp(yamlText, '[\r\n]+', 'split');
            yamlLines = yamlLines(~cellfun('isempty', yamlLines));

            % Parse each line of the YAML block
            for k = 1:length(yamlLines)
                lineStr = strtrim(yamlLines{k});
                if isempty(lineStr) || ~contains(lineStr, ':'), continue; end

                parts = split(lineStr, ':');
                propName = strtrim(parts{1});
                if length(parts) > 1
                    propValue = strtrim(strjoin(parts(2:end), ':'));
                else
                    propValue = '';
                end
                
                if isempty(propValue), continue; end

                % Assign values based on property type
                if ismember(propName, numericProps)
                    numValue = str2double(propValue);
                    if ~isnan(numValue), results.(strrep(propName, ' ', '_'))(i) = numValue; end
                elseif ismember(propName, timeProps)
                    results.(propName)(i) = string(propValue);
                elseif ismember(propName, boolProps)
                    if strcmpi(propValue, 'true') || strcmpi(propValue, 'false')
                        results.(strrep(propName, ' ', '_'))(i) = lower(propValue);
                    end
                end
            end
        end

        % Display progress
        fprintf('Processed: %s (%d/%d)\n', markdownFiles(fileIdx).name, i, length(validFilesIdx));
    end

    % Display summary
    fprintf('\nAnalysis complete! Processed %d files within the date range.\n', length(validFilesIdx));

catch ME
    % Error handling
    fprintf('\n!!! An error occurred during execution !!!\n');
    fprintf('Error Message: %s\n', ME.message);
    fprintf('In file: %s (Line %d)\n', ME.stack(1).name, ME.stack(1).line);
    rethrow(ME);
end

% Print completion information
fprintf('\nEnd Time: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf('=== Program Finished ===\n');
end
