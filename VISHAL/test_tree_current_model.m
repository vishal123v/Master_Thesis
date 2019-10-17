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

save Data\testSet_aus_tree_AMP testDates testX testY
clear X data trainInd testInd dates

%% Build the Bootstrap Aggregated Regression Trees


model = TreeBagger(20, trainX, trainY, 'method', 'regression', 'minleaf', 40)


oobError = [];
leafSizes = [10 20 40 50];
for i = 1:length(leafSizes)
    model = TreeBagger(20, trainX, trainY, 'method', 'regression', ...
                       'oobpred', 'on', 'minleaf', leafSizes(i));
    oobError = [oobError model.oobError];
    
    figure(1), plot(oobError);
    xlabel('Number of grown trees'), ylabel('Out-of-bag Regression Error');
    title(sprintf('Regression Error versus Number of Trees & Leaf Size'));
    legend(num2str(leafSizes(1:i)')), drawnow;
end

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
load Data\testSet_aus_tree_AMP
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
xlabel('Date'); ylabel('Error ');
linkaxes([ax1 ax2], 'x');
dynamicDateTicks([ax1 ax2], 'linked')

