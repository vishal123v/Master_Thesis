%% Electricity Load Forecasting using NN

%% Import Load Data

load ausdata_Amp_1year

term = 'short';

[X, dates, labels] = genPredictors_AMP(D, term);

%% Split the dataset to create a Training and Test set

% Create training set
trainInd = D.NumDate < datenum('2019-07-01');
trainX = X(trainInd,:);
trainY = D.Current(trainInd);

% Create test set and save for later
testInd = D.NumDate >= datenum('2019-07-01');
testX = X(testInd,:);
testY = D.Current(testInd);
testDates = dates(testInd);

save Data\testSet_aus_NN_AMP_1year testDates testX testY
%clear X data trainInd testInd dates

%% Build the Load Forecasting Model

%% Initialize and Train Network

reTrain = false;
if reTrain || ~exist('Models\NNModel_aus.mat', 'file')
    net = newfit(trainX', trainY', 20);
    net.performFcn = 'mae';
    net = train(net, trainX', trainY');
    save Models\NNModel_aus.mat net
else
    load Models\NNModel_aus.mat
end


%% Forecast using Neural Network Model
% Once the model is built, perform a forecast on the independent test set. 
cd Data
load testSet_aus_NN_AMP_1year
forecastLoad = sim(net, testX')';


%% Compare Forecast Load and Actual Load
% Create a plot to compare the actual load and the predicted load as well
% as compute the forecast error. In addition to the visualization, quantify
% the performance of the forecaster using metrics such as mean average
% error (MAE), mean average percent error (MAPE) and daily peak forecast
% error.
cd ../Util
err = testY-forecastLoad;
fitPlot(testDates, [testY forecastLoad], err);

errpct = abs(err)./testY*100;
l=length(forecastLoad);
fL = reshape(forecastLoad(1:end), 1, l/1)';
tY = reshape(testY(1:end), 1, (length(testY))/1)';
peakerrpct = abs(max(tY,[],2) - max(fL,[],2))./max(tY,[],2) * 100;
%peakerrpct =1;
MAE = mean(abs(err));
MAPE = mean(errpct(~isinf(errpct)));

fprintf('Mean Average Percent Error (MAPE): %0.2f%% \nMean Average Error (MAE): %0.2f MWh\nDaily Peak MAPE: %0.2f%%\n',...
    MAPE, MAE, mean(peakerrpct))



