// embed GPtrain_r into matlab
// by Wei Gong, Sep 2014
#include <stdlib.h>
#include "constant.h"
#include "utility.h"
#include "gpr.h"
#include "covfunc.h"
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[] )
{
	double **X1, **X2, *y1, *y2, **XX, *yy, *hyp, noise;
	double **K, **L, *a, **KK, **LL, *aa;
	double *p, *m, *pX1, *pX2, *pXX, *pK, *pKK, *pL, *pLL;
    int CovIdx, nInput, nSample, nSample1, nSample2, nhyp;
    int i, j;
	mwSize x1row, x1col, x2row, x2col, y1row, y1col, y2row, y2col, hrow, hcol;

    /* Check for proper number of arguments */

    if (nrhs != 10) {
    	mexErrMsgTxt("Input arguments should be 10.");
    } else if (nlhs != 6) {
    	mexErrMsgTxt("Output arguments should be 4.");
    }

    /* Check the dimensions of X, y, hyp.  X: nSample X nInput; y: nSample X 1; hyp: 1 X nhyp. */

    x1row = mxGetM(prhs[0]);
    x1col = mxGetN(prhs[0]);
    x2row = mxGetM(prhs[1]);
    x2col = mxGetN(prhs[1]);
    y1row = mxGetM(prhs[2]);
    y1col = mxGetN(prhs[2]);
    y2row = mxGetM(prhs[3]);
    y2col = mxGetN(prhs[3]);
    hrow = mxGetM(prhs[5]);
    hcol = mxGetN(prhs[5]);

    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || (x1row == 1)) {
    	mexErrMsgTxt("X1 must be a nSample1 X nInput double matrix.");
    }
    if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) ) {
        mexErrMsgTxt("X2 must be a nSample2 X nInput double matrix.");
    }
    if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || (y1row == 1) || (y1col != 1)) {
    	mexErrMsgTxt("y1 must be a nSample1 X 1 double vector.");
    }
    if (!mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || (y2col != 1)) {
        mexErrMsgTxt("y2 must be a nSample2 X 1 double vector.");
    }
    if (!mxIsDouble(prhs[5]) || mxIsComplex(prhs[5]) || (hrow != 1) || (hcol == 1)) {
    	mexErrMsgTxt("hyp must be a 1 X nhyp double vector.");
    }
    if (x1row != y1row) {
    	mexErrMsgTxt("X1, y1 must be the same length.");
    }
    if (x2row != y2row) {
        mexErrMsgTxt("X2, y2 must be the same length.");
    }
    if (x1col != x2col) {
        mexErrMsgTxt("X1, X2 must be the same width.");
    }

	/* Generate input matrix and copy the data */
    nInput = (int)x1col;
    nSample1 = (int)x1row;
    nSample2 = (int)x2row;
    nhyp = (int)hcol;

    pX1 = mxGetPr(prhs[0]);
    X1 = DoubleMatrix(nSample1, nInput);
    for (i = 0; i < nSample1; i++) {
    	for (j = 0; j < nInput; j++) {
    		X1[i][j] = pX1[nSample1*j+i];
    	}
    }
    pX2 = mxGetPr(prhs[1]);
    X2 = DoubleMatrix(nSample2, nInput);
    for (i = 0; i < nSample2; i++) {
        for (j = 0; j < nInput; j++) {
            X2[i][j] = pX2[nSample2*j+i];
        }
    }

    y1 = mxGetPr(prhs[2]);
    y2 = mxGetPr(prhs[3]);

    p = mxGetPr(prhs[4]);
    CovIdx = (int)*p;

	hyp = mxGetPr(prhs[5]);

    p = mxGetPr(prhs[6]);
    noise = *p;

    pK = mxGetPr(prhs[7]);
    K = DoubleMatrix(nSample1, nSample1);
    for (i = 0; i < nSample1; i++) {
        for (j = 0; j < nSample1; j++) {
            K[i][j] = pK[nSample1*j+i];
        }
    }
    pL = mxGetPr(prhs[8]);
    L = DoubleMatrix(nSample1, nSample1);
    for (i = 0; i < nSample1; i++) {
        for (j = 0; j < nSample1; j++) {
            L[i][j] = pL[nSample1*j+i];
        }
    }

    a = mxGetPr(prhs[9]);

    /* Generate output matrix */
    nSample = nSample1 + nSample2;
    XX = DoubleMatrix(nSample, nInput);
    KK = DoubleMatrix(nSample, nSample);
    LL = DoubleMatrix(nSample, nSample);
    for (i = 0; i < nSample; i++) {
    	for (j = 0; j < nSample; j++) {
    		KK[i][j] = 0;
			LL[i][j] = 0;
    	}
        for (j = 0; j < nInput; j++) {
            XX[i][j] = 0;
        }
    }

    /* Create a matrix for the return argument */
    plhs[0] = mxCreateDoubleMatrix(nSample, nInput, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nSample, 1, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(nSample, nSample, mxREAL);
    plhs[3] = mxCreateDoubleMatrix(nSample, nSample, mxREAL);
    plhs[4] = mxCreateDoubleMatrix(nSample, 1, mxREAL);
    plhs[5] = mxCreateDoubleMatrix(1, 1, mxREAL);

    /* Assign pointers and values to the various parameters */
    pXX = mxGetPr(plhs[0]);
    yy  = mxGetPr(plhs[1]);
    pKK = mxGetPr(plhs[2]);
    pLL = mxGetPr(plhs[3]);
	aa  = mxGetPr(plhs[4]);
	m   = mxGetPr(plhs[5]);

    /* Do the actual computations in a subroutine */

    *m = GPtrain_r(CovIdx, nhyp, hyp, noise, nInput, nSample1, nSample2, X1, X2, XX, y1, y2, yy, K, L, a, KK, LL, aa);

    /* Write the result to mxArrays */
    for (i = 0; i < nSample; i++) {
    	for (j = 0; j < nSample; j++) {
    		pKK[nSample*j+i] = KK[i][j];
			pLL[nSample*j+i] = LL[i][j];
    	}
        for (j = 0; j < nInput; j++) {
            pXX[nSample*j+i] = XX[i][j];
        }
    }
	FreeDoubleMatrix(X1, nSample1);
    FreeDoubleMatrix(X2, nSample2);
    FreeDoubleMatrix(XX, nSample);
	FreeDoubleMatrix(K, nSample1);
	FreeDoubleMatrix(L, nSample1);
    FreeDoubleMatrix(KK, nSample);
    FreeDoubleMatrix(LL, nSample);

    return;
}
