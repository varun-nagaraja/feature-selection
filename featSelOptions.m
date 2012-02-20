function options=featSelOptions(numFolds,numComps,datasetname)
% OPTIONS=FEATSELOPTIONS creates an options structure for comparing feature
% selection algorithms. This is to be used in conjunction with
% COMPAREFEATSELALGOS. Run the function once to create the structure and 
% make desired modifications.
%
% See also: COMPAREFEATSELALGOS

% Author: Varun Nagaraja (varun@cs.umd.edu)

% Cross-validation folds for each stage
options.numFolds = numFolds;

% Number of components for PLS subspace
options.numComps = numComps;

% Number of selected features at each stage
options.numFeats = options.numComps:10:200;

% For R scipts, instead of the function handle, give the system command 
% to be executed. The data is transferred in 
% -temp_data.mat
% ---trainX
% ---trainY
% -temp_params.mat
% ---ncomp - number of pls components
% ---nfeats - number of features to select
%
% The result is stored in
% -temp_output.mat
% ---feats - coefficients which have to be thresholded
% ---etas - sparsity coefficients

options.algos = [{'=AlgoNum=','=AlgoName=','=FunctionHandle=','=Params=','=Type='};
    {1,'OptimalLoadings',@optimalLoadings,{},'subset'};
    {2,'RegressionCoeffs',@regCoef,{},'rank'};
    {3,'RReliefF',@relieffWrapper,{10,'method','regression','updates',100},'rank'};
    {4,'FisherScore',@fisherScore,{},'rank'};
    {5,'mRMRq',@mRMR,{},'rank'};
    {6,'Sparse-PLS','R CMD BATCH spls.r',{},'lasso'}];

options.selectedAlgos = 1:size(options.algos,1)-1;
if length(numFolds)>1
    %numFolds is a vector of training indices
    options.partitionType = 'separate';
elseif (numFolds>0 && numFolds<1) 
    %numFolds is a fractional value
    options.partitionType = 'holdout';
else
    options.partitionType = 'kfold';
end

options.datasetname = datasetname;
options.tempdir = 'temp_results';
options.saveallresults = false;
options.numfolds_for_separate = 5;
