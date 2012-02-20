function feats = optimalLoadings(X,Y,varargin)
%FEATS = OPTIMALLOADINGS(X,Y,NUMFEATS,NUMCOMPS) 
% Selects NUMFEATS features based on Optimal Loadings criterion that 
% maximizes the determinant of loadings matrix obtained through Partial 
% Least Squares model of NCOMPS components. It uses a tweaked version of
% CANDEXCH (MATLAB Statistics Toolbox) which is a row exchange algorithm to
% produce D-optimal designs.
%
% See also: MYCANDEXCH

% Author: Varun Nagaraja (varun@cs.umd.edu)

numFeats = varargin{1};
numComps = varargin{2};

[XL,YL,XS,YS,BETA] = plsregress(X,Y,numComps);

%Rank by regression coefficients to use as an initial set of features
[sortedB BGenes]=sort(abs(BETA(2:end,:)),'descend');
initFeats = BGenes(1:numFeats);

% Use the tweaked version of candexch to avoid duplicate feature indices
% Search for 'Varun' in MYCANDEXCH to see the tweak.
feats= mycandexch(XL,numFeats,100,10,XL(initFeats,:));

end