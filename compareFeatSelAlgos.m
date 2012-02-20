function acc = compareFeatSelAlgos(X,Y,options,outFile)
% The feature selection function should be of the form
%
%     selectedFeats = featSelAgo(X,Y,varargin)
%
% where selectedFeats can be the desired k features or contains those
% features in selectedFeats(1:k). It is suggested to use a wrapper around
% the original function.
%
% See also: FEATSELOPTIONS

N = size(X,1);
if (N~=size(Y,1))
    error('Number of samples is not same in X and Y')
end

numAlgos = length(options.selectedAlgos);
numfolds = options.numFolds;
numstages = length(options.numFeats);

if (strcmp(options.partitionType,'holdout'))
    %use the partition mentioned in options
    numfolds = 1;
    c = cvpartition(N,'holdout',options.numFolds);
elseif (strcmp(options.partitionType,'kfold'))
    %k-fold crossvalidation partitions
    c = cvpartition(N,'kfold',numfolds);
elseif (strcmp(options.partitionType,'separate'))
    % separate training and validation setemacs
    % numfolds is a vector of training indices
    c.NumTestSets = 1;
    c.training = false(N,1);
    c.training(numfolds) = 1;
    c.test= false(N,1);
    c.test(setdiff(1:N,numfolds)) = 1;
    
    % repeat it 5 times with the same test and train data and avg the results
    numfolds = options.numfolds_for_separate;
end

% print experiment details to output file
datafile = fopen(outFile,'a');
fprintf(datafile,'---------------------------------------------------\n');
fprintf(datafile,'date: %s\n',date);
fprintf(datafile,'number of folds: %d\n',numfolds);
fprintf(datafile,'num of pls comps for lda subspace: %d\n',options.numComps);
tableheader='feats\t';
writeformat='%d\t\t';
fprintf(datafile,'algo\talgoname\n');
for i=1:numAlgos
    fprintf(datafile,'%d\t\t%s\n',options.algos{options.selectedAlgos(i)+1,1},...
        options.algos{options.selectedAlgos(i)+1,2});
    tableheader = strcat(tableheader,['algo' num2str(options.algos{options.selectedAlgos(i)+1,1})],'\t');
    writeformat=strcat(writeformat,'%0.4f\t');
end
fprintf(datafile,'-accuracies-');
fprintf(datafile,['\n' tableheader '\n']);

% Create a temp directory to dump results which will later be uploaded to NIPS Feature Selection
% Challenge site. Mostly used for the Arcene dataset.
if options.saveallresults
    tempdir = strcat(options.tempdir,'_',options.datasetname);
    mkdir(tempdir);
end


acc = zeros(numstages,numAlgos,numfolds); % will be avged over folds at the end
%err = zeros(size(acc));

