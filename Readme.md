Feature Selection using Partial Least Squares Regression and Optimal Experiment Design
============================================================
This repository contains code for the _Optimal Loadings_ feature selection technique proposed in the following paper [pdf](http://www.umiacs.umd.edu/~varun/files/optimal-loadings-IJCNN15.pdf).
```
@inproceedings{NagarajaPLS15,
  author    = {Varun K. Nagaraja and
               Wael Abd{-}Almageed},
  title     = {Feature Selection using Partial Least Squares Regression and Optimal
               Experiment Design},
  booktitle = {International Joint Conference on Neural Networks, {IJCNN}},
  year      = {2015}
}
```

The determinant maximization is performed using a modified version of the candidate exchange function present in the MATLAB Statistics Toolbox. Since I cannot share the original source of the MATLAB function, I have created a proteced file. Contact me if you want to know the edits. 

Other techniques compared in the paper
--------------------------------------
Minimum Redundancy Maximum Relevance (mRMR) (`mRMR.m`)
* Needs external library. See `mRMR.m` for details.
* Download a newer version of the [mutual information toolbox](http://www.mathworks.com/matlabcentral/fileexchange/14888)

Partial Least Squares (PLS) regression coefficients (`regCoef.m`)
* Uses `plsregress.m` from MATLAB statistics toolbox

ReliefF (classification) and RReliefF (regression) (`relieffWrapper.m`) 
* Wraps around `relieff.m` from the MATLAB stats toolbox. This is available MATLAB r2010b onwards. 
* Another option for ReliefF is to use the [code](http://featureselection.asu.edu/old/algorithms/fs_sup_relieff.zip) from ASU Feature Selection toolbox. This uses ReliefF from weka toolbox and hence needs additional libraries. Please see the corresponding documentation.

Fisher Score (`fisherScore.m`)
* Wraps around [`fsFisher.m`](http://featureselection.asu.edu/old/algorithms/fs_sup_fisher_score.zip) from the ASU Feature Selection toolbox 

Usage
-----
* Load the data
* Create an options structure using `featSelOptions.m`
* Perform experiments using `compareFeatSelAlgos.m`
