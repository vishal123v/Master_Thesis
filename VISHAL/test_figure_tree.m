%% Electricity Load Forecasting using NN

%% Import Load Data

load ausdata_Amp

term = 'short';

[X, dates, labels] = genPredictors_AMP(D, term);

%% Split the dataset to create a Training and Test set

% Create training set
trainInd = D.NumDate < datenum('2019-09-08');
trainX = X(trainInd,:);
trainY = D.Current(trainInd);

% Create test set and save for later
testInd = D.NumDate >= datenum('2019-09-08');
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


