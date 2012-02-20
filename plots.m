%% Script to generate various kinds of plots for comparing feature selection algorithms
% See plots in paper

%% Performance comparison plots
colors = {'r','b','m','k',[0.5 0.5 0.5],'k'};
markers = {'*','s','+','o','s','d'};
algoNames = options.algos(2:end,2);
legendTitles = cell(1,length(options.selectedAlgos));
for i=1:size(acc,2)
    figure(1), plot(options.numFeats,acc(:,i),['-' markers{i}],'Color',colors{i}), hold on
    legendTitles(i)=algoNames(options.selectedAlgos(i));
end
ylabel('Accuracy','FontSize',14),xlabel('Number of features','FontSize',14)
h_legend=legend(legendTitles);
set(h_legend,'FontSize',14,'Location','SouthEast');
% legend(legend()
axis([min(options.numFeats)-5 max(options.numFeats) 0 1])

grid on
% h = figure(1);
% set(h,'FontSize',20)

%% Feature points on images - (a) find feature indices
sampleFeats = [50 100 150 200];
idx = cell(length(sampleFeats),1);
for k = 1:length(sampleFeats)
    numFeats = sampleFeats(k);
    idx{k} = zeros(numFeats,length(options.selectedAlgos));
end
for i=1:length(options.selectedAlgos)
    algo = options.selectedAlgos(i)+1;
    algoType = options.algos{algo,5};
    featSelFunc = options.algos{algo,3};
    if strcmpi(algoType,'rank')
        % Select features once for ranking based algos
        varargin = cell(1);
        varargin{1} = max(sampleFeats);
        varargin{2} = options.numComps;
        varargin = [varargin options.algos{algo,4}];
        feats = feval(featSelFunc,X,Y,varargin{:});
    elseif strcmpi(algoType,'lasso')
        % mostly used to run lasso type algorithms in r.
        % the temp files are read in by the r function.
        
        % spls.r doesn\'t like features with zero variance
        trainx = X + rand(size(X))*1e-3;
        trainy = Y;
        delete temp_data.mat
        delete temp_params.mat
        delete temp_output.mat
        save('temp_data.mat','trainx','trainy');
        ncomp = options.numComps;
        nfeats = sampleFeats;
        save('temp_params.mat','ncomp','nfeats');
        system(featSelFunc);
        load('temp_output.mat');
    end
    for k = 1:length(sampleFeats)
        numFeats = sampleFeats(k);
        if strcmpi(algoType,'rank')
            idx{k}(:,i) = feats(1:numFeats);
        elseif strcmpi(algoType,'lasso')
            %Find the closest etaIndex for numFeats
            numfeats_diff = sum(feats~=0,2)-numFeats;
            closest = min(numfeats_diff(numfeats_diff >= 0));
            etaInd = find(numfeats_diff == closest);
            [coef,selectFeats] = sort(abs(feats(etaInd(1),:)),'descend');
            idx{k}(:,i) = selectFeats(1:numFeats);
        elseif strcmpi(algoType,'subset')
            varargin = cell(1);
            varargin{1} = numFeats;
            varargin{2} = options.numComps;
            varargin = [varargin options.algos{algo,4}];
            idx{k}(:,i) = feval(featSelFunc,X,Y,varargin{:});
        end
    end
end
%% Feature points on images - (b) overlay selected features on images
numAlgos = length(options.selectedAlgos);
%imgsize = [112 92]; %ORL images
% imgsize = [28 28]; %MNIST images
imgsize = [64 64]; %PIE images
for img = 1:size(X,1) % rotate over different images, pauses after every image
    for k = 1:length(sampleFeats)
        for i = 1:numAlgos
            temp = X(img,:);
            temp(idx{k}(:,i))=0;
            temp = reshape(temp,imgsize);
            
            subplot(length(sampleFeats),numAlgos,i+(k-1)*numAlgos),imshow(temp,[]), hold on
            [temp1,temp2] = ind2sub(imgsize,idx{k}(:,i));
            subplot(length(sampleFeats),numAlgos,i+(k-1)*numAlgos),plot(temp2,temp1,'r.')
            if (i==1)
                ylabel(sprintf('k = %d',sampleFeats(k)));
            end
            if (k==length(sampleFeats))
                xlabel(options.algos{options.selectedAlgos(i)+1,2});
            end
        end
    end
    pause
end

%% Feature points on HOG images
numAlgos = length(options.selectedAlgos);
smallerSize = [6 6 64];
largerSize = [2 2 128];
imgsize = [64 64]; %ORL images
for img = 1:size(X1,1) % rotate over different images, pauses after every image
    for k = 1:length(sampleFeats)
        for i = 1:numAlgos
            temp = X1(img,:);
            temp(setdiff(1:length(temp),idx{k}(:,i)))=0;
            
            imTemp = X(img,:);
            imTemp = reshape(imTemp,imgsize);
            
            smallerScale = temp(1:prod(smallerSize));
            largerScale = temp(prod(smallerSize)+1:end);
            
            smallerScale = reshape(smallerScale,smallerSize);
            V=hogDraw(smallerScale,11)>0;
            imTemp = imTemp.*~V(1:64,1:64) + 255*V(1:64,1:64);
            
            subplot(length(sampleFeats),numAlgos,i+(k-1)*numAlgos),imshow(imTemp,[]), hold on
            %             [temp1,temp2] = ind2sub(imgsize,idx{k}(:,i));
            %             subplot(length(selectFeats),numAlgos,i+(k-1)*numAlgos),plot(temp2,temp1,'r.')
            if (i==1)
                ylabel(sprintf('k = %d',sampleFeats(k)));
            end
            if (k==length(sampleFeats))
                xlabel(options.algos{options.selectedAlgos(i)+1,2});
            end
        end
    end
    pause
end

%% Plots - varying comps
colors = {'r','k','m','k',[0.5 0.5 0.5],'b'};
markers = {'*','s','+','o','s','d'};
numComps = unique(temp(:,8));
figure
for i=1:length(numComps)
    plot(temp(temp(:,8)==numComps(i),6),temp(temp(:,8)==numComps(i),1),...
        ['-' markers{i}],'Color',colors{i});
    hold on;
end
ylabel('Accuracy'),xlabel('Number of features')
legend('d=10','d=20','d=30')
legend(legend(),'Location','NorthEast');
axis([0 200 0 1])
grid on

%% Plots - detmax algos
colors = {'r','k','b','k',[0.5 0.5 0.5],'b'};
markers = {'*','s','d','o','s','d'};
algos = unique(temp(:,7));
comps = unique(temp(:,8));
k = unique(temp(:,6));
for i=1:length(comps)
    inds1 = temp(:,7)==algos(1) & temp (:,8)==comps(i);
    inds8 = temp(:,7)==algos(2) & temp (:,8)==comps(i);
    plot(temp(inds1,3),temp(inds8,3),...
        [markers{i}],'Color',colors{i});
    hold on;
end
% axis([100 800 100 800])
legend('d=10','d=20','d=40')
legend(legend(),'Location','NorthWest');
x = 1:800;
plot(x,x,'-.','Color',[0.5 0.5 0.5])
grid on
xlabel('logdet(PP'') (Exchange Algorithm)')
ylabel('logdet(PP'') (Convex Optimization)')
