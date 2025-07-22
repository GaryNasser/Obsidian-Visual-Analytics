# Obsidian-Visual-Analytics
A MATLAB suite for analyzing and visualizing personal data from Obsidian daily notes.

This project is a suite of MATLAB scripts designed to analyze and visualize personal daily data logged in Obsidian markdown files. It extracts data from YAML front matter in your daily notes and generates a series of insightful charts about your habits, such as sleep patterns, work-life balance, and fitness activities.

## Features

-   **Data Extraction**: Parses YAML front matter from Obsidian daily notes within a specified date range.
-   **Sleep Pattern Visualization**: Intelligently plots sleep cycles by correlating the "sleep-in" time of one day with the "wake-up" time of the next.
-   **Activity Trending**: Generates single-metric line charts with smoothed curves and average lines (e.g., for work duration).
-   **Comparative Analysis**: Creates dual Y-axis charts to compare two different metrics over time (e.g., Running vs. Meditation).
-   **Modular Design**: The analysis logic, data extraction, and plotting functions are separated into modular `.m` files for clarity and reusability.
-   **Smart Plotting**: Includes features like intelligent label collision avoidance in dual-axis charts.

## Project Structure

-   `main_analysis_script.mlx`: The main executable script. **Configure your parameters here.**
-   `analyzeObsidianNotes.m`: A function to read and parse data from Obsidian `.md` files.
-   `plotSleepPattern.m`: A function to create the sleep pattern visualization.
-   `createSingleLineChart.m`: A generic function to plot a single metric over time.
-   `createDualYAxisChart.m`: A generic function to plot two metrics on a dual Y-axis chart.

## How to Use

1.  **Prerequisites**:
    *   MATLAB installed on your system.
    *   Your daily data recorded in Obsidian notes, with filenames as dates (e.g., `2025-07-13.md`) and data in the YAML front matter.

2.  **Configuration**:
    *   Open `main_analysis_script.m`.
    *   Set the `obsidianFolder` variable to the absolute path of your Obsidian vault's "daily notes" directory.
    *   Define the `startDate` and `endDate` for the primary analysis period you wish to visualize.

3.  **Run**:
    *   Simply run the `main_analysis_script.m` file from MATLAB.
    *   The script will process the data and save the output charts as `.png` files in your current MATLAB directory.

## YAML Data Format Example

Your `.md` files should contain a YAML front matter block like this. The parser will handle missing values gracefully.

```yaml
---
wake-up: 07:30
sleep-in: 23:15
Working Outside: 3.5
Meditation: 20
new-feeling: false
---

Your daily notes content goes here...
