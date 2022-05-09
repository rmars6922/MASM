// embed GPpredict into matlab
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
	double **X1, **X2, *hyp, *y, *pv;
	double **L, *a;
	double *p, *pX1, *pX2, *pL;
    int CovIdx, nInput, nSample1, nSample2, nhyp;
    int i, j;
	mwSize x1row, x1col, x2row, x2col, hrow, hcol;

    /* Check for proper number of arguments */

    if (nrhs != 6) {
    	mexErrMsgTxt("Input arguments should be 6.");
    } else if (nlhs != 2) {
    	mexErrMsgTxt("Output arguments should be 2.");
    }

    /* Check the dimensions of X, y, hyp.  X: nSample X nInput; y: nSample X 1; hyp: 1 X nhyp. */

    x1row = mxGetM(prhs[0]);
    x1col = mxGetN(prhs[0]);
    x2row = mxGetM(prhs[1]);
    x2col = mxGetN(prhs[1]);
    hrow = mxGetM(prhs[3]);
    hcol = mxGetN(prhs[3]);

    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || (x1row == 1)) {
    	mexErrMsgTxt("X1 must be a nSample1 X nInput double matrix.");
    }
    if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])) {
    	mexErrMsgTxt("X2 must be a nSample2 X nInput double matrix.");
    }
    if (!mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || (hrow != 1) || (hcol == 1)) {
    	mexErrMsgTxt("hyp must be a 1 X nhyp double vector.");
    }
    if (x1col != x2col) {
    	mexErrMsgTxt("X1, X2 must have the same nInput.");
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

    p = mxGetPr(prhs[2]);
    CovIdx = (int)*p;

	hyp = mxGetPr(prhs[3]);

    pL = mxGetPr(prhs[4]);
    L = DoubleMatrix(nSample1, nSample1);
    for (i = 0; i < nSample1; i++) {
        for (j = 0; j < nSample1; j++) {
            L[i][j] = pL[nSample1*j+i];
        }
    }

    a = mxGetPr(prhs[5]);

    /* Generate output matrix */

    /* Create a matrix for the return argument */
    plhs[0] = mxCreateDoubleMatrix(nSample2, 1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nSample2, 1, mxREAL);

    /* Assign pointers and values to the various parameters */
    y = mxGetPr(plhs[0]);
    pv = mxGetPr(plhs[1]);

    /* Do the actual computations in a subroutine */

    GPpredict(CovIdx, nhyp, hyp, nInput, nSample1, nSample2, X1, X2, y, pv, L, a);

    /* Write the result to mxArrays */
	FreeDoubleMatrix(X1, nSample1);
	FreeDoubleMatrix(X2, nSample2);
	FreeDoubleMatrix(L, nSample1);

    return;
}
