clc;
clear all;
close all;

addpath('data');
addpath('functions');
addpath('RF');

%% load data
HSI = double(imread('2013_IEEE_GRSS_DF_Contest_CASI.tif'));
TrainImage = double(imread('2013_IEEE_GRSS_DF_Contest_Samples_TR.tif'));
TestImage = double(imread('2013_IEEE_GRSS_DF_Contest_Samples_VA.tif'));

[m, n, z] = size(HSI);

%% parameter setting
num_group = 4;
order = 3;
d = 30;

%% remove anomaly pixels
HSI2d = hyperConvert2d(HSI);
ind = isnan(HSI2d);
HSI2d(ind == 1) =0 ;
HSI3d = hyperConvert3d(HSI2d, m, n, z);

%% IAPs extraction
IAPs = IAPs_extraction(HSI3d, num_group, order);

%% feature learning with PCA
[HSI2d_pca, ~] = our_pca(IAPs, d);

%% feature normalization
NormalizedFea = FeaNormalization(HSI2d_pca');

%% training and test generation
Fea3d = hyperConvert3d(NormalizedFea, m, n, d);
[TrainSample, TestSample, TrainLabel, TestLabel]=GetSampleLabel(Fea3d, TrainImage, TestImage);

%% classification with 1NN
mdl = ClassificationKNN.fit(TrainSample', TrainLabel', 'NumNeighbors', 1, 'distance', 'euclidean'); 
characterClass = predict(mdl, TestSample'); 
[ ~ , oa_NN, pa_NN, ua_NN, kappa_NN] = confusionMatrix( TestLabel', characterClass);

rng(1);
num_trees = 500;
model = classRF_train(TrainSample', TrainLabel', num_trees);
[classTest, ~, ~] = classRF_predict(TestSample', model);
[ ~ , oa_RF, pa_RF, ua_RF, kappa_RF] = confusionMatrix( TestLabel', classTest);

