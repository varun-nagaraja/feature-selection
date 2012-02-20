function feats = mRMR(X,Y,varargin)
% FEATS = MRMRQ(X,Y,NUMFEATS) Selects NUMFEATS features using the mRMR
% techique. It currently uses the Information Gain quotient version instead 
% of the difference version.
%
% Please download the mRMR toolbox, MATLAB version with precompiled mutual 
% information toolbox, from the author's site
% http://penglab.janelia.org/proj/mRMR/
% Remember to store the files in the working directory or add the toolbox 
% path in MATLAB.

numFeats = varargin{1};
feats = mrmr_miq_d(X, Y, numFeats);
end