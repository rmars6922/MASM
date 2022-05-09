function y = eightday_lai(expcase,data)
% case1:2001-2009 
% case2:2010-2015
% case3:2001-2015
ii = 1; %GPP
gpp00 = data(1:366,ii); eightday00 = f(gpp00);
gpp01 = data(367:731,ii);eightday01 = f(gpp01);
gpp02 = data(732:1096,ii);eightday02 = f(gpp02);
gpp03 = data(1097:1461,ii);eightday03 = f(gpp03);
gpp04 = data(1462:1827,ii);eightday04 = f(gpp04);
gpp05 = data(1828:2192,ii);eightday05 = f(gpp05);
gpp06 = data(2193:2557,ii);eightday06 = f(gpp06);
gpp07 = data(2558:2922,ii);eightday07 = f(gpp07);
gpp08 = data(2923:3288,ii);eightday08 = f(gpp08);
gpp09 = data(3289:3653,ii);eightday09 = f(gpp09);
gpp10 = data(3654:4018,ii);eightday10 = f(gpp10);
gpp11 = data(4019:4383,ii);eightday11 = f(gpp11);
gpp12 = data(4384:4749,ii);eightday12 = f(gpp12);
gpp13 = data(4750:5114,ii);eightday13 = f(gpp13);
gpp14 = data(5115:5479,ii);eightday14 = f(gpp14);
gpp15 = data(5480:5844,ii);eightday15 = f(gpp15);
gpp16 = data(5845:6210,ii);eightday16 = f(gpp16);
gpp17 = data(6211:6575,ii);eightday17 = f(gpp17);    
gpp18 = data(6576:6940,ii);eightday18 = f(gpp18);  
gpp19 = data(6941:7305,ii);eightday19 = f(gpp19);


if expcase == 1
	y = [eightday01;eightday02;eightday03;eightday04;eightday05;eightday06;eightday07;eightday08;eightday09];
end

if expcase == 2
    
    y = [eightday10;eightday11;eightday12;eightday13;eightday14;eightday15;eightday16;eightday17];
end
if expcase == 3
    y = [eightday01;eightday02;eightday03;eightday04;eightday05;eightday06;eightday07;eightday08;eightday09;...
        eightday10;eightday11;eightday12;eightday13;eightday14;eightday15;eightday16;eightday17];
end

end

function result = f(gppdata)
    j=0;
    for i = 1:8:361   
        if (i<361)
            eightday(i-7*j,1) = mean(gppdata(i:i+7,1));
        else
            eightday(i-7*j,1) = mean(gppdata(i:length(gppdata),1));
        end
        j = j+1;
    end    
    result = eightday;
end


