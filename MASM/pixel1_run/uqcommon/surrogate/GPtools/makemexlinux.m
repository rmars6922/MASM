mex CFLAGS='-std=gnu89 -D_GNU_SOURCE -fexceptions -fPIC -fno-omit-frame-pointer -pthread' callGPtrain.c gpr.c covfunc.c utility.c
mex CFLAGS='-std=gnu89 -D_GNU_SOURCE -fexceptions -fPIC -fno-omit-frame-pointer -pthread' callGPtrain_r.c gpr.c covfunc.c utility.c
mex CFLAGS='-std=gnu89 -D_GNU_SOURCE -fexceptions -fPIC -fno-omit-frame-pointer -pthread' callGPpredict.c gpr.c covfunc.c utility.c