// embed GPtrain into matlab
// by Wei Gong, Sep 2014
// For gcc: replace '-ansi' with '-std=gnu89' in mexopt.sh
#include <stdlib.h>
#include "constant.h"
#include "utility.h"
#include "gpr.h"
#include "covfunc.h"
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[] )
{
	double **X, *y, *hyp, noise;
	double **K, **L, *a;
	double *p, *m, *pX, *pK, *pL;
    int CovIdx, nInput, nSample, nhyp;
    int i, j;
	mwSize xrow, xcol, yrow, ycol, hrow, hcol;

    /* Check for proper number of arguments */

    if (nrhs != 5) {
    	mexErrMsgTxt("Input arguments should be 10.");
    } else if (nlhs != 4) {
    	mexErrMsgTxt("Output arguments should be 4.");
    }

    /* Check the dimensions of X, y, hyp.  X: nSample X nInput; y: nSample X 1; hyp: 1 X nhyp. */

    xrow = mxGetM(prhs[0]);
    xcol = mxGetN(prhs[0]);
    yrow = mxGetM(prhs[1]);
    ycol = mxGetN(prhs[1]);
    hrow = mxGetM(prhs[3]);
    hcol = mxGetN(prhs[3]);

    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || (xrow == 1)) {
    	mexErrMsgTxt("X must be a nSample X nInput double matrix.");
    }
    if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || (yrow == 1) || (ycol != 1)) {
    	mexErrMsgTxt("y must be a nSample X 1 double vector.");
    }
    if (!mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || (hrow != 1) || (hcol == 1)) {
    	mexErrMsgTxt("hyp must be a 1 X nhyp double vector.");
    }
    if (xrow != yrow) {
    	mexErrMsgTxt("X, y must be the same length.");
    }

	/* Generate input matrix and copy the data */
    nInput = (int)xcol;
    nSample = (int)xrow;
    nhyp = (int)hcol;

    pX = mxGetPr(prhs[0]);
    X = DoubleMatrix(nSample, nInput);
    for (i = 0; i < nSample; i++) {
    	for (j = 0; j < nInput; j++) {
    		X[i][j] = pX[nSample*j+i];
    	}
    }

    y = mxGetPr(prhs[1]);

    p = mxGetPr(prhs[2]);
    CovIdx = (int)*p;

	hyp = mxGetPr(prhs[3]);

    p = mxGetPr(prhs[4]);
    noise = *p;

    /* Generate output matrix */
    K = DoubleMatrix(nSample, nSample);
    L = DoubleMatrix(nSample, nSample);
    for (i = 0; i < nSample; i++) {
    	for (j = 0; j < nSample; j++) {
    		K[i][j] = 0;
			L[i][j] = 0;
    	}
    }

    /* Create a matrix for the return argument */
    plhs[0] = mxCreateDoubleMatrix(nSample, nSample, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nSample, nSample, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(nSample, 1, mxREAL);
    plhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);

    /* Assign pointers and values to the various parameters */
    pK = mxGetPr(plhs[0]);
    pL = mxGetPr(plhs[1]);
	a = mxGetPr(plhs[2]);
	m = mxGetPr(plhs[3]);

    /* Do the actual computations in a subroutine */

    *m = GPtrain(CovIdx, nhyp, hyp, noise, nInput, nSample, X, y, K, L, a);

    /* Write the result to mxArrays */
    for (i = 0; i < nSample; i++) {
    	for (j = 0; j < nSample; j++) {
    		pK[nSample*j+i] = K[i][j];
			pL[nSample*j+i] = L[i][j];
    	}
    }
	FreeDoubleMatrix(X, nSample);
	FreeDoubleMatrix(K, nSample);
	FreeDoubleMatrix(L, nSample);

    return;
}
