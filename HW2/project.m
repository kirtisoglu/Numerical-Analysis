
%% Data preprocessing

data = readtable('population-change.xlsx'); % Census data for the US population change between 1910 - 2020
row = find(strcmp(data.Area, 'United States1')); % US population row
data_us = data(row, 2:end);  % keep only US population row and remove th first column (row names)
data_us = removevars(data_us, {'Area_1', 'Area_2'}); % remove row names in other pages

data_us.Properties.VariableNames  % see column names
column_indices = 1:width(data_us);  % Get all column indices
even_columns = column_indices(mod(column_indices, 2) == 0);  % Find even-numbered columns
data_us = removevars(data_us, data_us.Properties.VariableNames(even_columns)); % Remove the even-numbered columns from the table (percentage columns)
disp(data_us)  % see if the data is ready

years = cellfun(@(x) str2double(x(2:5)), data_us.Properties.VariableNames);  % Extract years (e.g., from 'x2020Census' -> 2020)
x = years
y = table2array(data_us)  % Convert the table to an array to access the values


%% (a) Determine the interpolation polynomial

degree = length(x) - 1;  % Degree of the polynomial
[p, S, mu] = polyfit(x, y, degree);  % Fit the polynomial

x_fit = linspace(min(x), max(x), 100);  % Generate 100 points between min and max year
y_fit = polyval(p, x_fit, S, mu);  % Evaluate the polynomial at x_fit

figure;
plot(x, y, 'o', 'DisplayName', 'Data');  % Original data points
hold on;
plot(x_fit, y_fit, '-', 'DisplayName', 'Interpolation Polynomial');  % Polynomial curve
xlabel('Year');
ylabel('Population');
legend;
title('Interpolation Polynomial Fit');



%% (b) Determine a cubic spline

pp = spline(x, y);  % Piecewise polynomial form for the cubic spline
y_spline = ppval(pp, x_fit);  % Evaluate spline at points in x_fit for plotting

figure;
plot(x, y, 'o', 'DisplayName', 'Data');  % Plot original data points
hold on;
plot(x_fit, y_spline, '-', 'DisplayName', 'Cubic Spline');  % Spline curve
xlabel('Year');
ylabel('Population');
legend;
title('Cubic Spline Fit');


%% (c) What is the estimated US population on Jan. 1st, 2005? Which estimate do you think makes more sense?

population_poly = polyval(p, 2005, S, mu); % Estimate the population using the polynomial
population_spline = ppval(pp, 2005); % Estimate the population using the cubic spline

fprintf('Estimated population in 2005 (polynomial): %.5f\n', population_poly); % Display the results with 5 decimals
fprintf('Estimated population in 2005 (spline): %.5f\n', population_spline);

%{
Which estimate makes more sense?

For a year like 2005, which is between the years 2010 and 2000 in the dataset, 
the cubic spline interpolation is typically more reasonable because it provides 
smooth transitions between the data points, and it avoids the risk of the polynomial 
overfitting or exhibiting oscillations.The polynomial will exactly fit the data points, 
but it may produce unrealistic behavior outside the data range (like large oscillations) 
due to the high-degree nature of the polynomial.
%}