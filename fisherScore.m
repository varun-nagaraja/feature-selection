function feats = fisherScore(X,Y,varargin)

% wraps around fsFisher.m available from ASU feature selection toolbox
% http://featureselection.asu.edu/algorithms/fs_sup_fisher_score.zip

out = fsFisher(X,Y);
feats = out.fList;
end