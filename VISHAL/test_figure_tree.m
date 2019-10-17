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




%% Determine Feature Importance
 

model = TreeBagger(20, trainX, trainY, 'method', 'regression', ...
                   'oobvarimp', 'on', 'minleaf', 30);

figure(1);
barh(model.OOBPermutedVarDeltaError);
ylabel('Feature');
xlabel('Out-of-bag feature importance');
title('Feature importance results');
set(gca, 'YTickLabel', labels)


model = TreeBagger(20, trainX, trainY, 'method', 'regression', 'minleaf', 20);


model = compact(model);
save Models\TreeModel_aus model


clear
load Models\TreeModel_aus
load Data\testSet_aus

forecastLoad = predict(model, testX);
cd Util
figure(2);
ax1 = subplot(2,1,1);
plot(testDates, [testY forecastLoad]);
ylabel('Load'); legend({'Actual', 'Forecast'}); legend('boxoff')
ax2 = subplot(2,1,2);
plot(testDates, testY-forecastLoad);
xlabel('Date'); ylabel('Error (MWh)');
linkaxes([ax1 ax2], 'x');
dynamicDateTicks([ax1 ax2], 'linked')



err = testY-forecastLoad;
errpct = abs(err)./testY*100;
% fL = reshape(forecastLoad, 24, length(forecastLoad)/24)';
% tY = reshape(testY, 24, length(testY)/24)';
% peakerrpct = abs(max(tY,[],2) - max(fL,[],2))./max(tY,[],2) * 100;
fL = reshape(forecastLoad(1:end-1), 1, (length(forecastLoad)-1)/1)';
tY = reshape(testY(1:end-1), 1, (length(testY)-1)/1)';
peakerrpct = abs(max(tY,[],2) - max(fL,[],2))./max(tY,[],2) * 100;
fprintf('Mean Average Percent Error (MAPE): %0.2f%% \nMean Average Error (MAE): %0.2f MWh\nDaily Peak MAPE: %0.2f%%\n',...
    mean(errpct(~isinf(errpct))), mean(abs(err)), mean(peakerrpct))
