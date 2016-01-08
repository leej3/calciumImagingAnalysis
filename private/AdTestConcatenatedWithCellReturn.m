function [adtestOutputAsConcatenatedString] = adtestconcatenated(inputMatrix)
try
[h p] = adtest(inputMatrix);
adtestOutputAsConcatenatedString = {[ num2str(h)  ' ('  num2str(p,'%.3f') ')']};
catch
    adtestOutputAsConcatenatedString = {'-'};
end