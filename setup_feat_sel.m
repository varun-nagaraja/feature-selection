addpath('~/Code/feature-selection')
addpath('~/Code/feature-selection/mRMR_0.9_compiled')
addpath('~/Code/feature-selection/mRMR_0.9_compiled/mi')
load ~/Datasets/arcene_combined.mat
options = featSelOptions(1:100,20,'arcene');
options.numFeats = [50 100 250 500 1000];
options.selectedAlgos = 5;
options.saveallresults = true;
options.numfolds_for_separate = 1;
options.tempdir = '~/Code/feature-selection/temp_results'
compareFeatSelAlgos(X,Y,options,'~/Datasets/arcene.out')
