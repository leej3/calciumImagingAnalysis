function [semVals] = GetSEM(inputMat)
    % Each row of inputMat is a time-series
    semVals = std(inputMat,0,1)/sqrt(size(inputMat,1));
end