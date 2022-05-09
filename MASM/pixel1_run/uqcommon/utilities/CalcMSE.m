function ee = CalcMSE(X,Y)
ee = sum((X-Y).^2)/length(X);