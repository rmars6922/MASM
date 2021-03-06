The original version of IBIS can be found from https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=808. 
The modified version of IBIS used in our manuscript is available by contacting the authors (luhaibo@mail.sysu.edu.cn and marui6922@whu.deu.cn).

The DALEC model and the model-data fusion code was used to generate the assimilated data for "Reference carbon cycle dataset for typical Chinese forests via colocated observations and data assimilation".

The DALEC model (evergreen and deciduous versions) written in fortan is fistly published in the REFLEX project host by prof Williams Mathew (Mat.Williams@ed.ac.uk).
Ref: Fox, A, M Williams, AD Richardson, D Cameron, JH Gove, T Quaife, D Ricciuto, M Reichstein, E Tomelleri, C Trudinger, MT van Wijk (2009) The REFLEX project: comparing different algorithms and implementations for the inversion of a terrestrial ecosystem model against eddy covariance data, Agricultural and Forest Meteorology 149, 1597–1615.

The main programm for MCMC and likelihood function is revised based on the code from John Zobitz (zobitz@augsburg.edu).The code requires Matlab version 2014a or higher. Ref: Zobitz J M, Desai A R, Moore D J P, Chadwick M A. A primer for data assimilation with ecological models using Markov Chain Monte Carlo (MCMC). Oecologia, 2011, 167(3): 599-611.

The standalone version of ASMO-PODE can be accessed directly from https://github.com/gongw03/ASMO-PODE (Gong et al., 2017).

We provide an optimization script of one pixel as well as its driving data as material to support the implementation of MASM algorithm in calibrating the IBIS simulator. (Please find the file: pixel1_run)