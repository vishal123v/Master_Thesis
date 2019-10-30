function [X, dates, labels] = genPredictors(data, term)
% GENPREDICTORS generates a matrix of predictor variables for the load
% forecasting model.
% Convert Dates into a Numeric Representation



if ~isfield(data,'NumDate')
    dates = datenum(data.date, 'yyyy-mm-dd HH:MM:SS') + (data.Hour-1)/24;
else
    dates = data.NumDate;
    if all(floor(dates)==dates) % true if dates don't include any hour information
        dates = dates + (data.Hour-1)/24;
    end
end

% Short term forecasting inputs
% Lagged load inputs
prevDaySameHourLoad = [NaN(24*2,1); data.Power(1:end-24*2)];
prevWeekSameHourLoad = [NaN(168*2,1); data.Power(1:end-168*2)];
prev24HrAveLoad = filter(ones(1,48)/48, 1, data.Power);

% Date predictors
dayOfWeek = weekday(dates);

% Short Term
 X = [data.Power data.Hour dayOfWeek prevWeekSameHourLoad prevDaySameHourLoad prev24HrAveLoad];
 labels = {'Power', 'Hour', 'Weekday','PrevWeekSameHourLoad', 'prevDaySameHourLoad', 'prev24HrAveLoad'};
     
    
 function y = rep24(x)
    y = repmat(x(:), 1, 24)';
    y = y(:);