%perform feature selection and evaluation for a given partitioning of data
for i = 1:numfolds
    fprintf('fold num: %d\n',i);
    if (strcmp(options.partitionType,'separate'))
        trainind = c.training;
        testind = c.test;
    else
        trainind = c.training(i);
        testind = c.test(i);
    end
    trainx = X(trainind,:);
    trainy = Y(trainind,:);
    testx = X(testind,:);
    testy = Y(testind,:);
    for j=1:numAlgos
        algo = options.selectedAlgos(j)+1;
        algotype = options.algos{algo,5};
        featselfunc = options.algos{algo,3};
        fprintf('algo: %s\n',options.algos{algo,2});
        
        %for ranking based algorithm, it is enough to obtain the ranks once
        if strcmpi(algotype,'rank')
            % select features
            varargin = cell(1);
            varargin{1} = max(options.numFeats);
            varargin{2} = options.numComps;
            varargin = [varargin options.algos{algo,4}];
            feats = feval(featselfunc,trainx,trainy,varargin{:});
        elseif strcmpi(algotype,'lasso')
            % mostly used to run lasso type algorithms in r.
            % the temp files are read in by the r function.
            
            % spls.r doesn\'t like features with zero variance
            trainx = trainx + rand(size(trainx))*1e-3;
            delete temp_data.mat
            delete temp_params.mat
            delete temp_output.mat
            save('temp_data.mat','trainx','trainy');
            ncomp = options.numComps;
            nfeats = options.numFeats;
            save('temp_params.mat','ncomp','nfeats');
            system(featselfunc);
            load('temp_output.mat');
        end
        
        fprintf('num features: ');
        for k=1:numstages
            numFeats = options.numFeats(k);
            fprintf('%d ',numFeats);
            if strcmpi(algotype,'rank')
                selectFeats = feats(1:numFeats);
            elseif strcmpi(algotype,'lasso')
                %Find the closest etaIndex for numFeats
                numfeats_diff = sum(feats~=0,2)-numFeats;
                closest = min(numfeats_diff(numfeats_diff >= 0));
                etaInd = find(numfeats_diff == closest);
                [coef,selectFeats] = sort(abs(feats(etaInd(1),:)),'descend');
                selectFeats = selectFeats(1:numFeats);
            elseif strcmpi(algotype,'subset')
                varargin = cell(1);
                varargin{1} = numFeats;
                varargin{2} = options.numComps;
                varargin = [varargin options.algos{algo,4}];
                selectFeats = feval(featselfunc,trainx,trainy,varargin{:});
            end
            
            yPredict = feval(@evaluateSubset,trainx,trainy,testx,selectFeats,options.numComps);
            
            if options.saveallresults
                % Write the selected features to txt file
                zip_file = strcat(tempdir,'/',options.algos{algo,2},'_fold',int2str(i),'_feats',int2str(numFeats));
                
                % The submission to NIPS site needs to have [data]_train.resu, [data]_valid.resu, [data]_test.resu
                % [data].feat files to compute all the results
                
                % Copy the training y label to the result (the actual thing should be the result of an feval)
                train_resu_filename = strcat(options.datasetname,'_train.resu');
                train_resu_file = fopen(strcat(tempdir,'/',train_resu_filename),'w');
                trainy_posneg = (trainy*2)-1;
                fprintf(train_resu_file,'%d\n',trainy_posneg);
                fclose(train_resu_file);
                
                valid_resu_filename = strcat(options.datasetname,'_valid.resu');
                valid_resu_file = fopen(strcat(tempdir,'/',valid_resu_filename),'w');
                yPredict_posneg = (yPredict*2)-1;
                fprintf(valid_resu_file,'%d\n',yPredict_posneg);
                fclose(valid_resu_file);
                
                % The [data]_test.resu file is faked for now
                test_resu_filename = strcat(options.datasetname,'_test.resu');
                test_resu_file = fopen(strcat(tempdir,'/',test_resu_filename),'w');
                testyPredict_posneg = repmat((trainy*2)-1,[7 1]); % Arcene contains 700 test samples
                fprintf(test_resu_file,'%d\n',testyPredict_posneg);
                fclose(test_resu_file);
                
                feat_filename = strcat(options.datasetname,'.feat');
                feat_file = fopen(strcat(tempdir,'/',feat_filename),'w');
                fprintf(feat_file,'%d\n',selectFeats);
                fclose(feat_file);
                
                system(horzcat('tar czf ',zip_file,'.tar.gz -C ',tempdir,' ',valid_resu_filename,' ',feat_filename,' ',train_resu_filename,' ',test_resu_filename));
                system(horzcat('rm ',tempdir,'/*.resu ',tempdir,'/*.feat')) ;
            end
            
            if (~isnumeric(yPredict))
                % works only if Y is converted to a categorical vector by using
                % num2str on a numeric vector
                % err(k,j,i) = mean((str2double(yPredict)-str2double(testy)).^2);
                acc(k,j,i) = sum(str2double(yPredict)==str2double(testy))/sum(testind);
            else
                % err(k,j,i) = mean((yPredict-testy).^2);
                acc(k,j,i) = sum(yPredict==testy)/sum(testind);
            end
        end
        fprintf('\n');
    end
    fprintf('\n');
end

% Take average over folds
acc = mean(acc,3); %for classification
% err = mean(err,3); %for regression

for i=1:size(acc,1)
    fprintf(datafile,[writeformat '\n'],options.numFeats(i),acc(i,:));
end
fclose(datafile);
end

%%
function Y = evaluateSubset(trainX,trainY,testX,feats,numComps)

%Select feature subset
testX = testX(:,feats);
newX = trainX(:,feats);

% Training: Find PLS subspace
[temp,temp,XS,temp,temp,temp,temp,stats] = plsregress(newX,trainY,numComps);
Xmean = mean(newX,1); %will need to subtract mean during testing
wts = stats.W; %weights to find projections of test data

%Project the test data onto PLS subspace
testX = testX - repmat(Xmean,size(testX,1),1);
testXS = testX * wts;

Y = classify(testXS,XS,trainY);
end
