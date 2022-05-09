function ee = CalcNRMSE(X,Y)
ee = CalcRMSE(X,Y)/(max(X)-min(X));