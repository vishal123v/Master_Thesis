%% Neural Network Load Forecasting
% This short script builds a Neural Network regression model for
% predicting day-ahead load from a predictor matrix consisting of
% temperature, date/time and lagged load data.

%% Initialize and Train Network
% Initialize a default network of two layers with 20 neurons. Use the "mean
% absolute error" (MAE) performance metric. Then, train the network with
% the default Levenburg-Marquardt algorithm. For 

net = newfit(trainX', trainY', 20);
net.performFcn = 'mae';

%% Train Network
% Train the network using the default Levenburg-Marquardt algorithm

net = train(net, trainX', trainY');

%% Predict with Network
% Perform a forecast on the independent testing dataset. 

forecastLoad = sim(net, testX')';

