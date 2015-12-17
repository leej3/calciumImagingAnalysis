function [matFileName] = GetMatFileName(lsmFileName)
%returns the matFileName with the .mat extension.
matFileName=[];
stimID = regexp(lsmFileName,'f\d\dr\d\d[a-z]','match');
% Date will be extracted by recognising 8 numbers together that start with
% the years 2011-2029.
dateStr=regexp(lsmFileName,'20[1-2][1-9]\d\d\d\d','match');
if ~isempty(stimID)&~isempty(dateStr)
matFileName=[stimID{1}  dateStr{1} '.mat'];
else
    folderContents = what;
    matFileName = [genvarname('atypicalFilename',cellfun(@(x) x(1:end-4),folderContents.mat,'UniformOutput',0)) '.mat'];
end
end
