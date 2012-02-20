function rowlist = mycandexch(fxcand,nrows,varargin)
%MYCANDEXCH A tweaked version of CANDEXCH such that no duplicate rows are
%selected. It is also stripped down to support few parameters only.
%
%   ROWLIST = MYCANDEXCH(X,NROWS) uses a row-exchange algorithm to select a
%   D-optimal design from the N-by-P matrix, X. NROWS is the desired number
%   of rows in the design.  ROWLIST is a vector of length NROWS listing the
%   selected rows.
%
%   ROWLIST = MYCANDEXCH(C,NROWS,MAXITER,TRIES,INIT)
%
%      Parameter    Value
%      MAXITER      Maximum number of iterations (default = 10).
%      TRIES        Number of times to try to generate a design from a
%                   new starting point, using random points for each
%                   try except possibly the first (default = 1).
%      INIT         Initial design as an NROWS-by-P matrix
%                   (default = random subset of the rows of X).
%
% See also: CANDEXCH

end