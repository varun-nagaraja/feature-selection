A simple framework for comparing Feature Selection techniques
============================================================
* Perform cross-validation experiments to compare feature selection techniques.
* Try it with some [sample datasets](https://github.com/vkn13/Datasets.git).
* This project is still in its alpha stage.

Supervised Techniques
---------------------

Minimum Redundancy Maximum Relevance (mRMR) (`mRMR.m`)
* Needs external library. See `mRMR.m` for details.
* Download a newer version of the [mutual information toolbox](http://www.mathworks.com/matlabcentral/fileexchange/14888)

Partial Least Squares (PLS) regression coefficients (`regCoef.m`)
* Uses `plsregress.m` from MATLAB statistics toolbox

ReliefF (classification) and RReliefF (regression) (`relieffWrapper.m`) 
* Wraps around `relieff.m` from the MATLAB stats toolbox. This is available MATLAB r2010b onwards. 
* Another option for ReliefF is to use the [code](http://featureselection.asu.edu/algorithms/fs_sup_relieff.zip) from ASU Feature Selection toolbox. This uses ReliefF from weka toolbox and hence needs additional libraries. Please see the corresponding documentation.

Fisher Score (`fisherScore.m`)
* Wraps around [`fsFisher.m`](http://featureselection.asu.edu/algorithms/fs_sup_fisher_score.zip) from the ASU Feature Selection toolbox 

Note: I am sorry if the required MATLAB files are not available in the version you own. I have tried my best to use easily available code that I can rely on.

Usage
-----
* Load the data
* Create an options structure using `featSelOptions.m`
* Perform experiments using `compareFeatSelAlgos.m`