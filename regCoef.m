function feats = regCoef(X,Y,varargin)
% FEATS = REGCOEF(X,Y,NUMFEATS,NUMCOMPS) selects top NUMFEATS features 
% based on regression coefficients obtained through a Partial Least Squares 
% model of NCOMPS components

% Author: Varun Nagaraja (varun@cs.umd.edu)

numComps = varargin{2};
[temp,temp,temp,temp,BETA] = plsregress(X,Y,numComps);
[sortedB feats]=sort(abs(BETA(2:end,:)),'descend');

end
