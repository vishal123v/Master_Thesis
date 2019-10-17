function y = loadForecast_aus(date, hour,histLoad)
% LOADFORECAST performs a day-ahead load forecast using a pre-trained
% Neural-Network or Bagged Regression Tree model
%
% USAGE:
% y = loadForecast(model, date, hour, temperature, isWorkingDay, ...
%                  histDate, histHour, histLoad)

% Process Historical loads

dayofweek = weekday(date);
isWorkingDay = 1;

% histDate = datenum(histDate);%+(histHour-1)/24;
prevWeek = histLoad(end-(48*8)+1:end-(48*7));
prevDay  = histLoad(end-47:end);
ave24 = filter(ones(48,1)/48, 1, histLoad);
prev24 = ave24(end-47:end);

% Create predictor matrix
% Drybulb, Dewpnt, Hour, Day, isWkDay, PrevWeek, PrevDay, Prev24
% X = [temperature hour weekday(date) isWorkingDay*ones(size(date)) prevWeek prevDay prev24];
try
X = [hour dayofweek isWorkingDay prevWeek prevDay prev24];
% Load model and perform prediction
s = load('NNModel_aus.mat');
y1 = sim(s.net, X')';



plot(hour, [y1 y2]/1e3); 
xlabel('Hour');
ylabel('Load (x1000 MW)');
title(sprintf('Load Forecast Profile for %s', datestr(date(1))))
grid on;
legend('NeuralNet','BaggedTree','Location','best');
print -dmeta

y = [y1 y2];
catch
    whos
end
%#function TreeBagger
%#function CompactTreeBagger
%#function network
%#function network\sim