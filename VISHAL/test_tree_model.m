%% Electricity Load Forecasting using NN

%% Import Load Data

load ausdata

term = 'short';

[X, dates, labels] = genPredictors(D, term);

%% Split the dataset to create a Training and Test set

% Create training set
trainInd = D.NumDate < datenum('2019-09-08');
trainX = X(trainInd,:);
trainY = D.Power(trainInd);

% Create test set and save for later
testInd = D.NumDate >= datenum('2019-09-08');
testX = X(testInd,:);
testY = D.Power(testInd);
testDates = dates(testInd);

save Data\testSet_aus_tree testDates testX testY
clear X data trainInd testInd dates

%% Build the Bootstrap Aggregated Regression Trees


model = TreeBagger(20, trainX, trainY, 'method', 'regression', 'minleaf', 40)

%% Determine Feature Importance
 

model = TreeBagger(20, trainX, trainY, 'method', 'regression', ...
                   'oobvarimp', 'on', 'minleaf', 30);

figure(2);
barh(model.OOBPermutedVarDeltaError);
ylabel('Feature');
xlabel('Out-of-bag feature importance');
title('Feature importance results');
set(gca, 'YTickLabel', labels)

%% Build the Final Model
% Given our analysis of parameters, we may wish to now build the final
% model with 20 trees, a leaf size of 20 and all of the features

model = TreeBagger(20, trainX, trainY, 'method', 'regression', 'minleaf', 20);

%% Save Trained Model
% We can compact the model (to remove any stored training data) and save
% for later reuse

model = compact(model);
save Models\TreeModel_aus model

%% Test Results
% Load in the model and test data and run the treeBagger forecaster and
% compare to actual load.

clear
cd Models
load Models\TreeModel_aus
cd ..
cd Data
load Data\testSet_aus_tree
cd ..


%% Compute Prediction
% Predict the load for 2008 using the model trained on load data from 2007
% and before.
forecastLoad = predict(model, testX);


%% Compare Forecasted Load and Actual Load
% Create a plot to compare the actual load and the predicted load as well
% as the forecast error.
cd Util
ax1 = subplot(2,1,1);
plot(testDates, [testY forecastLoad]);
ylabel('Load'); legend({'Actual', 'Forecast'}); legend('boxoff')
ax2 = subplot(2,1,2);
plot(testDates, testY-forecastLoad);
xlabel('Date'); ylabel('Error (MWh)');
linkaxes([ax1 ax2], 'x');
dynamicDateTicks([ax1 ax2], 'linked')

%% Compute Model Forecast Metrics
% In addition to the visualization we can quantify the performance of the
% forecaster using metrics such as mean average error (MAE), mean average
% percent error (MAPE) and daily peak forecast error.

err = testY-forecastLoad;
errpct = abs(err)./testY*100;


fL = reshape(forecastLoad(1:end-1), 1, (length(forecastLoad)-1)/1)';
tY = reshape(testY(1:end-1), 1, (length(testY)-1)/1)';

peakerrpct = abs(max(tY,[],2) - max(fL,[],2))./max(tY,[],2) * 100;

fprintf('Mean Average Percent Error (MAPE): %0.2f%% \nMean Average Error (MAE): %0.2f MWh\nDaily Peak MAPE: %0.2f%%\n',...
    mean(errpct(~isinf(errpct))), mean(abs(err)), mean(peakerrpct))