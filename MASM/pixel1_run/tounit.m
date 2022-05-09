function xu = tounit(x)
% vmaxub,p5,p14,p15,p17,p18,p20
    parub = [0.1,0.996,0.996,8.0e-05,0.1,0.7,365];
	parlb = [0.05,0.6,0.6,2.0e-5,1.0e-04,0.1,200];
	pardf = [0.06,0.97,0.99,3.0e-05,0.06,0.48,270];
    parrng = (parub-parlb);
    
    nInputS = 7;
    [T,ndim] = size(x);
    xu = zeros(T,nInputS);
    for i = 1:T
       xu(i,:) = (x(i,:) - parlb)./parrng;
    end
end